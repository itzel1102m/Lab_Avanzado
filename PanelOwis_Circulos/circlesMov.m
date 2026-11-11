function circlesMov(res, grupos, BW, p)
% CIRCLESMOV  Equivalente de generalMov pero para círculos y anillos.
% Recibe la salida de RingDetection y, para cada figura:
%   1) mueve la mesa con el láser APAGADO al punto de arranque (cx, cy+R_int)
%   2) llama a anilloMov, que traza el círculo o rellena el anillo.
%
% Convención de coordenadas (la misma que generalMov):
%   - 1 píxel = p.pix2mm mm  (generalMov usa /1000 -> 1 px = 1 um)
%   - eje X del motor = columna de la imagen, eje Y = fila
%   - la posición de la mesa al presionar "Run" es el CENTRO de la imagen
%     (antes, en generalMov, era la esquina = píxel (0,0)).
%     Al terminar, la mesa regresa a ese mismo punto.
%
% Cómo decide qué trazar con los grupos de RingDetection:
%   - grupo de 1 círculo          -> círculo sencillo
%   - grupo de 2+ concéntricos    -> recorre los radios de menor a mayor y
%     revisa en BW si entre dos radios consecutivos hay blanco:
%       blanco -> anillo relleno entre ambos radios
%       negro  -> son líneas separadas: cada una es un círculo sencillo

if nargin < 4, p = struct(); end
if ~isfield(p, 'pix2mm'), p.pix2mm = 1/1000; end
if ~isfield(p, 'axis_X'), p.axis_X = 1; end
if ~isfield(p, 'axis_Y'), p.axis_Y = 2; end

% ---------- conectar con el PS35 (como hacía ps35tool) ----------
% Si p.COMp viene definido, se conecta aquí mismo, así no importa si se
% te olvidó presionar el botón de conectar del panel.
if isfield(p, 'COMp') && ~isempty(p.COMp) && ~isnan(p.COMp)
    conectarPS35(p);
end

% ---------- lista de trazos [cy cx R_int R_ext] en píxeles ----------
trazos = zeros(0,4);
for g = 1:numel(grupos)
    c = cell2mat(res(grupos{g})');            % [cy cx r] de cada borde
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
% Las coordenadas se miden desde el centro de la imagen, que corresponde a
% donde está el láser al presionar Run.
c0y = (size(BW,1) + 1)/2;                      % fila del centro
c0x = (size(BW,2) + 1)/2;                      % columna del centro
trazos(:,1) = trazos(:,1) - c0y;
trazos(:,2) = trazos(:,2) - c0x;

% ---------- mostrar el plan antes de mover ----------
fprintf('\n%d trazo(s) a realizar (coordenadas desde el centro de la imagen):\n', size(trazos,1));
for t = 1:size(trazos,1)
    if trazos(t,3) == trazos(t,4)
        fprintf('  %d) círculo  centro (x=%+.0f, y=%+.0f) px   r = %.1f px\n', t, trazos(t,2), trazos(t,1), trazos(t,3));
    else
        fprintf('  %d) anillo   centro (x=%+.0f, y=%+.0f) px   r = %.1f a %.1f px\n', t, trazos(t,2), trazos(t,1), trazos(t,3), trazos(t,4));
    end
end

% ---------- ejecutar ----------
DAQstate(false);
posX = 0;  posY = 0;                           % mm, relativo al centro de la imagen
for t = 1:size(trazos,1)
    cx = trazos(t,2)*p.pix2mm;   cy = trazos(t,1)*p.pix2mm;
    Ri = trazos(t,3)*p.pix2mm;   Re = trazos(t,4)*p.pix2mm;

    % 1) ir al arranque (ángulo 90°): (cx, cy + Ri), láser apagado
    moverRel(p, cx - posX, (cy + Ri) - posY);

    % 2) trazar
    fprintf('Trazo %d de %d ...\n', t, size(trazos,1));
    Rfin = anilloMov(Ri, Re, p);

    % 3) anilloMov termina en (cx, cy + Rfin)
    posX = cx;  posY = cy + Rfin;
end

% regresar al punto de inicio (centro de la imagen)
moverRel(p, -posX, -posY);
disp('Listo.');
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
% Igual que el inicio de ps35tool / el botón de conectar del panel.
if ~libisloaded('ps35')
    loadlibrary('ps35', 'ps35.h');
end
COMp = int32(p.COMp);
if COMp == 0                       % primer controlador que encuentre
    ret = calllib('ps35','PS35_SimpleConnect', 1, '');
elseif COMp == -1                  % por red (tcp/ip)
    ret = calllib('ps35','PS35_SimpleConnect', 1, 'net');
else                               % puerto COM indicado
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
% Movimiento relativo en línea recta, láser apagado (como ps35tool).
if ~isfield(p,'axis_X'), p.axis_X = 1; end
if ~isfield(p,'axis_Y'), p.axis_Y = 2; end
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
