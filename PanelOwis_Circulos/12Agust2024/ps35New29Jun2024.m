function val = ps35New(in1,in2, in3, in4, in5,in6,in7)
%ps35tool This is a demo application for the PS 35 controller.
%   retval = ps35tool( COM_port, axis_no, velocity, distance ) moves the attached axis...
%   function parameters 
%   parameter 1 - COM port
%   parameter 2 - axis number
%   parameter 3 - positioning velocity in Hz
%   parameter 4 - distance for positioning in mm, distance=0 - reference run
%   parameter 5 - mode for data export: 0 - nothing to do, 1 - save, 2 - load

% nComPort=int32(6); 
% nAxis=int32(1);
% dPosF=30000.0;
% dDistance=10.0; 
% nExport=int32(0);

% if nargin ~= 6  
% 	fprintf(2, 'ps35tool(COM_port, axis_no, velocity, distance, params_export)\n');
% 	fprintf(2, 'e.g. ps35tool(7,1,30000,10,0)\n');
%     return;
% end



 loadlibrary('ps35')

% set parameters *************
if ischar(in1) == 0
	nComPort=int32(in1);
else
    nComPort=int32(str2double(in1));
end
if ischar(in2) == 0
	nAxis=int32(in2);
else
    nAxis=int32(str2double(in2));
end

nh=in4;


velR=in3*10;

if ischar(velR) == 0
	dPosF=int32(velR);
else
    dPosF=str2double(velR);
end
% if ischar(in4) == 0
% 	dDistance=in4;
% else
%     dDistance=str2double(in4);

if ischar(in5) == 0
	nExport=int32(in5);
else
    nExport=int32(str2double(in5));
end 
% ****************************

dispY=in6/1000;
dispX=in7/1000;
% loadlibrary('ps35')
 
% open virtual serial interface (or serial interface via tcp/ip socket)
if(nComPort==0)  % find first connected control unit
	calllib('ps35','PS35_SimpleConnect', 1, '');
end
if(nComPort==-1) % find the first connected control unit via tcp/ip socket (localhost, port=1200)
	calllib('ps35','PS35_SimpleConnect', 1, 'net');
else % connect control unit with defined COM port
	calllib('ps35','PS35_Connect', 1, 0, nComPort, 230400, 0, 0, 0, 0);
end

% define constants for calculation Inc -> mm
% calllib('ps35','PS35_SetStageAttributes', 1, nAxis, 1.0, 200, 1.0);

% load param file
if(nExport==2)
	calllib('ps35','PS35_LoadTextFile', 1, 1, 'ps35_params_export.txt');
    calllib('ps35','PS35_LoadTextFile', 1, 2, 'ps35_params_export.txt');
end

% initialize axis
calllib('ps35','PS35_MotorInit', 1, 1);
calllib('ps35','PS35_MotorInit', 1, 2);


% save param file
% if(nExport==1)
% 	calllib('ps35','PS35_LoadTextFile', 1, nAxis, 'ps35_params_export.txt');
% end


% set target mode (0 - relative)
calllib('ps35','PS35_SetTargetMode', 1, 1, 0);
calllib('ps35','PS35_SetTargetMode', 1, 2, 0);

% set velocity 
if(dPosF>0.0)
	calllib('ps35','PS35_SetPosF', 1, 1, dPosF);
    calllib('ps35','PS35_SetPosF', 1, 2, dPosF);
end

% check position
% % PositionA = calllib('ps35','PS35_GetPositionEx', 1, nAxis);
% % fprintf(1, 'Position=%.3f\n', PositionA);

% start positioning
DAQstate(true);
% Turn on laser

d=1;
%tr=0.7;


v=in3;

              dY=dispY;
              dX=dispX;
      

if(d==0.0) % go home (to start position)
	calllib('ps35','PS35_GoRef', 1, 2, 4);
else % move to target position (+ positive direction, - negative direction)

                                          % Loop for ablate an individual figure 
     for i=1:1:nh
                
                
                while calllib('ps35','PS35_GetMoveState', 1, 1) > 0
                end
                
                
                
                calllib('ps35', 'PS35_MoveEx',1, 2, dY,  1);
                
                tic
                 while calllib('ps35','PS35_GetMoveState', 1, 2) > 0
                 end
                toc

                  calllib('ps35', 'PS35_MoveEx',1, 1, dX,  1);
         
                 
                 while calllib('ps35','PS35_GetMoveState', 1, 1) > 0
                 end
                
                    calllib('ps35', 'PS35_MoveEx',1, 2, -dY,  1);
                     
                 
                while calllib('ps35','PS35_GetMoveState', 1, 2) > 0
                end
                
                calllib('ps35', 'PS35_MoveEx',1, 1, dX,  1);

     end             
end








% check move state of the axis
% % fprintf(1, 'Axis is moving...\n');
%end
% % fprintf(1, 'Axis is in position.\n');

% check position
% % PositionB = calllib('ps35','PS35_GetPositionEx', 1, nAxis);
% % fprintf(1, 'Position=%.3f\n', PositionB);
% % retval = PositionB;


% close interface

DAQstate(false);

val="end";

%close interface
calllib('ps35','PS35_MotorOff',1,1);
calllib('ps35','PS35_MotorOff',1,2);
calllib('ps35','PS35_Disconnect',1);

unloadlibrary ps35



end