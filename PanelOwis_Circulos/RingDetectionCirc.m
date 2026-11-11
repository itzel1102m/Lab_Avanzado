function [res, grupos, BW] = RingDetectionCirc(Im, grosorMax)
% (3a salida BW: la imagen binaria ya limpia; circlesMov la usa para saber
%  si entre dos círculos concéntricos hay relleno -> anillo relleno)
% Detecta círculos (incluye anillos / círculos concéntricos) en una imagen B/N
% (dibujo en blanco, fondo negro).
% Salidas:
%   res{i}    = [cy, cx, r]  (fila, columna, radio) en píxeles
%   grupos{j} = índices de res que comparten centro (numel>1 -> anillo)
% grosorMax: grosor máximo (px) de una línea de contorno. Dos bordes cuyos
%            radios difieren menos que esto se consideran el MISMO círculo.
if nargin < 2, grosorMax = 5; end  %grosormax es un argumento opcional, si no se le da toma 5

%esta parte es para leer la imagen 
if ischar(Im) || isstring(Im)
    Im2 = imread(Im);
else
    Im2 = Im;
end

%convierte la imagen a blanco y negro
if size(Im2,3) == 3
    grayImage = rgb2gray(Im2);
else
    grayImage = Im2;
end
BW = imbinarize(grayImage);

BW = bwareaopen(BW, 20);        % quita puntitos blancos sueltos
BW = ~bwareaopen(~BW, 20);      % rellena SOLO huecos diminutos (ruido), no los anillos

% 1. Ajustar un círculo a cada contorno (exteriores y de huecos) 
B = bwboundaries(BW, 'holes'); %Detecta contornos y contornos de los huecos que hay dentro (anillos)
C = zeros(0,4);                 % [cy cx r error]
for k = 1:numel(B) %numel(B) es el numero de contornos que encontro 
    P = B{k}; %p son los puntos del contorno k
    if size(P,1) < 20, continue; end            % contornos demasiado pequeños si tiene menos de 20 puntos 
    y = P(:,1);  x = P(:,2);
    % Ajuste algebraico: x^2 + y^2 + a*x + b*y + c = 0
    % ======================================================================
    % AJUSTE DE CÍRCULO POR MÍNIMOS CUADRADOS (método de Kasa)
    % ----------------------------------------------------------------------
    % Ecuación del círculo:   (x - cx)^2 + (y - cy)^2 = r^2
    % Expandida:              x^2 + y^2 + a*x + b*y + c = 0
    %   con  a = -2*cx,  b = -2*cy,  c = cx^2 + cy^2 - r^2
    %
    % Esta forma es LINEAL en (a, b, c). Cada píxel (xi, yi) del contorno
    % da una ecuación:
    %       a*xi + b*yi + c = -(xi^2 + yi^2)
    % En forma matricial:  A*p = b
    %       A = [x  y  1]   (N x 3),   p = [a; b; c],   b = -(x.^2 + y.^2)
    %
    % Sistema SOBREDETERMINADO: N ecuaciones (cientos de píxeles) y solo
    % 3 incógnitas. Por la discretización en píxeles y el ruido, ningún
    % círculo pasa exactamente por todos los puntos -> no hay solución exacta.
    %
    % El operador "\" resuelve por MÍNIMOS CUADRADOS:
    %       min  sum_i ( a*xi + b*yi + c + xi^2 + yi^2 )^2
    %       solución:  p = (A'*A)^(-1) * A'*b   (MATLAB usa QR, más estable)
    % Equivale a una regresión lineal: respuesta -(x^2+y^2),
    % variables x, y e intercepto.
    %
    % Recuperar centro y radio:
    %       cx = -a/2,   cy = -b/2,   r = sqrt(cx^2 + cy^2 - c)
    %
    % Calidad del ajuste:
    %       err = std(distancias al centro) / r   (~0 si es un círculo)
    %
    % Implicaciones:
    %  + Los errores de cada píxel se promedian -> precisión sub-píxel.
    %  - Siempre devuelve "el mejor círculo", aunque la figura no lo sea
    %    -> por eso se revisa err.
    %  - Minimiza un error ALGEBRAICO, no la distancia geométrica: pequeño
    %    sesgo (radio algo menor) con arcos cortos o mucho ruido;
    %    despreciable para contornos completos y limpios.
    %  - Requiere puntos que rodeen el círculo; si están casi alineados,
    %    A'*A es casi singular y el resultado es inestable.
    % ======================================================================
    p  = [x y ones(size(x))] \ -(x.^2 + y.^2);
    cx = -p(1)/2;  cy = -p(2)/2;
    r  = sqrt(cx^2 + cy^2 - p(3));
    err = std(hypot(x-cx, y-cy)) / r;           % ~0 si es un círculo
    C(end+1,:) = [cy cx r err]; %#ok<AGROW>
end

% --- 2. Fusionar bordes que son el mismo círculo (los 2 lados de una línea) ---
usado = false(size(C,1),1);
res = {};
for i = 1:size(C,1)
    if usado(i), continue; end
    d = hypot(C(:,1)-C(i,1), C(:,2)-C(i,2));
    mismo = ~usado & d < grosorMax & abs(C(:,3)-C(i,3)) <= grosorMax;
    usado(mismo) = true;
    m = mean(C(mismo,:), 1);
    res{end+1} = m(1:3); %#ok<AGROW>
    if max(C(mismo,4)) > 0.05
        warning('Círculo en (%.0f, %.0f) r=%.1f: el contorno no parece circular (error %.2f).', ...
            m(2), m(1), m(3), max(C(mismo,4)));
    end
end
Nc = numel(res);
if Nc == 0, grupos = {}; return; end

% --- 3. Ordenar por fila, columna y luego radio ---
cen = cell2mat(res');
[~, idx] = sortrows([round(cen(:,1:2)) cen(:,3)]);
res = res(idx);
cen = cen(idx,:);

% --- 4. Agrupar círculos concéntricos (anillos) ---
g = zeros(Nc,1);  grupos = {};
for i = 1:Nc
    if g(i), continue; end
    conc = g == 0 & hypot(cen(:,1)-cen(i,1), cen(:,2)-cen(i,2)) < grosorMax;
    g(conc) = numel(grupos) + 1;
    grupos{end+1} = find(conc)'; %#ok<AGROW>
end

% --- Visualización ---
imshow(BW); hold on
for i = 1:Nc
    plot(res{i}(2), res{i}(1), 'yo', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
    viscircles([res{i}(2), res{i}(1)], res{i}(3), 'Color', 'r', 'LineWidth', 1);
end
hold off
end