function generalMov(res,COMp,vx,vy,n,tr,ax,ay)

st = false; 
fig = length(res);                                                                  % Get the number of isolated figures in



% the design% State of laser false/off or true/on
DAQstate(st);                                                                       % Initialize Pharos
%vx = 1000;                                                                         % Set velocity in x axis um/s
%vy = 1000;
%COMp = 3;                                                                          % Set COM port for NI 6009
%n = 1;
%tr = 1;                                                                            % Step-size in micrometers
%ax = 1;
%ay = 2;


% stru = VertexDetection(figname);                                                  % Design to be ablated
% loadlibrary('ps35')                                                                 % Load the library for using the motors

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

j = 0;                                                                              % Initialization of usefull variables
jaux = 0;                                                                           % (auxiliary)
minX0 = 0;
minY0 = 0;
maxY0 = 0;
maxX0 = 0;
dispX = 0;
dispY = 0;


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%                                                     %%%
        %%%             Ablation algorithm selection            %%%
        %%%                                                     %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The value of n tells to the program which algorithm must this 
% execute, for instance, an n = 1 should execute ablation along 
% x direction, id est, laser will move along this direction. For
% n = 2 should do anything completely analogue but in the y direc-
% tion. Finally the n = 3 first ablates the contour of the figure
% and later its inner.


% switch n
%     case 1                                                                          % Move along x-axis              
        for i = 1 : fig 
            aux = res{i};
            maxX = max(aux(:, 2));                                                  % Maximum x-coordinate
            minX = min(aux(:, 2));                                                  % Minimum x-coordinate
            maxY = max(aux(:, 1));                                                  % Maximum y-coordinate
            minY = min(aux(:, 1));                                                  % Minimum y-coordinate

            %if mod(jaux,2) ~= 0
                
                
                %ps35tool(COMp, ax, vx, (minX - minX0)/1000, 0, st);                 % depending on previous position

                %calllib('ps35', 'PS35_MoveEx',1, ax, (minX - minX0)/1000,  1);


            % else 
            ps35tool(COMp, ax, vx, (minX - minX0)/1000, 0, st);
            % end
            %if i > 1
            %calllib('ps35','PS35_MoveEx', 1, ax, dDistance, 1);
            
            ps35tool(COMp, ay, vy, (minY - maxY0)/1000, 0, st);                        

            
            %end

            dispX = maxX - minX;
            dispY = maxY - minY;

            %nh = dispY/tr;
            hold on
            plot(res{i}(:,2),res{i}(:,1),'yo','MarkerFaceColor','g','MarkerSize',5);
            hold off;
            ps35New(COMp, ax, vx,tr ,0,dispY,dispX, n);
            
            if n == 1
                ps35tool(COMp, ax, vx, -dispX/1000, 0, st);
                ps35tool(COMp, ay, vy, dispY/1000, 0, st);
            end


            minX0 = minX;
            minY0 = minY;
            maxX0 = maxX;
            maxY0 = maxY;
         end
%     case 2                                                                          % Move along y-axis              
%         for i = 1 : fig 
%             aux = res{i};
%             maxX = max(aux(:, 2));                                                  % Maximum x-coordinate
%             minX = min(aux(:, 2));                                                  % Minimum x-coordinate
%             maxY = max(aux(:, 1));                                                  % Maximum y-coordinate
%             minY = min(aux(:, 1));                                                  % Minimum y-coordinate
% 
%             if mod(jaux,2) ~= 0
%                 ps35tool(COMp, ay, vy, (minY - minY0)/1000, 0, st);
%             else
%                 ps35tool(COMp, ay, vy, (minY - minY0 - dispY)/1000, 0, st);
%             end
%             ps35tool(COMp, ax, vx, (minX - maxX0)/1000, 0, st);
%             dispX = maxX - minX;
%             dispY = maxY - minY;
%             jaux = 1;
%             for j = 1: tr : dispX
%                 hold on
%                 plot(res{i}(:,2),res{i}(:,1),'yo','MarkerFaceColor','g','MarkerSize',5);
%                 hold off
%                 st = true;                                 
%                 ps35tool(COMp, ay, vy, ((-1)^(jaux + 1))*dispY/1000, 0, st);          % Moves ed um on x axis
%                 st = false;
%                 ps35tool(COMp, ax, vx, tr/1000, 0, st);                               % Moves ed um on y axis
%                 jaux = jaux + 1;
%             end
%             minX0 = minX;
%             minY0 = minY;
%             maxX0 = maxX;
%             maxY0 = maxY;
%         end
%     case 3                                                                              % Ablates contour first             
%         for i = 1 : fig 
%             aux = res{i};
%             maxX = max(aux(:, 2));                                                      % Maximum x-coordinate
%             minX = min(aux(:, 2));                                                      % Minimum x-coordinate
%             maxY = max(aux(:, 1));                                                      % Maximum y-coordinate
%             minY = min(aux(:, 1));                                                      % Minimum y-coordinate
% 
%             % if mod(jaux,2) ~= 0
%                 ps35tool(COMp, ax, vx, (minX - minX0)/1000, 0, st);
%             % else
%             %     ps35tool(COMp, ax, vx, (minX - minX0 - dispX)/1000, 0, st);
%             % end
%             ps35tool(COMp, ay, vy, (minY - maxY0)/1000, 0, st);
%             dispX = maxX - minX;
%             dispY = maxY - minY;
%             st = true;                                                              % Ablates the contour of figure 
%             ps35tool(COMp, ax, vx, dispX/1000, 0, st);
%             st = true;
%             ps35tool(COMp, ay, vy, dispY/1000, 0, st);
%             st = true;
%             ps35tool(COMp, ax, vx, -dispX/1000, 0, st);
%             st = true;
%             ps35tool(COMp, ay, vy, -dispY/1000, 0, st);
%             st = false;
%             ps35tool(COMp, ax, vx, 1/1000, 0, st);
%             ps35tool(COMp, ay, vy, 1/1000, 0, st);
%             jaux = 1;
%             for j = 1: tr : dispY - 2
%                 hold on
%                 plot(res{i}(:,2),res{i}(:,1),'yo','MarkerFaceColor','g','MarkerSize',5);
%                 hold off
%                 st = true;                                 
%                 ps35tool(COMp, ax, vx, ((-1)^(jaux + 1))*(dispX - 1)/1000, 0, st);        % Moves ed um on x axis
%                 st = false;
%                 ps35tool(COMp, ay, vy, tr/1000, 0, st);                               % Moves ed um on y axis
%                 jaux = jaux + 1;
%             end
%             minX0 = minX;
%             minY0 = minY;
%             maxX0 = maxX;
%             maxY0 = maxY;
%         end
% end


% calllib('ps35','PS35_Disconnect',1);
% unloadlibrary ps35

end
