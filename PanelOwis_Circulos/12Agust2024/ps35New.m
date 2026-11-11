function val = ps35New(in1,in2, in3, in4, in5,in6,in7, in8)
%ps35tool This is a demo application for the PS 35 controller.
%   retval = ps35tool( COM_port, axis_no, velocity, distance ) moves the attached axis...
%   function parameters 
%   parameter 1 - COM port
%   parameter 2 - axis number
%   parameter 3 - positioning velocity in Hz
%   parameter 4 - distance for positioning in mm, distance=0 - reference run
%   parameter 5 - mode for data export: 0 - nothing to do, 1 - save, 2 - load

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


if ischar(in3) == 0
	dPosF=int32(in3);
else
    dPosF=str2double(in3);
end
 
% open virtual serial interface (or serial interface via tcp/ip socket)
if(nComPort==0)  % find first connected control unit
	calllib('ps35','PS35_SimpleConnect', 1, '');
end
if(nComPort==-1) % find the first connected control unit via tcp/ip socket (localhost, port=1200)
	calllib('ps35','PS35_SimpleConnect', 1, 'net');
else % connect control unit with defined COM port
	calllib('ps35','PS35_Connect', 1, 0, nComPort, 230400, 0, 0, 0, 0);
end

% initialize axis
calllib('ps35','PS35_MotorInit', 1, 1);
calllib('ps35','PS35_MotorInit', 1, 2);

% set target mode (0 - relative)
calllib('ps35','PS35_SetTargetMode', 1, 1, 0);
calllib('ps35','PS35_SetTargetMode', 1, 2, 0);

% set velocity 
if(dPosF>0.0)
	calllib('ps35','PS35_SetPosF', 1, 1, dPosF);
    calllib('ps35','PS35_SetPosF', 1, 2, dPosF);
    %calllib('ps35','PS35_MultiGoTarget', 1, 2, 1);antesCuendo no
    %funcionaba
    

end

DAQstate(true);

disp = 0;
e1 = 0;
e2 = 0;

if in8 == 1
    disp1 = in7;
    disp2 = in6;
    e1 = 2;
    e2 = 1;

else
    disp1 = in6;
    disp2 = in7;
    e1 = 1;
    e2 = 2;
end


                                          % Loop for ablate an individual figure 
     for i = 0 : disp1/(2*in4)
                
                
                while calllib('ps35','PS35_GetMoveState',1 , e2) > 0
                end
       
                
                calllib('ps35', 'PS35_MoveEx',1, e1, disp2/1000,  1);
                
                
                 while calllib('ps35','PS35_GetMoveState', 1, e1) > 0
                 end
                

                 calllib('ps35', 'PS35_MoveEx',1, e2, in4/1000,  1);
         
                 
                 while calllib('ps35','PS35_GetMoveState', 1, e2) > 0
                 end
                
                    calllib('ps35', 'PS35_MoveEx',1, e1, -disp2/1000,  1);
                     
                 
                while calllib('ps35','PS35_GetMoveState', 1, e1) > 0
                end
                
                if i + 1 < disp1/(2*in4)

                calllib('ps35', 'PS35_MoveEx',1, e2, in4/1000,  1);

                end
                

     end             

DAQstate(false);

end