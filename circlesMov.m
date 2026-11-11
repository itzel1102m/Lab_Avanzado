function circlesMov(res, grupos, BW, p)
% CIRCLESMOV  Equivalente de generalMov para círculos y anillos.
% Recibe la salida de RingDetectionCirc y, para cada figura:
%   1) mueve la mesa con el láser APAGADO al arranque (cx, cy+R_int)
%   2) llama a anilloMov, que traza el círculo o rellena el anillo.
%
% Coordenadas: 1 px = p.pix2mm mm; X motor = columna, Y motor = fila;
% la posición de la mesa al presionar "Go Ablation" es el CENTRO de la
% imagen; al terminar regresa ahí.
%
% CAMBIOS 2026-11-04: imprime cuánto tarda cada fase (conexión, traslado,
% escritura de tabla, trazo) para ubicar dónde se pierde el tiempo.

if nargin < 4, p = struct(); end
if ~isfield(p, 'pix2mm'), p.pix2mm = 1/1000; end
if ~isfield(p, 'axis_X'), p.axis_X = 1; end
if ~isfield(p, 'axis_Y'), p.axis_Y = 2; end
tTotal = tic;

% ---------- conectar con el PS35 ----------
if isfield(p, 'COMp') && ~isempty(p.COMp) && ~isnan(p.COMp)
    t0 = tic;
    conectarPS35(p);
    fprintf('[t] conexión PS35: %.1f s\n', toc(t0));
end

% ---------- lista de trazos [cy cx R_int R_ext] en píxeles ----------
trazos = zeros(0,4);
for g = 1:numel(grupos)
    c = cell2mat(res(grupos{g})');
    [r, o] = sort(c(:,3));  c = c(o,:);
    cy = mean(c(:,1));  cx = mean(c(:,2));
    k = 1;
    while k <= numel(r)
        if k < numel(r) && entreEsBlanco(BW, cy, cx, r(k), r(k+1))
            trazos(end+1,:) = [cy cx r(k) r(k+1)]; %#ok<AGROW>
            k = k + 2;
        else
            trazos(end+1,:) = [cy cx r(k) r(k)];   %#ok<AGROW>
            k = k + 1;
        end
    end
end

% ---------- origen = centro de la imagen ----------
c0y = (size(BW,1) + 1)/2;
c0x = (size(BW,2) + 1)/2;
trazos(:,1) = trazos(:,1) - c0y;
trazos(:,2) = trazos(:,2) - c0x;

% ---------- plan ----------
fprintf('\n%d trazo(s) a realizar (coordenadas desde el centro de la imagen):\n', size(trazos,1));
for t = 1:size(trazos,1)
    if trazos(t,3) == trazos(t,4)
        fprintf('  %d) círculo  centro (x=%+.0f, y=%+.0f) px   r = %.1f px\n', t, trazos(t,2), trazos(t,1), trazos(t,3));
    else
        fprintf('  %d) anillo   centro (x=%+.0f, y=%+.0f) px   r = %.1f a %.1f px\n', t, trazos(t,2), trazos(t,1), trazos(t,3), trazos(t,4));
    end
end

% ---------- ejecutar ----------
t0 = tic;
DAQstate(false);
fprintf('[t] DAQstate (apagar láser): %.1f s\n', toc(t0));

posX = 0;  posY = 0;                           % mm, relativo al centro
for t = 1:size(trazos,1)
    cx = trazos(t,2)*p.pix2mm;   cy = trazos(t,1)*p.pix2mm;
    Ri = trazos(t,3)*p.pix2mm;   Re = trazos(t,4)*p.pix2mm;

    fprintf('\nTrazo %d de %d\n', t, size(trazos,1));

    % 1) ir al arranque (ángulo 90°): (cx, cy + Ri), láser apagado
    t0 = tic;
    moverRel(p, cx - posX, (cy + Ri) - posY);
    fprintf('[t] traslado al arranque: %.1f s\n', toc(t0));

    % 2) trazar
    t0 = tic;
    Rfin = anilloMov(Ri, Re, p);
    fprintf('[t] anilloMov total: %.1f s\n', toc(t0));

    % 3) anilloMov termina en (cx, cy + Rfin)
    posX = cx;  posY = cy + Rfin;
end

% regresar al punto de inicio (centro de la imagen)
t0 = tic;
moverRel(p, -posX, -posY);
fprintf('[t] regreso al centro: %.1f s\n', toc(t0));
fprintf('[t] TOTAL: %.1f s\nListo.\n', toc(tTotal));
end

% =========================================================================
function b = entreEsBlanco(BW, cy, cx, r1, r2)
% ¿El aro entre r1 y r2 está relleno de blanco? (muestrea 72 puntos)
th = linspace(0, 2*pi, 73);  th(end) = [];
rm = (r1 + r2)/2;
yy = round(cy + rm*sin(th));  xx = round(cx + rm*cos(th));
ok = yy >= 1 & yy <= size(BW,1) & xx >= 1 & xx <= size(BW,2);
if ~any(ok), b = false; return; end
b = mean(BW(sub2ind(size(BW), yy(ok), xx(ok)))) > 0.5;
end

function conectarPS35(p)
if ~libisloaded('ps35')
    loadlibrary('ps35', 'ps35.h');
end
COMp = int32(p.COMp);
if COMp == 0
    ret = calllib('ps35','PS35_SimpleConnect', 1, '');
elseif COMp == -1
    ret = calllib('ps35','PS35_SimpleConnect', 1, 'net');
else
    ret = calllib('ps35','PS35_Connect', 1, 0, COMp, 230400, 0, 0, 0, 0);
end
if ret ~= 0
    warning(['PS35_Connect regresó %d en COM%d: puede que no se haya ' ...
             'conectado. Revisa el número de puerto en el panel.'], ret, COMp);
end
calllib('ps35','PS35_MotorInit', 1, p.axis_X);
calllib('ps35','PS35_MotorInit', 1, p.axis_Y);
calllib('ps35','PS35_SetTargetMode', 1, p.axis_X, 0);   % relativo
calllib('ps35','PS35_SetTargetMode', 1, p.axis_Y, 0);
fprintf('Conexión al PS35 en COM%d (código %d, 0 = OK).\n', COMp, ret);
end

function moverRel(p, dx, dy)
% Movimiento relativo en línea recta, láser apagado.
calllib('ps35','PS35_SetTargetMode', 1, p.axis_X, 0);
calllib('ps35','PS35_SetTargetMode', 1, p.axis_Y, 0);
if isfield(p,'vx') && p.vx > 0, calllib('ps35','PS35_SetPosF', 1, p.axis_X, p.vx); end
if isfield(p,'vy') && p.vy > 0, calllib('ps35','PS35_SetPosF', 1, p.axis_Y, p.vy); end
if abs(dx) > 1e-6, calllib('ps35','PS35_MoveEx', 1, p.axis_X, dx, 1); end
if abs(dy) > 1e-6, calllib('ps35','PS35_MoveEx', 1, p.axis_Y, dy, 1); end
while calllib('ps35','PS35_GetMoveState', 1, p.axis_X) > 0 || ...
      calllib('ps35','PS35_GetMoveState', 1, p.axis_Y) > 0
    pause(0.02);
end
end
