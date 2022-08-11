
function y = genSweep(dur, freqlims, sweepdir, Fs)
% y = genSweep(dur, freqlims, sweepdir, Fs)
% dur is duration in seconds
% freqlims are bottom and top of sweep 
% sweepdir is the direction, 1 = up, 0 = down
% Fs is sampling rate in samples per sec 

%% Generate single FM sweep
flo = freqlims(1);      % Hz - frequency at end of ramp up
fhi = freqlims(2);     % Hz - frequency at start of ramp down
sweepLen = floor(dur*Fs);
stimeSweep = (0:(sweepLen-1))/Fs;

beta = log(fhi/flo)/dur;
corrPhase0 = rem(2*pi*flo/beta, 2*pi);
omegaSweep_t = (2*pi*flo)/beta*exp(beta*stimeSweep) - corrPhase0;
y = sin(omegaSweep_t);
if ~sweepdir
  y = fliplr(y);
end