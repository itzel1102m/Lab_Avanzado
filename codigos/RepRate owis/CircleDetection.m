function res = CircleDetection(Im)
% Detecta círculos en una imagen blanco/negro (dibujo en blanco, fondo negro).
% Salida: res{i} = [cy, cx, r]  (fila, columna, radio) en píxeles

if ischar(Im) || isstring(Im)
    Im2 = imread(Im);      % con el nombre del archivo
else
    Im2 = Im;              % con la imagen ya leída
end

if size(Im2,3) == 3
    grayImage = rgb2gray(Im2);
else
    grayImage = Im2;
end
BW = imbinarize(grayImage);

% Si el círculo está dibujado solo como contorno, lo rellenamos
BW = imfill(BW, 'holes');
BW = bwareaopen(BW, 20);                 % quita ruido de pocos píxeles

stats = regionprops(BW, 'Centroid', 'Area', 'Perimeter', 'EquivDiameter');
Nc = numel(stats);

res = cell(1, Nc);
circ = zeros(1, Nc);
for i = 1:Nc
    cx = stats(i).Centroid(1);           % Centroid = [x y]
    cy = stats(i).Centroid(2);
    r  = stats(i).EquivDiameter / 2;     % radio del círculo de igual área
    res{i} = [cy, cx, r];
    circ(i) = 4*pi*stats(i).Area / stats(i).Perimeter^2;   % ~1 si es círculo
end

% Aviso si alguna figura no parece un círculo
for i = find(circ < 0.85)
    warning('Figura %d tiene circularidad %.2f: puede no ser un círculo.', i, circ(i));
end

% Ordenar por altura (fila) y luego por columna
cen = cell2mat(res');
[~, idx] = sortrows(cen(:,1:2));
res = res(idx);

% Visualización
imshow(BW); hold on
for i = 1:Nc
    plot(res{i}(2), res{i}(1), 'yo', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
    viscircles([res{i}(2), res{i}(1)], res{i}(3), 'Color', 'r', 'LineWidth', 1);
end
hold off
end
