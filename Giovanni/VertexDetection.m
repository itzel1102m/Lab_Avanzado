function res = CircleDetection(Im)

Im2 = imread(Im);   % Carga la imagen

grayImage = rgb2gray(Im2);  % Convierte a escala de grises
BW = imbinarize(grayImage); % Binariza la imagen

% Mide las propiedades de las regiones conectadas
R = regionprops(BW, 'Centroid', 'EquivDiameter', 'PixelIdxList', ...
    'EulerNumber', 'BoundingBox');
% Calcula su centroide, el diametro del circulo con la misma area que la
% region detectada. EulerNumber: Número de objetos en la región menos el 
% número de huecos en esos objetos, devuelto como un escalar.

Nv = numel(R);

centers = zeros(Nv,2);

% Radios
innerRadii = zeros(Nv,1);
outerRadii = zeros(Nv,1);

% Tipo de objeto
type = strings(Nv,1);

imshow(BW)
hold on

% Recorre cada objeto
for i = 1:Nv

    % Centros
    centers(i,:) = R(i).Centroid;

    % Circulo. Si es un circulo es una region, sin huecos... 
    % EulerNumber=+1-0=1    
    if R(i).EulerNumber == 1

        type(i) = "circulo";

        % Radio = diámetro equivalente / 2
        outerRadii(i) = R(i).EquivDiameter / 2;

        % Dibujar centro
        plot(centers(i,1), centers(i,2), ...
            'ro', 'MarkerFaceColor','r', 'MarkerSize',5);

        % Dibujar círculo
        theta = linspace(0,2*pi,200);

        x = centers(i,1) + outerRadii(i)*cos(theta);
        y = centers(i,2) + outerRadii(i)*sin(theta);

        plot(x,y,'y','LineWidth',1.5);


    % Si es un anillo, tiene un hueco y EulerNumber=+1-1=0.
    elseif R(i).EulerNumber == 0
        
        % Solo escribe un string si es anillo o circulo
        type(i) = "anillo";

        % Recortar solamente la región del anillo
        box = R(i).BoundingBox;

        x1 = floor(box(1));
        y1 = floor(box(2));
        x2 = ceil(box(1) + box(3) - 1);
        y2 = ceil(box(2) + box(4) - 1);
        x1 = max(x1,1);
        y1 = max(y1,1);
        x2 = min(x2,size(BW,2));
        y2 = min(y2,size(BW,1));
        
        % Traza los limites de una region donde esta la imagen binaria
        BWcrop = BW(y1:y2,x1:x2);

        % Rellenar el hueco del anillo
        BWfilled = imfill(BWcrop,'holes');

        % El hueco es la diferencia entre la región rellena (circulo
        % exteiror) y la región original
        hole = BWfilled & ~BWcrop;

        % Segundo regionprops: medir el hueco
        H = regionprops(hole,'Area','Centroid','EquivDiameter');

        if ~isempty(H)  % Si H no esta vacio, hay anillo

            % Radio interior
            innerRadii(i) = H(1).EquivDiameter / 2;

        end

        % Radio exterior
        % El diametro equivalente de la region rellena
        % corresponde al circulo exterior
        E = regionprops(BWfilled,'EquivDiameter');

        outerRadii(i) = E(1).EquivDiameter / 2;
        
        % Dibuja en la figura los anillos
        plot(centers(i,1), centers(i,2), ...
            'ro', 'MarkerFaceColor','r', 'MarkerSize',5);

        theta = linspace(0,2*pi,200);

        % Circunferencia exterior
        xOuter = centers(i,1) + ...
            outerRadii(i)*cos(theta);

        yOuter = centers(i,2) + ...
            outerRadii(i)*sin(theta);

        plot(xOuter,yOuter,'y','LineWidth',1.5);

        % Circunferencia interior
        xInner = centers(i,1) + ...
            innerRadii(i)*cos(theta);

        yInner = centers(i,2) + ...
            innerRadii(i)*sin(theta);

        plot(xInner,yInner,'c','LineWidth',1.5);

    end

end

hold off


% Ordenar
[~,idx] = sort(centers(:,2));

centers = centers(idx,:);
innerRadii = innerRadii(idx);
outerRadii = outerRadii(idx);
type = type(idx);

% Imprimie resultados
disp('Centros [x, y]:')
disp(centers)

disp('Tipo:')
disp(type)

disp('Radios exteriores:')
disp(outerRadii)

disp('Radios interiores:')
disp(innerRadii)


res.centers = centers;
res.innerRadii = innerRadii;
res.outerRadii = outerRadii;
res.type = type;

end
