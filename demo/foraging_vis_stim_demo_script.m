% Example usage - visual stimulus display with moving inter-trial track dots
% 
% This script demos the loading of a stimulus file and the presentation of
% a sequence of visual decision stimuli using Psychtoolbox-3, 
% similar to approach used in Morrill et al. "Audiovisual task switching 
% rapidly modulates sound encoding in mouse auditory cortex." bioRxiv 
% https://doi.org/10.1101/2021.11.09.467944
%
% It could be used to build your own virtual foraging task, but it is
% intended solely as a demo and is provided with no guarantees. 
%
% Due to major differences in sound hardware for high-precision timing 
% and varied support of PsychPortAudio, (Psychtoolbox's audio engine), no 
% auditory stim are used here. 
% To get started on audio: 
% >> help PsychPortAudio
% 
% Description: 
% - loads a stimulus description file (provided in GitHub repo)
% - generates visual stimulus procedural graphics handles (drifting
% gratings)
% - presents track dots, followed by drifting gratings
% - repeats nrTrs times
% - to exit, hold [ESC]
%
% Requirements: 
% - Psychtoolbox-3: http://psychtoolbox.org/ (requires OpenGL support)
% - All contents of https://github.com/HasenstaubLab/AVtrainer-stim/ on
% MATLAB path 
%
% RJM 2022

close all; % close figs leftover from previous runs

% load a stimulus file (supplied in repo)
stimfile = load('AVtaskSwitch_Vert_8kHzTC_example.mat');
stim_to_use = [1,2]; % 1 and 2 are visual-only stim  
stimulus = stimfile.stimulus(stim_to_use);
nrStim = numel(stimulus);

% make a stimulus sequence vector - codes for decision stimuli to present
% normally this would be sent over from the behavior control machine
nrTrs = 10; % total number of trials 
stimVec = []; 
for i = 1:numel(stim_to_use)
    stimVec = [stimVec ones(1,round(nrTrs/nrStim))*stim_to_use(i)];
end
stimVec = stimVec(randperm(nrTrs)); % random sequence
stimVec = addTrackCodesToStimVec(stimVec); % intersperse zeros as 'track codes'

dotSz = stimfile.general.dotSz; % unpack size of track dots
stimHt = stimfile.general.stimHt; % decision stim height, value in pixels
halfStimHt = stimHt/2;

% set parameters related to the inter-trial track
trckLenNorm = 1000; % length of track, in pixels
maxTrackWidth = 600; % width of track, in pixels
trackDens = 300; % number of dots per screen

AssertOpenGL;
KbName('UnifyKeyNames');
escape = KbName('ESCAPE');
space = KbName('space');

Screen('Preference', 'VisualDebugLevel', 0);
% skip sync tests for demo purposes. ***do not include if using this in experiments***
Screen('Preference', 'SkipSyncTests', 1);

whichScreen = max(Screen('Screens'));

% get screen-specific color values
black = BlackIndex(whichScreen);
white = WhiteIndex(whichScreen);
gray = (white+black)/2;
inc=white-gray;

% Open a new window.
[window, windowRect ] = Screen('OpenWindow', whichScreen, gray);
AssertGLSL;
ifi = Screen('GetFlipInterval', window); % inter-flip interval

% Flip a gray screen for the wait period
Screen('Flip', window);

yBottom = windowRect(4);
yTop = windowRect(2);
xLeft = windowRect(1);
xRight = windowRect(3);
xMid = (xLeft + xRight)/2;
maxYOffset = yBottom+halfStimHt*2;
centerX = diff([xLeft xRight])/2;
initialY = yTop-halfStimHt;% completely offscreen

stimStartPosn = 50;

% set parameters for track
trckLens_all = ones(1,nrTrs)*trckLenNorm;
xPtsOffset = xMid-maxTrackWidth/2;
xPts_track = round(rand(1,trackDens)*maxTrackWidth+xPtsOffset);
yPts_track = round(rand(1,trackDens)*yBottom);

%%% visual stimulus setup
stimRect = zeros(nrStim, 4); % rects for stim drawing
tex = zeros(1,nrStim); 
PTparams = cell(1,nrStim); 
phase_inc = zeros(1,numel(stimulus)); % for dynamic gratings only

for i = 1:nrStim
    if stimulus(i).Vstim
        [tex(i), PTparams{i}] = retVis_trainer(stimulus(i), window);
        stimulus(i).isCircle = strcmp(stimulus(i).Vstim_type, 'grating');
        if isfield(stimulus, 'Vstim_cycles_perSec') && isfield(stimulus, 'Vstim_dynamic')
            if stimulus(i).Vstim_dynamic
                phase_inc(i) = stimulus(i).Vstim_cycles_perSec * 360 * ifi;
            end
        end

        % make the rects into which stim will be drawn
        if numel(stimulus(i).Vstim_size) == 1
            stimRect(i,:) = [0 0 stimulus(i).Vstim_size stimulus(i).Vstim_size];
        else
            stimRect(i,:) = [0 0 stimulus(i).Vstim_size(1) stimulus(i).Vstim_size(2)];
        end
        
        % set the nr of screen flips for each stimulus, according to monitor
        % inter-frame interval
        stimulus(i).Vstim_flips = round(stimulus(i).Vstim_dur/ifi); % number of screen flips to be on
    else % auditory only
        stimRect(i,:) = [0 0 0 0]; % dummy
        stimulus(i).Vstim_flips = 0;
        stimulus(i).isCircle = 0;
    end
end

% initialize variables that are used to keep track of task progress
yOffset = 0;
idx = 0;
currTr = 0;
preStim = 1;
stimPlaying = 0; 
stimIdx = 1;
percentOnScreen = 0;
currStim = stimVec(stimIdx);

WaitSecs(0.5);

%%% setup complete, begin stimulus presentation
disp('Starting session');
while 1
    %%% determine what track dots to draw
    disp(currStim)
    
    if currStim ~= 0 % in stimulus
        
        percentOnScreen = round(yOffset/maxYOffset*100); % amt of stim on screen
        
        if stimulus(currStim).Vstim
            centeredspotRect = CenterRectOnPoint(stimRect(currStim,:), centerX, initialY);
            offsetCenteredspotRect = OffsetRect(centeredspotRect, 0, yOffset);
            currY = mean([offsetCenteredspotRect(2), offsetCenteredspotRect(4)]);
            
            if stimulus(currStim).Vstim_track_behind || ~stimPlaying
                xPts_draw = xPts_track;
                yPts_draw = yPts_track;
            else
                % do not draw dots within the visual stimulus
                if stimulus(currStim).isCircle
                    drawthese = isNotInCircle(xPts_track, yPts_track, [xMid, currY], halfStimHt+5);
                else % is rectangular
                    drawthese = isNotInRect(xPts_track, yPts_track, [xMid, currY], stimulus(currStim).Vstim_size(1)+5, stimulus(currStim).Vstim_size(2)+5);
                end
                xPts_draw = xPts_track(drawthese);
                yPts_draw = yPts_track(drawthese);
            end
        else
            currY = initialY + yOffset;
            xPts_draw = xPts_track;
            yPts_draw = yPts_track;
        end
        
    else % in track
        percentOnScreen = 0; % amt of stimulus on screen
        xPts_draw = xPts_track;
        yPts_draw = yPts_track;
    end
    
    if ~isempty(xPts_draw)
        Screen('DrawDots', window, [xPts_draw; yPts_draw], dotSz, black, [], 1);
    end
    Screen('DrawingFinished', window);
    
    if currStim ~= 0
        if percentOnScreen >= stimStartPosn && preStim
            stimPlaying = 1;
            fdvIdx = 1;
            preStim = 0;
        end
        
        if ~preStim
            if fdvIdx<=stimulus(currStim).Vstim_flips
                angle = stimulus(currStim).Vstim_angle;
                visContrast = stimulus(currStim).Vstim_contrast;
                Screen('DrawTexture', window, tex(currStim), [], offsetCenteredspotRect, angle, ...
                    [], [], [255 255 255]*visContrast, [], [], [PTparams{currStim}{:}]);
                
                fdvIdx = fdvIdx+1;
                
                if isfield(stimulus, 'Vstim_dynamic') && stimulus(currStim).Vstim_dynamic && ~isempty(PTparams{currStim})
                    PTparams{currStim}{1} = PTparams{currStim}{1} + phase_inc(currStim);
                end
                stimPlaying = 1; 
            else
                stimPlaying = 0; 
            end
        end
    end
    
    idx = idx+1;
    Screen('Flip', window);
    
    % check to see if it's time to end (either keyboard or exit code)
    [~, ~, keyCode] = KbCheck(-1);
    if keyCode(escape)
        fprintf('ESC key recognized, stopping now\n');
        break;
    end
    
    % input your own movement measurements here, scale values appropriately
    step_y = 20;

    if ~stimPlaying
        
        if step_y == 0 % no movement detected, do not move screen
            continue
            
        elseif step_y > 0
            
            if currStim == 0 % track portion of task
                if yOffset > trckLens_all(currTr+1) % stop the track, go to the next stimulus
                    % advance the stimulus and the trial
                    yOffset = 0;
                    preStim = 1;
                    stimIdx = stimIdx + 1;
                    currTr = currTr + 1;
                    currStim = stimVec(stimIdx);
                else
                    yOffset = yOffset + step_y; % move track down
                end
                
            else % decision stim portion of task
                
                if yOffset - stimHt > yBottom % the stimulus has moved past bottom of screen, go to track
                    
                    yOffset = 0; % reset
                    
                    if currTr<nrTrs % are we still going?
                        oldStimIdx = stimIdx;
                        stimIdx = stimIdx + 1;
                        currStim = stimVec(stimIdx);
                    else % break
                        fprintf('Trial %d reached\n', nrTrs);
                        stopTime = GetSecs;
                        break
                    end
                else % still in decision stimulus
                    yOffset = yOffset + step_y; % move stimulus down according to movement
                end
            end
            % put new dots on screen
            yPts_track = yPts_track + step_y;
            yPts_out = find(yPts_track>yBottom);
            nrOut = numel(yPts_out);
            xPts_track(yPts_out) = round(rand(1,nrOut)*maxTrackWidth+xPtsOffset);
            yPts_track(yPts_out) = round(rand(1,nrOut)*step_y);
            
        end
    end
end


Screen('FillRect', window,black);
Screen('Flip', window);

WaitSecs(0.5);

% clean up
Screen('CloseAll');


