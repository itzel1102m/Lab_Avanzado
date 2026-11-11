function R_final = anilloMov(R_int, R_ext, p)
% ANILLOMOV  Traza un círculo (R_int == R_ext) o un anillo relleno
% (círculos concéntricos de R_int a R_ext separados por el paso del láser)
% con la interpolación circular del PS35 (PS35_CircleToVectorTab).
%
% Modo RELATIVO: la mesa debe estar en (cx, cy + R_int) al llamar
% (ángulo de arranque 90° = punto de ARRIBA del círculo). Termina en
% (cx, cy + R_final). circlesMov deja la mesa en ese punto.
%
% CAMBIOS 2026-11-04 (lentitud antes de cada figura):
%   1) Ya NO se llama PS35_ClearVectorTab(1,0,1999). Borraba 2000 renglones
%      por el puerto serie antes de cada figura y era la espera larga con
%      la mesa quieta. No hace falta: GoVectorTab solo ejecuta los
%      renglones 0..idx-1 que se acaban de escribir (el código del
%      compañero tampoco la usa). Si se quiere, p.limpiarTabla = true.
%   2) Lotes más chicos (p.circPorLote, por defecto 1 círculo). Antes se
%      escribían hasta 19 círculos (~1900 renglones) antes de mover nada.
%   3) La velocidad de los traslados (PosF) se guarda y se restaura al
%      final; antes quedaba en 0.2 mm/s y los traslados entre figuras
%      eran lentísimos.
%   4) p.laserOn = false para probar sin láser.
%   5) Imprime cuánto tarda cada fase (escribir tabla / ejecutar).
%
% Entradas (en mm): R_int, R_ext, p (struct; ver valores por defecto).

% ---------------- valores por defecto ------------------------------------
def.axis_X = 1;
def.axis_Y = 2;
def.motorSpeed = 0.2e-3;          % mm/ms (= 0.2 mm/s)
def.laserStepWidth = 0.7e-3;      % mm (0.7 um)
def.secantNum = 100;
def.angleStart = 90;
def.t_max = 1600;                 % ms por secante (límite PS35: 1638 ms)
def.mm2incrementsFactor = 10000;
def.maxTableEntries = 2000;
def.circPorLote = 1;              % círculos escritos antes de ejecutar
def.limpiarTabla = false;         % true -> ClearVectorTab (lento)
def.laserOn = true;               % false -> prueba sin láser
def.verbose = true;
if nargin < 3, p = struct(); end
f = fieldnames(def);
for k = 1:numel(f)
    if ~isfield(p, f{k}) || isempty(p.(f{k})), p.(f{k}) = def.(f{k}); end
end
if ~isfinite(p.laserStepWidth) || p.laserStepWidth <= 0
    error('anilloMov: laserStepWidth inválido (%g). ¿Se confirmó el Step-size con ENTER?', p.laserStepWidth);
end

angleArc = 360;
mmInc = p.mm2incrementsFactor;

% ---------------- guardar velocidad de traslado y fijar la de trazo -------
posF_X = calllib('ps35','PS35_GetPosF', 1, p.axis_X);
posF_Y = calllib('ps35','PS35_GetPosF', 1, p.axis_Y);
chk(calllib('ps35','PS35_SetTargetMode', 1, p.axis_X, 0), 'SetTargetMode X');
chk(calllib('ps35','PS35_SetTargetMode', 1, p.axis_Y, 0), 'SetTargetMode Y');
chk(calllib('ps35','PS35_SetPosFEx', 1, p.axis_X, p.motorSpeed/1e-3), 'SetPosFEx X');
chk(calllib('ps35','PS35_SetPosFEx', 1, p.axis_Y, p.motorSpeed/1e-3), 'SetPosFEx Y');

% ---------------- paso del láser (semicírculo de radio paso/2) -----------
laserCircumRadius = ceil((p.laserStepWidth/2)*mmInc);      % incrementos
laserStepWidth    = 2*(laserCircumRadius/mmInc);           % mm redondeado

% ---------------- lista de radios ----------------------------------------
if R_ext - R_int < laserStepWidth/2
    radios = R_ext;                                % círculo sencillo
else
    radios = R_int:laserStepWidth:R_ext;           % anillo relleno
end
radios = round(radios*mmInc)/mmInc;
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

% ---------------- tamaño de lote ------------------------------------------
maxPorLote = floor(p.maxTableEntries/(secantNum+1));
if maxPorLote < 1
    error('anilloMov: secantNum=%d no cabe en la tabla del PS35.', secantNum);
end
circPorLote = max(1, min(p.circPorLote, maxPorLote));

if p.verbose
    fprintf('  anilloMov: %d círculo(s), %d secantes c/u, lotes de %d.\n', N, secantNum, circPorLote);
end
tEscribir = 0;  tEjecutar = 0;

try
    i = 1;
    while i <= N
        iFin = min(N, i + circPorLote - 1);
        idx = 0;

        % --- escribir el lote ---
        t0 = tic;
        if p.limpiarTabla
            chk(calllib('ps35','PS35_ClearVectorTab', 1, 0, p.maxTableEntries-1), 'ClearVectorTab');
        end
        for k = i:iFin
            if k > 1                               % paso radial hacia afuera
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
        dtW = toc(t0);  tEscribir = tEscribir + dtW;

        % --- ejecutar el lote ---
        t0 = tic;
        if p.laserOn, DAQstate(true); end
        chk(calllib('ps35','PS35_GoVectorTab', 1, 0, idx-1), 'GoVectorTab');
        pause(0.1);                                % dar tiempo a que arranque
        while calllib('ps35','PS35_GetMoveState', 1, p.axis_X) > 0 || ...
              calllib('ps35','PS35_GetMoveState', 1, p.axis_Y) > 0
            pause(0.02);
        end
        if p.laserOn, DAQstate(false); end
        dtE = toc(t0);  tEjecutar = tEjecutar + dtE;

        if p.verbose && N > 1
            fprintf('    círculos %d-%d de %d: escribir %.1f s, ejecutar %.1f s\n', i, iFin, N, dtW, dtE);
        end
        i = iFin + 1;
    end
catch ME
    DAQstate(false);
    calllib('ps35','PS35_StopVectorTab', 1);
    restaurarPosF(p, posF_X, posF_Y);
    rethrow(ME);
end

calllib('ps35','PS35_StopVectorTab', 1);
restaurarPosF(p, posF_X, posF_Y);
R_final = radios(end);

if p.verbose
    fprintf('  anilloMov: escribir tabla %.1f s | ejecutar %.1f s\n', tEscribir, tEjecutar);
end
end

% =========================================================================
function restaurarPosF(p, fx, fy)
% Regresa la velocidad de traslado a la que tenía antes del trazo.
if fx > 0, calllib('ps35','PS35_SetPosF', 1, p.axis_X, fx); end
if fy > 0, calllib('ps35','PS35_SetPosF', 1, p.axis_Y, fy); end
end

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
