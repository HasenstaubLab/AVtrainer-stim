
function y = genSinTone(dur, freq, Fs)
%y = genSinTone(dur, freq, Fs)
% one-liner to generate pure tones for AVtrainer 
% dur is duration in sec
% freq is frequency in Hz
% Fs is sampling frequency in samples per second

y = sin(linspace(0, dur*freq*2*pi, round(dur*Fs)));






