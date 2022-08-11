function grating = genSqGrating_trainer(stimulus,win)
% make a square grating
% inspired by Psychtoolbox-3, DriftDemos2.m
% see http://psychtoolbox.org/

width = stimulus.Vstim_size(1)/2; 
height = stimulus.Vstim_size(2)/2; 

% colors 
black = BlackIndex(win);
white = WhiteIndex(win);
gray = (white+black)/2;
inc=white-gray;

% Calculate parameters of the grating:
f = 0.005; % cycle per pixel
if isfield(stimulus, 'Vstim_spatialFreq') && ~isempty(stimulus.Vstim_spatialFreq)
    f = stimulus.Vstim_spatialFreq; % cycle per pixel
end
%p=ceil(1/f);  % pixels/cycle
fr=f*2*pi;
[x,y]=meshgrid(-width:width, -height:height);
grating=gray + inc*cos(fr*x);
square = white * (abs(x) <= abs(width) & abs(y) <= abs(height));
grating(:,:,2) = 0;
grating(1:2*width+1, 1:2*height+1, 2) = square;
