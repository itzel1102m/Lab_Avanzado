function DAQstatesquare(st)
%Initialize the Data Acquisition Toolbox
s=daq('ni');
%Add digital output lines
ch1=addoutput(s,"Dev3","ctr0",'PulseGeneration');
ch1.Frequency=10;
ch1.DutyCycle=0.5;
if st==true
ch1=false;
write(s,ch1);
else
ch1=true;
write(s,ch1);
end