function flash = genFlash_trainer(stim, win)
% make a 'flash' stimulus - a square that appears centered in the screen 

flashRect = ones(stim.Vstim_size(1), stim.Vstim_size(2)); 
if isempty(stim.Vstim_color)
    white = WhiteIndex(win); 
    flash = flashRect*white; 
else
    flash = cat(3,flashRect*stim.Vstim_color(1),flashRect*stim.Vstim_color(2),flashRect*stim.Vstim_color(3)); 
end
