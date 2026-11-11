clear all
close all
% clc

d = daq("ni");
ch1 = addoutput(d,"Dev3","ao0","Voltage");
ch1.Range = [-5  5];
%d.Rate = 2.85714e+06;
d.Rate = 2e+04;
amplitudePeakToPeak_ch1 = 4;

f = 10; % 10 Hz
duration = 1;


outputSignal = [];
outputSignal(:,1) = 0.5+twotr(amplitudePeakToPeak_ch1/2,f,d.Rate, "bipolar", duration);
preload(d,outputSignal);

tic

start(d,"repeatoutput")


% pause(5) % Adjust the duration of signal generation.
% stop(d)
% clear d ch1 outputSignal
toc