
d = daq("ni");
ch1 = addoutput(d,"Dev3", "ctr0" ,"PulseGeneration");
ch1.Frequency = 10;
ch1.DutyCycle = 0.1;
%start(d, 'Duration', seconds(10));

% addoutput(s, "Dev2", "Port1/Line3", 'Digital');
% if st == true
%     outputData = false;     % Write '0' to the specified digital line
%     write(s, outputData);
% else 
%    outputData = true;      % Write '1' to the specified digital line
%     write(s, outputData); 
% end