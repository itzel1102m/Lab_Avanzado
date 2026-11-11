function DAQstate(st)

% Initialize the Data Acquisition Toolbox
%s = daq('ni');
d = daq('ni');

% Add digital output lines
addoutput(d, "Dev2", "Port1/Line3", 'Digital');
%addoutput(s,"Dev3", "Port1/Line3", 'Digital');
if st == true
    outputData = false;     % Write '0' to the specified digital line
    write(d, outputData);
else 
   outputData = true;      % Write '1' to the specified digital line
    write(d, outputData); 
end