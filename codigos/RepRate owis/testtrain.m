d = daqlist;
s = daq('ni');
Fs = s.Rate; % set rate if you need to acquire data
 % s.DurationInSeconds = 100; % video duration in seconds
 % duration = s.DurationInSeconds; % set duration
ch1 = addoutput(s,'Dev3','ctr0','PulseGeneration'); % valve trigger
ch1.Frequency = 50; % this is going to be the valve activation freq (you can set it to 1 if you want 1 pulse only)
ch1.DutyCycle = 0.1; % default value 0.1, amount of time the pulse stays active (from 0 to 1) 
ch1.Terminal % it tells you which ports are being used just to make sure you are connecting the cables right)