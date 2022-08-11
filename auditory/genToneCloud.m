
function y = genToneCloud(dur, freq, pipdur, Fs) 
% y = genToneCloud(dur, freq, Fs) 
% dur is the total duration of the stimulus
% freq is a 2-element vector of [upper lower] frequency bounds, in Hz
% Fs is the auditory sampling rate in samples per sec
% pipdur is the duration of each pip, e.g. pipdur = 0.050 for 50 ms pips 

if numel(freq)~= 2 
    error('Tone clouds require an upper and lower frequency'); 
end

lowFreq = freq(1); 
highFreq = freq(2); 

nrPips = floor(dur/pipdur); 
rampDur = 0.003; % 3ms of ramp up/down for each pip 

y = [];
for i = 1:nrPips
    currfreq = (rand(1)*(highFreq-lowFreq))+lowFreq; 
    freqSeq(i) = currfreq;
    currpip = genSinTone_trainer(pipdur, currfreq, Fs);
    currpip = rampStim(currpip, rampDur, Fs); 
    y = [y currpip];
end
