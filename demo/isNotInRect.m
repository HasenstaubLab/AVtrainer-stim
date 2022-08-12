function notInRect = isNotInRect(xPts, yPts, center, rectWdth, rectHt) 
% supporting function for AVtrainerStim system
notInRect = xPts >= center(1)+rectWdth/2 | xPts <= center(1)-rectWdth/2 | ...
        yPts >= center(2)+rectHt/2 | yPts <= center(2)-rectHt/2; 
