function grating = genGrating_trainer(stimulus,win)
% make static grating in a circle
% inspired by Psychtoolbox-3, DriftDemos2.m
% http://psychtoolbox.org/

spotRadius = stimulus.Vstim_size/2; 

% colors 
black = BlackIndex(win);
white = WhiteIndex(win);
gray = (white+black)/2;
inc=white-gray;

% Calculate parameters of the grating:
if isfield(stimulus, 'Vstim_spatialFreq') && ~isempty(stimulus.Vstim_spatialFreq)
    f = stimulus.Vstim_spatialFreq; % cycle per pixel
else
    f = 0.005; % cycle per pixel. this default works well for mouse visual system
end

fr=f*2*pi;
[x,y]=meshgrid(-spotRadius:spotRadius, -spotRadius:spotRadius);
grating=gray + inc*cos(fr*x);
circle = white * (x.^2 + y.^2 <= (spotRadius)^2);
grating(:,:,2) = 0;
grating(1:2*spotRadius+1, 1:2*spotRadius+1, 2) = circle;
