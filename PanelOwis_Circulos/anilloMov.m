function R_final = anilloMov(R_int, R_ext, p)
% ANILLOMOV  Versión en FUNCIÓN de circulo_while (Updated 2026_05_28) para
% usarse desde PanelOwis.
%
% Traza, con interpolación circular del PS35 (PS35_CircleToVectorTab),
% círculos concéntricos desde R_int hasta R_ext separados por el paso del
% láser. Si R_int == R_ext traza UN solo círculo.
%
% IMPORTANTE (igual que en circulo_while):
%   - Modo RELATIVO: el centro NO se le da al controlador. El círculo arranca
%     en la posición actual de la mesa, que debe estar en el ángulo
%     p.angleStart (=90°) del primer círculo, es decir, en
%         (cx, cy + R_int)
%     Esa posición la deja lista circlesMov antes de llamar a esta función.
%   - Termina en (cx, cy + R_final), con R_final = último radio trazado.
%
% DIFERENCIAS con el live script circulo_while:
%   - NO hace clear / close all / clc (borraban handles y cerraban el panel).
%   - NO hace loadlibrary, PS35_Connect, Disconnect ni unloadlibrary:
%     usa la conexión que ya abrió PanelOwis (botón de conectar).
%   - Si el anillo necesita más de 2000 renglones de tabla, lo parte en
%     varios lotes en vez de marcar error.
%   - Revisa el valor de retorno de las llamadas al PS35 y avisa si alguna
%     falla (antes fallaban en silencio).
%
% Entradas (todas en mm):
%   R_int, R_ext : radios interior y exterior
%   p            : struct con campos (ver valores por defecto abajo)
%       axis_X, axis_Y, motorSpeed [mm/ms], laserStepWidth [mm],
%       secantNum, angleStart, t_max [ms], mm2incrementsFactor

% ---------------- valores por defecto (los de circulo_while) -------------
def.axis_X = 1;
def.axis_Y = 2;
def.motorSpeed = 0.2e-3;          % 0.2 um/ms  (= 0.2 mm/s)
def.laserStepWidth = 0.7e-3;      % 0.7 um
def.secantNum = 100;
def.angleStart = 90;
def.t_max = 1600;                 % ms, máximo por secante (PS35: 1638 ms)
def.mm2incrementsFactor = 10000;
def.maxTableEntries = 2000;
if nargin < 3, p = struct(); end
f = fieldnames(def);
for k = 1:numel(f)
    if ~isfield(p, f{k}) || isempty(p.(f{k})), p.(f{k}) = def.(f{k}); end
end

angleArc = 360;
mmInc = p.mm2incrementsFactor;

% ---------------- velocidad y modo relativo ------------------------------
chk(calllib('ps35','PS35_SetTargetMode', 1, p.axis_X, 0), 'SetTargetMode X');
chk(calllib('ps35','PS35_SetTargetMode', 1, p.axis_Y, 0), 'SetTargetMode Y');
chk(calllib('ps35','PS35_SetPosFEx', 1, p.axis_X, p.motorSpeed/1e-3), 'SetPosFEx X');
chk(calllib('ps35','PS35_SetPosFEx', 1, p.axis_Y, p.motorSpeed/1e-3), 'SetPosFEx Y');

% ---------------- paso del láser (semicírculo de radio paso/2) -----------
laserCircumRadius = ceil((p.laserStepWidth/2)*mmInc);      % en incrementos
laserStepWidth    = 2*(laserCircumRadius/mmInc);           % mm, ya redondeado

% ---------------- lista de radios ----------------------------------------
if R_ext - R_int < laserStepWidth/2
    radios = R_ext;                                % círculo sencillo
else
    radios = R_int:laserStepWidth:R_ext;           % anillo relleno
end
radios = round(radios*mmInc)/mmInc;                % a incrementos enteros
N = numel(radios);

% ---------------- número de secantes (según el radio mayor) --------------
secantNum = p.secantNum;
tSec = ceil(secantLen(max(radios), angleArc, secantNum)/p.motorSpeed);
if tSec > p.t_max
    secantNum = secantNumFromLen(max(radios), angleArc, p.motorSpeed*p.t_max);
end

% ---------------- renglón del paso radial --------------------------------
stepVec = [p.axis_X, p.axis_Y, ceil(laserStepWidth/p.motorSpeed), 0, 1, ...
           laserCircumRadius, -p.angleStart, 180, 1, 1];
stepChar = vec2char(stepVec);

% ---------------- partir en lotes de <= 2000 renglones -------------------
circPorLote = floor(p.maxTableEntries/(secantNum+1));
if circPorLote < 1
    error('anilloMov: secantNum=%d no cabe en la tabla del PS35.', secantNum);
end

i = 1;
while i <= N
    iFin = min(N, i + circPorLote - 1);
    idx = 0;
    chk(calllib('ps35','PS35_ClearVectorTab', 1, 0, p.maxTableEntries-1), 'ClearVectorTab');

    for k = i:iFin
        if k > 1                                   % paso hacia afuera
            chk(calllib('ps35','PS35_CircleToVectorTab', 1, idx, stepChar), 'CircleToVectorTab (paso)');
            idx = idx + 1;
        end
        R = radios(k);
        tSec = ceil(secantLen(R, angleArc, secantNum)/p.motorSpeed);
        cVec = [p.axis_X, p.axis_Y, tSec, 0, secantNum, round(R*mmInc), ...
                p.angleStart, angleArc, 1, 1];
        chk(calllib('ps35','PS35_CircleToVectorTab', 1, idx, vec2char(cVec)), 'CircleToVectorTab (círculo)');
        idx = idx + secantNum;
    end

    % --- ejecutar el lote con el láser encendido ---
    DAQstate(true);
    chk(calllib('ps35','PS35_GoVectorTab', 1, 0, idx-1), 'GoVectorTab');
    pause(0.1);                                    % dar tiempo a que arranque
    while calllib('ps35','PS35_GetMoveState', 1, p.axis_X) > 0 || ...
          calllib('ps35','PS35_GetMoveState', 1, p.axis_Y) > 0
        pause(0.05);
    end
    DAQstate(false);

    i = iFin + 1;
end

calllib('ps35','PS35_StopVectorTab', 1);
R_final = radios(end);
end

% =========================================================================
function chk(ret, nombre)
% El PS35 regresa 0 si todo salió bien.
if ret ~= 0
    warning('PS35_%s regresó %d (posible error de conexión/parámetros).', nombre, ret);
end
end

function L = secantLen(R, angleArc, n)
L = abs(2*R*sind(angleArc/(2*n)));       % manual PS35, pág. 13
end

function n = secantNumFromLen(R, angleArc, L)
n = ceil(angleArc/(2*asind(min(1, L/(2*R)))));
end

function s = vec2char(v)
if norm(round(v) - v) > 1e-9
    error('anilloMov: valores no enteros en la tabla: %s', mat2str(v));
end
s = char(strjoin(string(round(v)), ','));
end
