% Imagen negra de 400 x 600 píxeles
Im = false(400, 600);
[X, Y] = meshgrid(1:600, 1:400);

% Círculos: [cx, cy, r]  (columna, fila, radio)
circulos = [100 100 40;
    300 120 60;
    500  90 30;
    150 300 50;
    420 290 70];

for k = 1:size(circulos,1)
    cx = circulos(k,1); cy = circulos(k,2); r = circulos(k,3);
    Im((X-cx).^2 + (Y-cy).^2 <= r^2) = true;   % disco blanco relleno
end

imwrite(Im, 'prueba_circulos.png');
imshow(Im)
