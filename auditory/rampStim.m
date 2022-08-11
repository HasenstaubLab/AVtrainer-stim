
function y = rampStim(y, rampLen, Fs)
% y = rampStim(y, rampLen, Fs)
% apply a ramp of length rampLen to auditory stimulus y
% Fs is sampling rate in samples per sec

rampLen = rampLen *2; % double this to get hanning win size 
hanwin = hanning(round(rampLen*Fs));
rampUp = hanwin(1:round(end/2));
rampDown = hanwin(round(end/2)+1:end);
% apply window
y(1:length(rampUp)) = (y(1:length(rampUp)).*rampUp')';
y(end-length(rampDown)+1:end) = (y(end-length(rampDown)+1:end).*rampDown')';