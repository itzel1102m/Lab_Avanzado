function TrazarCirculos(res, grupos, escala, rellenarAnillos)
% TRAZARCIRCULOS  Traza con el láser los círculos que detectó RingDetection.
%
%   [res, grupos] = RingDetection('imagen.png');
%   TrazarCirculos(res, grupos, 1e-3, true)
%
% Entradas:
%   res, grupos     : salidas de RingDetection (res{i} = [cy cx r] en píxeles)
%   escala          : mm por píxel. Por defecto 1e-3 (1 px = 1 um, igual que
%                     generalMov, que divide las coordenadas entre 1000).
%   rellenarAnillos : true  -> un grupo concéntrico se rellena entre el radio
%                              menor y el mayor (anillo sólido)
%                     false -> cada círculo se traza por separado (solo línea)
%                     Un círculo solo siempre se traza como una línea.
%
% Origen: la posición del láser al empezar corresponde al píxel (0,0) de la
% imagen (esquina superior izquierda), como en generalMov. Al terminar, el
% láser regresa a ese origen.

if nargin < 3 || isempty(escala), escala = 1e-3; end
if nargin < 4, rellenarAnillos = true; end

% ----------------------------------------------------------------
% Parámetros (los mismos de circulo_while)
% ----------------------------------------------------------------
miliseconds = 1;   seconds = 1000*miliseconds;
milimeters  = 1;   micrometers = 1e-3*milimeters;

p.t_max               = 1.6*seconds;            % tiempo máximo por secante
p.mm2incrementsFactor = 10000*milimeters;
p.maxTableEntries     = 2000;
p.nComPort            = 3;
p.axis_X              = 1;
p.axis_Y              = 2;
p.targetMode          = 0;                      % 0 = relativo
p.secantNum           = 100;
p.motorSpeed          = 0.2*micrometers/miliseconds;
p.angleStart          = 90;
p.angleArc            = 360;
p.laserStepWidth      = 0.7*micrometers;
p.signoY              = 1;   % cambia a -1 si el dibujo sale reflejado en Y

% ----------------------------------------------------------------
% Lista de trabajos en mm: [Xc Yc R_int R_ext]
% ----------------------------------------------------------------
trabajos = zeros(0,4);
for j = 1:numel(grupos)
    c  = cell2mat(res(grupos{j})');               % filas [cy cx r] (px)
    Xc = mean(c(:,2))*escala;
    Yc = mean(c(:,1))*escala*p.signoY;
    r  = c(:,3)*escala;
    if rellenarAnillos || numel(r) == 1
        trabajos(end+1,:) = [Xc Yc min(r) max(r)]; %#ok<AGROW>
    else
        for k = 1:numel(r)
            trabajos(end+1,:) = [Xc Yc r(k) r(k)]; %#ok<AGROW>
        end
    end
end
fprintf('%d figura(s) por trazar.\n', size(trabajos,1));

% ----------------------------------------------------------------
% Conexión e inicialización (igual que circulo_while)
% ----------------------------------------------------------------
DAQstate(0)
if ~libisloaded('ps35'), loadlibrary('ps35','ps35.h'); end
nCom = int32(p.nComPort);
if nCom == 0
    calllib('ps35','PS35_SimpleConnect',1,'');
elseif nCom == -1
    calllib('ps35','PS35_SimpleConnect',1,'net');
else
    calllib('ps35','PS35_Connect',1,0,nCom,9600,0,0,0,0);
end
for ax = [p.axis_X p.axis_Y]
    calllib('ps35','PS35_MotorInit',1,ax);
    calllib('ps35','PS35_SetTargetMode',1,ax,p.targetMode);
    calllib('ps35','PS35_SetPosFEx',1,ax,p.motorSpeed/micrometers);
end

% ----------------------------------------------------------------
% Trazar cada figura
% ----------------------------------------------------------------
pos = [0 0];                                       % posición actual [X Y] mm
try
    for t = 1:size(trabajos,1)
        Xc = trabajos(t,1);  Yc = trabajos(t,2);
        R_int = trabajos(t,3);  R_ext = trabajos(t,4);
        R_int = round(R_int*p.mm2incrementsFactor)/p.mm2incrementsFactor;

        % 1) Ir (láser apagado) al punto de inicio del círculo interior
        inicio = [Xc + R_int*cosd(p.angleStart), Yc + R_int*sind(p.angleStart)];
        moverRel(inicio - pos, p);

        % 2) Trazar el círculo / anillo
        fprintf('Figura %d: centro (%.4f, %.4f) mm, R = %.4f a %.4f mm\n', ...
                t, Xc, Yc, R_int, R_ext);
        R_fin = circulo_while_fn(R_int, R_ext, p);

        % 3) Actualizar dónde quedó el láser
        pos = [Xc + R_fin*cosd(p.angleStart), Yc + R_fin*sind(p.angleStart)];
    end

    % Regresar al origen
    moverRel(-pos, p);
catch ME
    DAQstate(0)                                    % apagar el láser si algo falla
    desconectar();
    rethrow(ME)
end

desconectar();
disp('¡Listo!');
end

% ====================== Funciones auxiliares ======================
function moverRel(d, p)
% Movimiento relativo con el láser apagado: primero X, luego Y (mm)
    DAQstate(0)
    ejes = [p.axis_X p.axis_Y];
    for k = 1:2
        if abs(d(k)) > 1e-7
            calllib('ps35','PS35_MoveEx',1,ejes(k),d(k),1);
            while calllib('ps35','PS35_GetMoveState',1,ejes(k)) > 0
                pause(0.05)
            end
        end
    end
end

function desconectar()
    disp("Disconnecting ...");
    calllib('ps35','PS35_StopVectorTab',1);
    calllib('ps35','PS35_Disconnect',1);
    unloadlibrary ps35
    disp("Disconnected :^)");
end
