function [tex, PTparams] = retVis_trainer(stimulus,win)
% caller to generate a texture and any additional parameters
% requires Psychtoolbox-3: http://psychtoolbox.org/
% calls vis stim generation functions
% returns tex handle

if stimulus.Vstim
    switch stimulus.Vstim_type
        case 'grating'
            if isfield(stimulus, 'Vstim_dynamic') && stimulus.Vstim_dynamic % make a dynamic (drifting) grating
                tex = CreateProceduralSineGrating(win, stimulus.Vstim_size, stimulus.Vstim_size, [0.5 0.5 0.5 0], stimulus.Vstim_size/2);
                phase = 0;
                spatial_freq = 0.005;
                contrast = 0.5;
                PTparams = {phase spatial_freq contrast 0}; %
            else
                img = genGrating_trainer(stimulus,win);
                tex = Screen('MakeTexture', win, img);
                PTparams = {[]};
            end  
        case 'square grating' % displays grating with square boader
                img = genSqGrating_trainer(stimulus,win);
                tex = Screen('MakeTexture', win, img);
                PTparams = {[]};
        case 'flash'
            img = genFlash_trainer(stimulus,win);
            tex = Screen('MakeTexture', win, img);
            PTparams = {[]};
        case 'color' % turns screen a color determined by a 1x3 rgb vector stimulus.VstimColor.
                     % e.g. gray = stimulus(1).Vstim_color = [0.5 0.5 0.5]
            fprintf('stimulus will be a color using [%d %d %d]\n', stimulus.Vstim_color(1), stimulus.Vstim_color(2),stimulus.Vstim_color(3))
            tex = -1;
            PTparams = [];
        otherwise
            error('AVtrainerStim:retVis_trainer: could not find visual stimulus type %s, for acceptable inputs see genStimParams.m', stimulus.Vstim_type);
    end
    
else
    tex = -1;
    PTparams = [];
end




