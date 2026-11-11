function twotr = twotr(A,f,sampleRate, type, duration)
numSamplesPerCycle = floor(sampleRate/f);
T = 1/f;
timestep = T/numSamplesPerCycle;
t = (0 : timestep : T-timestep)';

m=1; %intero mayor o igual a 1
n=1; %intero mayor o igual a 1
Frequency1 = f;
Frequency2 = f;

y1 = A*square(2*pi*Frequency1*t,99);
y2 = A*square(2*pi*Frequency2*t+2*pi/4,99);
all2y = y1 + y2;

% figure(1)
% plot(t, y1)
% figure(2)
% plot(t, y2)



if type == "bipolar"
    y = all2y;
elseif type == "unipolar"
    y = all2y + A;
end 

% figure
% plot(t,y)
numCycles = round(A*f*duration);
twotr = repmat(y,numCycles,1);
end