
function y = genNoise(dur, freqband, Fs)
%y = genNoise(dur, freqband, Fs)
% dur is duration in sec
% freqband is frequency of passband [f_lo, f_hi] in Hz. Leave empty for
% full spectrum
% Fs is sampling frequency in samples per second

y = rand(1, round(dur*Fs))*2-1; % scaled random numbers

if ~isempty(freqband) % bandpass noise
    if numel(freqband) ~= 2
        error('genAudio: genWhiteNoise_trainer: for bandpassed noise, freqband must be a 2-element vector');
    end

    Wn(1) = freqband(1)/(0.5*Fs); 
    Wn(2) = freqband(2)/(0.5*Fs); 
    n = 1000; 
    b = fir1(n, Wn, 'bandpass');
    y = filtfilt(b,1,y);
    
end
