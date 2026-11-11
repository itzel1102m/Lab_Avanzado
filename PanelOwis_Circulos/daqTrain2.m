function daqTrain2(freqRR,wp)
d = daq("ni");
n=10;
ch1 = addoutput(d,"Dev3", "ctr0" ,"PulseGeneration");
ch1.Frequency = freqRR;
ch1.DutyCycle = wp;
%addtrigger(d,"Digital","StartTrigger","External","Dev3/PFI0")
%addtrigger(d,"Digital","StartTrigger","Dev3/PFI0");
%for i=1:1:n
  %  if freqRR > 0
   % pause(0.08);
    %start(d, 'Duration', seconds(1))
    start(d,"Continuous")
    %end
%end
end
