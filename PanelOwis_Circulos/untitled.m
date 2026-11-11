d = daq("ni");
ch1 = addoutput(d,"Dev3", "ctr0" ,"PulseGeneration");
ch1.Frequency = 10;
ch1.DutyCycle = 0.5;
start(d, "continuous");
pause(2)
stop(d);