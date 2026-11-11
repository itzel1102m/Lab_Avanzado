% ----------------------------
%
% For both Circuit and Funnel
%
% ----------------------------

% Required variables
% circuit_AngleDeg
% table_Key

% Time management
PS35_max_Secant_Time = 1.638 * seconds; % See documentation of PS35_CircleToVector
PS35_max_Secant_Time = floor(PS35_max_Secant_Time*scale_Factor);


% ----------------------------
%
% Only Circuit
%
% ----------------------------
% if strcmp(table_Key, "Circuit_Upper_Branch") == 1 || strcmp(table_Key, "Circuit_Lower_Branch")
    
    % 
    % Angle Management
    angleStart = 90;    % In degs
    angleArc = abs( circuit_AngleDeg ); % In degs
    
    % 
    % Length Management
    s_Length = plate_Length/ 3;

    circuit_tailLength = (plate_Length-s_Length)/2; 
    circuit_tailLength = ceil(circuit_tailLength*mm2incrementsFactor)/mm2incrementsFactor;

    %
    % Radius Management
    % R2- R1 = 300, R2+R1=L/sin theta
    R1 = ( s_Length/sind(circuit_AngleDeg) - circuit_Spacing_Int ) / 2;
    R2 = ( s_Length/sind(circuit_AngleDeg) + circuit_Spacing_Int ) / 2;

    % 
    % Secant Num Management
    secantNum_1 = ceil( circuit_AngleDeg *(circuit_secantsPer90deg/90) ); % In int
    secantNum_2 = ceil(secantNum_1 * R2/R1); 

    % Round raidus
    R1 = ceil( R1 *mm2incrementsFactor )/mm2incrementsFactor;
    R2 = ceil( R2 *mm2incrementsFactor )/mm2incrementsFactor;

    % UPPER BRANCH
    if strcmp(table_Key, "Circuit_Upper_Branch") == 1
        circumRadius_L = R1;
        circumRadius_R = R2;
        secantNum_L = secantNum_1;
        secantNum_R = secantNum_2;
    else % strcmp(table_Key, "Circuit_Lower_Branch")
        circumRadius_L = R2;
        circumRadius_R = R1;
        secantNum_L = secantNum_2;
        secantNum_R = secantNum_1;
    end
    
    % 
    % Time Management
    circuit_tailTime = circuit_tailLength/motorSpeed;
    N_circuitTailTime = ceil(circuit_tailTime/PS35_max_Secant_Time);

    % Secant Management
    secantLenght_L =  abs( 2*circumRadius_L*sind(0.5*angleArc/secantNum_L) ); % In increments, see manual
    timePerSecant_L = ceil( (secantLenght_L / motorSpeed) ); % In miliseconds

    secantLenght_R =  abs( 2*circumRadius_R*sind(0.5*angleArc/secantNum_R) ); % In increments, see manual
    timePerSecant_R = ceil( (secantLenght_R / motorSpeed) ); % In miliseconds
    
% end

% ----------------------------
%
% Only Funnel
%
% ----------------------------
% if strcmp(table_Key, "Funnel_Upper_Branch") == 1 || strcmp(table_Key, "Funnel_Lower_Branch")
    funnel_Time = funnel_Length/motorSpeed;
    N_funnelTime = ceil(funnel_Time/PS35_max_Secant_Time);
% end   



% ----------------------------
%
% Only Circuit
%
% ----------------------------
%
% Encode the circle data:
%

% Circle Data ----
% 1/2 #1 Circle - IV - Up
circleData_IV_Up_vec = [
        axis_X,...          %  1 - axis X
        axis_Y, ...         %  2 - axis Y
        timePerSecant_L,... %  3 - time interval of segments in ms
        0, ...              %  4 - function code (16 bits – bit pattern)
        secantNum_L,...     %  5 - secant number
        circumRadius_L*mm2incrementsFactor, ...   %  6 - circumradius with sign (values in increments)
        angleStart,...      %  7 - start angle in degrees with sign     
        angleArc,...        %  8 - angle range in degrees with sign
        1,...               %  9 - optional: scaling factor Z (numerator) with sign
        1                   % 10 - optional: scaling factor N (denominator) with sign
        ];
% 1/2 #4 Circle - IV - Down
circleData_IV_Dw_vec = circleData_IV_Up_vec;
circleData_IV_Dw_vec(7) = 90+angleArc;
circleData_IV_Dw_vec(8) = (-1)*circleData_IV_Up_vec(8);


% 1/2 #2 Circle - II - Up
circleData_II_Up_vec = circleData_IV_Up_vec;
circleData_II_Up_vec(3) = timePerSecant_R;
circleData_II_Up_vec(5) = secantNum_R;
circleData_II_Up_vec(6) = circumRadius_R*mm2incrementsFactor;
circleData_II_Up_vec(7) = -90+angleArc;
circleData_II_Up_vec(8) = (-1)*circleData_IV_Up_vec(8); % angle range in degrees with sign

% 1/2 ·3 Circle - II - Down
circleData_II_Dw_vec = circleData_II_Up_vec;
circleData_II_Dw_vec(7) = circleData_IV_Up_vec(7)+180;
circleData_II_Dw_vec(8) = angleArc;


%
% Encode Downward Steps 
%
St_DR_Circumradius_InInc = ceil(0.5*dStep_Dist*mm2incrementsFactor);
St_DR_Time = ceil(dStep_Dist/motorSpeed);
circleData_dSt_DR_vec = [
        axis_X,...          %  1 - axis X
        axis_Y, ...         %  2 - axis Y
        St_DR_Time,...      %  3 - time interval of segments in ms
        0, ...              %  4 - function code (16 bits – bit pattern)
        1,...               %  5 - secant number
        St_DR_Circumradius_InInc, ... %  6 - circumradius with sign (values in increments)
        dStep_AngleDeg,...  %  7 - start angle in degrees with sign     
        180, ...            %  8 - angle range in degrees with sign
        1,...               %  9 - optional: scaling factor Z (numerator) with sign
        1                   % 10 - optional: scaling factor N (denominator) with sign
        ];

%
% Encode Straight Tail Steps
%
St_RR_Circumradius_InInc = ceil(0.5*(circuit_tailLength/N_circuitTailTime)*mm2incrementsFactor);
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
% To Char
%
circleData_IV_Up_char = char(vec2commas(circleData_IV_Up_vec));
circleData_II_Up_char = char(vec2commas(circleData_II_Up_vec));
circleData_II_Dw_char = char(vec2commas(circleData_II_Dw_vec));
circleData_IV_Dw_char = char(vec2commas(circleData_IV_Dw_vec));

circleData_dSt_DR_char = char(vec2commas(circleData_dSt_DR_vec));

circleData_St_RR_char = char(vec2commas(circleData_St_RR_vec));
circleData_St_LL_char = char(vec2commas(circleData_St_LL_vec));

% ----------------------------
%
% Funnel
%
% ----------------------------
%
% Encode Sideward Steps 
%
circleData_dStFun_UR_vec = circleData_dSt_DR_vec; 
circleData_dStFun_DR_vec = circleData_dSt_DR_vec;
circleData_dStFun_UR_vec(7) = 90 - funnel_Angle;
circleData_dStFun_DR_vec(7) = funnel_Angle - 90;


%
% Encode Straight Steps
%
circleData_StFun_UR_vec = circleData_St_RR_vec;
circleData_StFun_UL_vec = circleData_St_RR_vec;
circleData_StFun_DL_vec = circleData_St_RR_vec;
circleData_StFun_DR_vec = circleData_St_RR_vec;

circleData_StFun_UR_vec(7) = + funnel_Angle; 
circleData_StFun_UL_vec(7) = 180 - funnel_Angle;
circleData_StFun_DL_vec(7) = 180 + funnel_Angle;
circleData_StFun_DR_vec(7) = - funnel_Angle;

%
% To Char
%
circleData_dStFun_UR_char = char(vec2commas(circleData_dStFun_UR_vec));
circleData_dStFun_DR_char = char(vec2commas(circleData_dStFun_DR_vec));

circleData_StFun_UR_char = char(vec2commas(circleData_StFun_UR_vec));
circleData_StFun_UL_char = char(vec2commas(circleData_StFun_UL_vec));
circleData_StFun_DL_char = char(vec2commas(circleData_StFun_DL_vec));
circleData_StFun_DR_char = char(vec2commas(circleData_StFun_DR_vec));

if strcmp(table_Key, "Funnel_Upper_Branch") == 1
    circleData_StFun_OUTWARD_char = circleData_StFun_UL_char;
    circleData_StFun_INWARD_char  = circleData_StFun_DR_char;
    circleData_dStFun_SIDEWARD_char = circleData_dStFun_UR_char;
else 
    circleData_StFun_OUTWARD_char = circleData_StFun_DL_char;
    circleData_StFun_INWARD_char  = circleData_StFun_UR_char;
    circleData_dStFun_SIDEWARD_char = circleData_dStFun_DR_char;
end


% ----------------------
%
% Writing Circuit Data
%
% ----------------------
%
% Clear Table
%
disp("Clearing data ...");
lineIndx = 0;
N_TableLines =  N_traces*(secantNum_1+secantNum_2+1+2*N_circuitTailTime) - 1;
calllib('ps35','PS35_ClearVectorTab',1,lineIndx,N_TableLines);

%
% Movement for a single line
%
disp("Writting data ...");

if strcmp(table_Key, "Circuit_Upper_Branch") == 1 || strcmp(table_Key, "Circuit_Lower_Branch")

for i_trace = 1:N_traces
    % 
    % Circuit Traces
    %
    % % % % - - - Up Passsage - - - % % % % 
    if mod(i_trace,2) == 1  
        % Right Centering Step
        for i_t = 1:N_circuitTailTime
            calllib('ps35','PS35_CircleToVectorTab',1,lineIndx,circleData_St_RR_char);
            lineIndx = lineIndx + 1;
        end
        % 1/2 #1
        calllib('ps35','PS35_CircleToVectorTab',1,lineIndx,circleData_IV_Up_char);
        lineIndx = lineIndx + secantNum_L;
        % 1/2 #2
        calllib('ps35','PS35_CircleToVectorTab',1,lineIndx,circleData_II_Up_char);
        lineIndx = lineIndx + secantNum_R;

        % Right Extremal Step
        for i_t = 1:N_circuitTailTime
            calllib('ps35','PS35_CircleToVectorTab',1,lineIndx,circleData_St_RR_char);
            lineIndx = lineIndx + 1;
        end

    else 
    % % % % - - - Down Passsage - - - % % % % 
        % Left Centering Step 
        for i_t = 1:N_circuitTailTime
            calllib('ps35','PS35_CircleToVectorTab',1,lineIndx,circleData_St_LL_char);
            lineIndx = lineIndx + 1;
        end

        % 1/2 #3 
        calllib('ps35','PS35_CircleToVectorTab',1,lineIndx,circleData_II_Dw_char);
        lineIndx = lineIndx + secantNum_R;
        % 1/2 #4
        calllib('ps35','PS35_CircleToVectorTab',1,lineIndx,circleData_IV_Dw_char);
        lineIndx = lineIndx + secantNum_L;

        % Left Extremal Step
        for i_t = 1:N_circuitTailTime
            calllib('ps35','PS35_CircleToVectorTab',1,lineIndx,circleData_St_LL_char);
            lineIndx = lineIndx + 1;
        end
    end
    % 
    % Sideward Step
    %
    if i_trace < N_traces
        calllib('ps35','PS35_CircleToVectorTab',1,lineIndx,circleData_dSt_DR_char);
        lineIndx = lineIndx + 1;
    end

end
% trim lineIndx
lineIndx = lineIndx - 1;

end % table_Key

% ----------------------
%
% Writing Funnel Data
%
% ----------------------

if strcmp(table_Key, "Funnel_Upper_Branch") == 1 || strcmp(table_Key, "Funnel_Lower_Branch")

N_Funnel_Traces = ceil( funnel_Width / dStep_Dist );

disp("Clearing data ...");
lineIndx = 0;
N_TableLines =  N_Funnel_Traces*(N_funnelTime+1) - 1;
calllib('ps35','PS35_ClearVectorTab',1,lineIndx,N_TableLines); %%%%%%%%%% Do we need another 

% % EMBUDOS
disp("Preparing data ...");

% 
% Funnel Traces
%
disp("Writting data ...");

for i_Funnel = 1:N_Funnel_Traces
    % % % % - - - Outward Passage - - - % % % % 
    if mod(i_Funnel,2) == 1  
        % Right Extremal Step
        for i_t = 1:N_funnelTime
            calllib('ps35','PS35_CircleToVectorTab',1,lineIndx,circleData_StFun_OUTWARD_char);
            lineIndx = lineIndx + 1;
        end

    else 
    % % % % - - - Inward Passage - - - % % % % 
        % Left Centering Step 
        for i_t = 1:N_funnelTime
            calllib('ps35','PS35_CircleToVectorTab',1,lineIndx,circleData_StFun_INWARD_char);
            lineIndx = lineIndx + 1;
        end
    end
    % 
    % Sideward Step
    %
    if i_Funnel < N_Funnel_Traces
        calllib('ps35','PS35_CircleToVectorTab',1,lineIndx,circleData_dStFun_SIDEWARD_char); %%% CAREFUL
        lineIndx = lineIndx + 1;
    end
end % i_Funnel
% trim lineIndx
lineIndx = lineIndx - 1;


end % table_Key

% ----------------------
%
% Functions
%
% ----------------------

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