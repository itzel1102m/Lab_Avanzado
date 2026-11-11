function daqTrain3(freqRR,wp)
d = daq("ni");
ch1 = addoutput(d,"Dev3", "ctr0" ,"PulseGeneration");
ch1.Frequency = freqRR;
ch1.DutyCycle = wp;
start(d, "Continuous");
%pause(0.1);
end

% addoutput(s, "Dev2", "Port1/Line3", 'Digital');
% if st == true
%     outputData = false;     % Write '0' to the specified digital line
%     write(s, outputData);
% else 
%    outputData = true;      % Write '1' to the specified digital line
%     write(s, outputData); 
% end