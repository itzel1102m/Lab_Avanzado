function R_final = circulo_while_fn(R_int, R_ext, p)
% CIRCULO_WHILE_FN  Versión en función de la parte "CODE" de circulo_while.
% Rellena un anillo con círculos concéntricos desde R_int hasta R_ext (mm),
% separados por p.laserStepWidth, usando interpolación circular del PS35.
% Si R_int == R_ext traza un solo círculo.
%
% SUPONE (lo hace TrazarCirculos):
%   - librería ps35 cargada, conexión abierta, ejes inicializados,
%     modo relativo y velocidades ya puestas
%   - el láser (apagado) ya está en el punto de inicio: el punto del
%     círculo interior en el ángulo p.angleStart (90° -> en +Y del centro)
%
% Salida:
%   R_final = radio (mm) del último círculo trazado. El láser termina en el
%             ángulo p.angleStart de ese círculo.

if R_ext < R_int, [R_int, R_ext] = deal(R_ext, R_int); end

mm2inc    = p.mm2incrementsFactor;
secantNum = p.secantNum;          % se reinicia en cada figura

% --- Paso radial del láser (interpolación circular de media vuelta) ---
laserCircumRadius = ceil( (p.laserStepWidth/2)*mm2inc );
laserStepWidth    = 2*(laserCircumRadius/mm2inc);

% --- Lista de radios ---
circumRadium_List = R_int:laserStepWidth:R_ext;
N_Circles = length(circumRadium_List);

% --- secantNum máximo según t_max (con el radio exterior) ---
secantLength  = PS35_getSecantLenght(R_ext, p.angleArc, secantNum);
timePerSecant = ceil(secantLength / p.motorSpeed);
if timePerSecant > p.t_max
    newSecantLenght = p.motorSpeed * p.t_max;
    secantNum = PS35_getSecantNum(R_ext, p.angleArc, newSecantLenght);
    disp("secantNum cambiado a " + num2str(secantNum));
end

% --- Límite de la tabla del PS35 ---
totalTableEntries = N_Circles*(secantNum+1) - 1;
if totalTableEntries > p.maxTableEntries
    error("La tabla de vectores excede %d entradas: %d (R_int=%.4f mm, R_ext=%.4f mm)", ...
          p.maxTableEntries, totalTableEntries, R_int, R_ext);
end

% --- Parámetros base de la interpolación circular ---
circleData_Base_vec = [
    p.axis_X, ...      %  1 - eje X
    p.axis_Y, ...      %  2 - eje Y
    0, ...             %  3 - tiempo por secante en ms (se llena abajo)
    0, ...             %  4 - function code
    secantNum, ...     %  5 - número de secantes
    0, ...             %  6 - circunradio en incrementos (se llena abajo)
    p.angleStart, ...  %  7 - ángulo inicial
    p.angleArc, ...    %  8 - rango angular
    1, ...             %  9 - escala Z
    1                  % 10 - escala N
    ];

% --- Desplazamiento radial entre círculos (media vuelta pequeña) ---
laserDispData_vec    = circleData_Base_vec;
laserDispData_vec(3) = ceil(laserStepWidth/p.motorSpeed);
laserDispData_vec(5) = 1;
laserDispData_vec(6) = laserCircumRadius;
laserDispData_vec(7) = -p.angleStart;
laserDispData_vec(8) = 180;
laserDispData_char   = PS35_fromVec2Char(laserDispData_vec);

% --- Llenar la tabla ---
lastTableIndex = 0;
for i_Circles = 1:N_Circles
    R = circumRadium_List(i_Circles);
    circleData_vec    = circleData_Base_vec;
    secantLength      = PS35_getSecantLenght(R, p.angleArc, secantNum);
    circleData_vec(3) = ceil(secantLength / p.motorSpeed);
    circleData_vec(6) = round(R*mm2inc);
    calllib('ps35','PS35_CircleToVectorTab',1,lastTableIndex, ...
            PS35_fromVec2Char(circleData_vec));
    lastTableIndex = lastTableIndex + secantNum;
    if i_Circles < N_Circles
        calllib('ps35','PS35_CircleToVectorTab',1,lastTableIndex,laserDispData_char);
        lastTableIndex = lastTableIndex + 1;
    end
end
lastTableIndex = lastTableIndex - 1;

% --- Ejecutar ---
DAQstate(1)
calllib('ps35','PS35_GoVectorTab',1,0,lastTableIndex);
while calllib('ps35','PS35_GetMoveState',1,p.axis_X) > 0 || ...
      calllib('ps35','PS35_GetMoveState',1,p.axis_Y) > 0
    pause(0.05)
end
DAQstate(0)
calllib('ps35','PS35_StopVectorTab',1);   % salir del modo tabla antes de mover con MoveEx

% Radio real del último círculo (redondeado a incrementos, como en la tabla)
R_final = round(circumRadium_List(end)*mm2inc)/mm2inc;
end

% ====================== Funciones auxiliares ======================
function secantLength = PS35_getSecantLenght(R, angleArc, secantNum)
    % Manual PS35 pág. 13: secantLength = |2*R*sin(angleArc/2n)|
    secantLength = abs(2*R*sind(angleArc/(2*secantNum)));
end

function secantNum = PS35_getSecantNum(R, angleArc, secantLength)
    LHS = asind( secantLength/(2*R) );
    secantNum = ceil(angleArc/(2*LHS));
end

function charList = PS35_fromVec2Char(vecList)
    if norm(round(vecList) - vecList) > 1e-12
        error("Error en la lista. Valores decimales encontrados")
    end
    charList = char(strjoin(string(round(vecList)), ','));
end
