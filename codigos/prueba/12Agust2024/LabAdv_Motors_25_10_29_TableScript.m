%
% Requires the angle variable % circuit_AngleDeg
%

N_traces =  ceil(lineWidth/(dStep_Dist*cosd(dStep_AngleDeg))); % Must be so to mathch the desired width
if mod(N_traces,2)==1, N_traces= N_traces+1; end 

s_Length = circuit_Height*sind(circuit_AngleDeg)/(1-cosd(circuit_AngleDeg));
circuit_tailLength = (circuit_Length-s_Length)/2; 
circuit_tailLength = ceil(circuit_tailLength*mm2incrementsFactor)/mm2incrementsFactor;

t_tail = circuit_tailLength/motorSpeed;
PS35_max_Secant_Time = 1.638 * seconds; % See documentation of PS35_CircleToVector
N_L = ceil(t_tail/PS35_max_Secant_Time);

% --------------- ------------
% Motor Movement  --- Beta ---
% --------------- ------------
%
% Encode the circle data:
%
% Constants -------
circumRadius = circuit_Height / ( 2*(1-cosd(circuit_AngleDeg)) ); % In mm, See proof
circumRadius = ceil( circumRadius*mm2incrementsFactor ) /mm2incrementsFactor; % In increments
angleStart = 90;    % In degs
angleArc = abs( circuit_AngleDeg ); % In degs
secantNum = ceil( circuit_AngleDeg *(circuit_secantsPer90deg/90) ); % In int
secantLenght =  abs( 2*circumRadius*sind(0.5*angleArc/secantNum) ); % In increments, see manual
timePerSecant = ceil( (secantLenght / motorSpeed) ); % In miliseconds


% Circle Data ----
% 1/2 #1 Circle - IV - Up
circleData_IV_Up_vec = [
        axis_X,...          %  1 - axis X
        axis_Y, ...         %  2 - axis Y
        timePerSecant,...   %  3 - time interval of segments in ms
        0, ...              %  4 - function code (16 bits – bit pattern)
        secantNum,...       %  5 - secant number
        circumRadius*mm2incrementsFactor, ...   %  6 - circumradius with sign (values in increments)
        angleStart,...      %  7 - start angle in degrees with sign     
        angleArc,...        %  8 - angle range in degrees with sign
        1,...               %  9 - optional: scaling factor Z (numerator) with sign
        1                   % 10 - optional: scaling factor N (denominator) with sign
        ];
% 1/2 #2 Circle - II - Up
circleData_II_Up_vec = circleData_IV_Up_vec;
circleData_II_Up_vec(8) = (-1)*circleData_IV_Up_vec(8); % angle range in degrees with sign
circleData_II_Up_vec(7) = -90+angleArc;

% 1/2 ·3 Circle - II - Down
circleData_II_Dw_vec = circleData_IV_Up_vec;
circleData_II_Dw_vec(7) = circleData_IV_Up_vec(7)+180;

% 1/2 #4 Circle - IV - Down
circleData_IV_Dw_vec = circleData_IV_Up_vec;
circleData_IV_Dw_vec(8) = (-1)*circleData_IV_Up_vec(8);
circleData_IV_Dw_vec(7) = 90+angleArc;

%
% Encode Downward Steps % GUI - MISSING
%
St_DR_Circumradius_InInc = ceil(0.5*dStep_Dist*mm2incrementsFactor);
St_DR_Time = ceil(dStep_Dist/motorSpeed);
circleData_St_DR_vec = [
        axis_X,...          %  1 - axis X
        axis_Y, ...         %  2 - axis Y
        secantNum*timePerSecant,...   %  3 - time interval of segments in ms
        0, ...              %  4 - function code (16 bits – bit pattern)
        1,...               %  5 - secant number
        St_DR_Circumradius_InInc, ... %  6 - circumradius with sign (values in increments)
        dStep_AngleDeg,...  %  7 - start angle in degrees with sign     
        180, ...            %  8 - angle range in degrees with sign
        1,...               %  9 - optional: scaling factor Z (numerator) with sign
        1                   % 10 - optional: scaling factor N (denominator) with sign
        ];


%
% Encode Side Steps % GUI - MISSING
%
St_RR_Circumradius_InInc = ceil(0.5*(circuit_tailLength/N_L)*mm2incrementsFactor);
circleData_St_RR_vec = [
        axis_X,...          %  1 - axis X
        axis_Y, ...         %  2 - axis Y
        PS35_max_Secant_Time,...    %  3 - time interval of segments in ms
        0, ...              %  4 - function code (16 bits – bit pattern)
        1,...               %  5 - secant number
        St_RR_Circumradius_InInc, ... %  6 - circumradius with sign (values in increments)
        0,...               %  7 - start angle in degrees with sign     
        180, ...            %  8 - angle range in degrees with sign
        1,...               %  9 - optional: scaling factor Z (numerator) with sign
        1                   % 10 - optional: scaling factor N (denominator) with sign
        ];

circleData_St_LL_vec = circleData_St_RR_vec;
circleData_St_LL_vec(7) = 180;

%
%
% To Char
%
circleData_IV_Up_char = char(vec2commas(circleData_IV_Up_vec));
circleData_II_Up_char = char(vec2commas(circleData_II_Up_vec));
circleData_II_Dw_char = char(vec2commas(circleData_II_Dw_vec));
circleData_IV_Dw_char = char(vec2commas(circleData_IV_Dw_vec));

circleData_St_DR_char = char(vec2commas(circleData_St_DR_vec));
circleData_St_RR_char = char(vec2commas(circleData_St_RR_vec));
circleData_St_LL_char = char(vec2commas(circleData_St_LL_vec));

%
% Functions
% 

function str = vec2commas(A)
    %VEC2COMMAS Convert numeric vector into comma-separated string
    %   Each number is formatted with up to 2 decimal places.
    
    % Preallocate cell array for formatted numbers
    parts = cell(1, numel(A));
    
    for i = 1:numel(A)
        if mod(A(i),1) == 0
            % Integer → no decimals
            parts{i} = sprintf('%d', A(i));
        else
            % Decimal → up to 2 decimals
            parts{i} = sprintf('%.2f', A(i));
            % Remove trailing zeros and possible trailing decimal point
            parts{i} = regexprep(parts{i}, '0+$', '');
            parts{i} = regexprep(parts{i}, '\.$', '');
        end
    end
    
    % Join with commas
    str = strjoin(parts, ',');
end