function CircleMov(res,COMp,vx,vy,ax,ay)

st = false;                         % Láser OFF
DAQstate(st);

milimeters = 1;
micrometers = 1e-3;

mm2incrementsFactor = 10000;    % Viene del codigo de las secantes

% Parametros
t_max = 1.6e3;                      % ms
maxTableEntries = 2000;

angleStart = 90;
angleArc = 360;

secantNum = 100;

% Velocidad de motores
motorSpeed = 0.2 * micrometers;

% Numero de figuras
N = length(res.centers);

% Centro de la imagen
alto = 1500;
ancho = 3000;

x0 = ancho/2;
y0 = alto/2;

% Inicialmente suponemos que el sistema OWIS esta colocado
% exactamente en el centro de la imagen.
currentX = 0;       % mm
currentY = 0;       % mm

% Separacion deseada entre trayectorias del relleno
laserStepWidth_um = 0.7;

for i = 1:N

    % Centro geometrico detectado en la imagen
    xPixel = res.centers(i,1);
    yPixel = res.centers(i,2);

    targetX = xPixel - x0;
    targetY = -(yPixel - y0);

    figura = string(res.type(i));
    outerRadius = res.outerRadii(i);

    fprintf('\nFigura %d: %s\n', i, figura);
    fprintf('Centro detectado: X = %.2f, Y = %.2f um\n', ...
        targetX, targetY);

    % Determinar el radio desde el que empieza la trayectoria
    if figura == "anillo"
        innerRadius = res.innerRadii(i);
        firstRadius = innerRadius;
    else
        firstRadius = outerRadius;  % Si es un circulo
    end

    % El motor inicia la circunferencia en su punto inferior??
    % Posicionar el motor en ese punto, no en el "centro"
    startX = targetX;
    startY = targetY - firstRadius;

    dispX = startX - currentX;
    dispY = startY - currentY;

    DAQstate(false);

    if abs(dispX) > 0
        ps35tool(COMp, ax, vx, dispX/1000, 0, false);
    end

    if abs(dispY) > 0
        ps35tool(COMp, ay, vy, dispY/1000, 0, false);
    end

    currentX = startX;
    currentY = startY;

if figura == "anillo"

    innerRadius = res.innerRadii(i);

    fprintf('Radio interior: %.2f um\n', innerRadius);
    fprintf('Radio exterior: %.2f um\n', outerRadius);

    [currentX, currentY] = drawRing( ...
        innerRadius, ...
        outerRadius, ...
        laserStepWidth_um, ...
        targetX, targetY, ...
        currentX, currentY, ...
        COMp, vx, vy, ax, ay, ...
        motorSpeed, ...
        angleStart, angleArc, ...
        secantNum, ...
        mm2incrementsFactor, ...
        t_max, maxTableEntries);

else

    drawCircle( ...
        outerRadius, ...
        ax, ay, ...
        motorSpeed, ...
        angleStart, angleArc, ...
        secantNum, ...
        mm2incrementsFactor, ...
        t_max, maxTableEntries);

    currentX = targetX;
    currentY = targetY - outerRadius;

end

    DAQstate(false);

end




fprintf('\n====================================\n');
fprintf('Ablacion terminada.\n');
fprintf('====================================\n');


end

%Funcion que dibuja anillos
function [currentX, currentY] = drawRing( ...
    innerRadius_um, outerRadius_um, laserStepWidth_um, ...
    targetX, targetY, currentX, currentY, ...
    COMp, vx, vy, axis_X, axis_Y, ...
    motorSpeed, angleStart, angleArc, secantNum, ...
    mm2incrementsFactor, t_max, maxTableEntries)

    % Cuantizar el paso radial a la resolucion de la PS35
    um2mm = 1e-3;

    laserStepWidth_mm = laserStepWidth_um * um2mm;

    laserCircumRadius = ceil( ...
        (laserStepWidth_mm / 2) * mm2incrementsFactor);

    effectiveStep_mm = ...
        2 * laserCircumRadius / mm2incrementsFactor;

    effectiveStep_um = effectiveStep_mm / um2mm;

    % Generar array de radios de um
    radii_um = innerRadius_um:effectiveStep_um:outerRadius_um;

    % Garantizar que se dibuje tambien el radio exterior
    if isempty(radii_um)
        radii_um = outerRadius_um;
    elseif radii_um(end) < outerRadius_um - 1e-9
        radii_um(end+1) = outerRadius_um;
    end

    N_Circles = length(radii_um);

    fprintf('Circunferencias de relleno: %d\n', N_Circles);
    fprintf('Paso radial efectivo: %.3f um\n', effectiveStep_um);

    % Comprobar el numero de entradas por circunferencia.
    % drawCircle puede aumentar secantNum si necesita
    % cumplir el limite de tiempo t_max.
    if secantNum > maxTableEntries
        error('secantNum supera el limite de entradas de la tabla.');
    end

    % Ejecutar cada circunferencia por separado
    for k = 1:N_Circles

        R_um = radii_um(k);

        fprintf('Circunferencia %d/%d: R = %.3f um\n', ...
            k, N_Circles, R_um);

        % Punto inferior de esta circunferencia
        startX = targetX;
        startY = targetY - R_um;

        % Apagar el laser antes de reposicionar
        DAQstate(false);

        % Desplazamiento desde la posicion actual
        dispX = startX - currentX;
        dispY = startY - currentY;

        % solo es para ver si se necesitan mover los motores o no
        if abs(dispX) > 1e-9
            ps35tool(COMp, axis_X, vx, dispX/1000, 0, false);
        end

        if abs(dispY) > 1e-9
            ps35tool(COMp, axis_Y, vy, dispY/1000, 0, false);
        end

        % Registrar la posicion inicial de la trayectoria
        currentX = startX;
        currentY = startY;

        % Ejecutar una sola circunferencia.
        % La funcion carga la tabla desde el indice cero(supongo)
        drawCircle( ...
            R_um, ...
            axis_X, axis_Y, ...
            motorSpeed, ...
            angleStart, angleArc, ...
            secantNum, ...
            mm2incrementsFactor, ...
            t_max, maxTableEntries);

        % Apagar el laser antes de la siguiente trayectoria
        DAQstate(false);

        % Se supone que la circunferencia termina donde empieza.
        % Por eso currentX y currentY permanecen iguales.
    end

    % La ultima circunferencia es la exterior
    currentX = targetX;
    currentY = targetY - outerRadius_um;

end



% Funcion que dibuja circulos
function drawCircle( ...
    R_um, ...
    axis_X, ...
    axis_Y, ...
    motorSpeed, ...
    angleStart, ...
    angleArc, ...
    secantNum, ...
    mm2incrementsFactor, ...
    t_max, ...
    maxTableEntries)
% Convertir a mm
R = R_um * 1e-3;

% Longitud de secante. Viene del codigo de secantes
secantLength = PS35_getSecantLenght( ...
    R, ...
    angleArc, ...
    secantNum);

timePerSecant = ceil(secantLength/motorSpeed);

% Codigo de secantes. Evita que pase mucho tiempo en una secante y dibuje
% una recta
if timePerSecant > t_max

    newSecantLength = motorSpeed*t_max;

    secantNum = PS35_getSecantNum( ...
        R, ...
        angleArc, ...
        newSecantLength);

    % Recalcular
    secantLength = PS35_getSecantLenght( ...
        R, ...
        angleArc, ...
        secantNum);

    timePerSecant = ceil(secantLength/motorSpeed);

end

totalTableEntries = secantNum;

if totalTableEntries > maxTableEntries

    error(['Total vector table entries exceeds ', ...
        num2str(maxTableEntries)]);

end

circleData_vec = [ ...
    axis_X,...
    axis_Y,...
    timePerSecant,...
    0,...
    secantNum,...
    round(R*mm2incrementsFactor),...
    angleStart,...
    angleArc,...
    1,...
    1];

circleData_char = PS35_fromVec2Char(circleData_vec);


firstTableIndex = 0;

calllib( ...
    'ps35',...
    'PS35_CircleToVectorTab',...
    1,...
    firstTableIndex,...
    circleData_char);

% Enciende laser
DAQstate(true);

lastTableIndex = secantNum - 1;

calllib( ...
    'ps35',...
    'PS35_GoVectorTab',...
    1,...
    firstTableIndex,...
    lastTableIndex);

% Espera
while ...
        calllib('ps35','PS35_GetMoveState',1,axis_X) > 0 || ...
        calllib('ps35','PS35_GetMoveState',1,axis_Y) > 0

    pause(0.05);

end


calllib('ps35','PS35_StopVectorTab',1);


end

% Funciones
function secantLength = PS35_getSecantLenght(R,angleArc,secantNum)

secantLength = abs( ...
    2*R*sind(angleArc/(2*secantNum)));

end


function secantNum = PS35_getSecantNum(R,angleArc,secantLength)

LHS = asind(secantLength/(2*R));

secantNum = angleArc/(2*LHS);

secantNum = ceil(secantNum);

end


function charList = PS35_fromVec2Char(vecList)

diff = norm(round(vecList)-vecList);

if diff > 1e-12

    error('Error en la lista. Valores decimales encontrados');

end

vecRoundedList = round(vecList);

charList = char( ...
    strjoin(string(vecRoundedList),','));

end