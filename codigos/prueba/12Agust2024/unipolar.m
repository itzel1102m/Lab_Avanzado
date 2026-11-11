function unipolar = unipolar(A,f,sampleRate, type, duration)
numSamplesPerCycle = floor(sampleRate/f);
T = 1/f;
timestep = T/numSamplesPerCycle;
t = (0 : timestep : T-timestep)';

u = 4;


figure(1)
plot(t, u)
 if type == "unipolar"
    uu = u;
 end 

figure
plot(t,uu)
numCycles = round(A*f*duration);
unipolar = repmat(uu,numCycles,1);
end