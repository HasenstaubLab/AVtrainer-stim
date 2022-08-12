function stimVec = addTrackCodesToStimVec(stimVec)
% intersperse zeros ('track codes') into stimulus vector for AVtrainer

nrTrs = numel(stimVec); 

stimVec_mod = zeros(1,nrTrs*2);
stimVec_mod(~mod(1:numel(stimVec_mod), 2)) = stimVec; % assign stimVec values to every even element
stimVec = stimVec_mod;
