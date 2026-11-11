function val = repRate(in1,in2, in3, in4, in5,in6,in7,in8)

 loadlibrary('ps35')

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
f=in8;

dY=in6/1000;
dX=in7/1000;

velR=in3*10;

if ischar(in3) == 0
	dPosF=int32(in3);
else
    dPosF=str2double(velR);
end

if ischar(in5) == 0
	nExport=int32(in5);
else
    nExport=int32(str2double(in5));
end 

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


calllib('ps35','PS35_SetTargetMode', 1, 1, 0);
calllib('ps35','PS35_SetTargetMode', 1, 2, 0);

% set velocity 
if(dPosF>0.0)
	calllib('ps35','PS35_SetPosF', 1, 1, dPosF);
    calllib('ps35','PS35_SetPosF', 1, 2, dPosF);
end

% if(d==0.0) % go home (to start position)
% 	calllib('ps35','PS35_GoRef', 1, 2, 4);
% else % move to target position (+ positive direction, - negative direction)


% Loop for ablate an individual figure 
d.Rate =2e+4;
amplitudePeakToPeak_ch1 = 4;
f = in8; % 10 Hz
duration = 10;


     for i=1:1:nh
                
                
                % while calllib('ps35','PS35_GetMoveState', 1, 1) > 0
                % end

                d = daq("ni");
                ch1 = addoutput(d,"Dev3","ao0","Voltage");
                ch1.Range = [-5  5];
                % d.Rate = 2.85714e+03;
                
                outputSignal = [];
                outputSignal(:,1) = 0.5+twotr(amplitudePeakToPeak_ch1/2,f,d.Rate, "bipolar", duration);
                preload(d,outputSignal);
                if i==1
                   outputSignal=4;
                else
                   start(d,"repeatoutput")
                end

                
                while calllib('ps35','PS35_GetMoveState', 1, 2) > 0
                  
                end
                                            
                calllib('ps35', 'PS35_MoveEx',1, 1, dX,  1);
                             
                while calllib('ps35','PS35_GetMoveState', 1, 1) > 0
                  
                end
                
                stop(d);              
                outputSignal=4;

                calllib('ps35', 'PS35_MoveEx',1, 1, -dX,  1);
         
               
                while calllib('ps35','PS35_GetMoveState', 1, 1) > 0
                 end
                 
          

                calllib('ps35', 'PS35_MoveEx',1, 2, dY,  1);
                     
                 
                while calllib('ps35','PS35_GetMoveState', 1, 2) > 0
                end
               

                % DAQstate(true);
                % 
                % 
                % calllib('ps35', 'PS35_MoveEx',1, 1, dX,  1);

                

     end             

     DAQstate(false);


val="end";

%close interface
calllib('ps35','PS35_MotorOff',1,2);
calllib('ps35','PS35_MotorOff',1,1);
calllib('ps35','PS35_Disconnect',1);

unloadlibrary ps35


end