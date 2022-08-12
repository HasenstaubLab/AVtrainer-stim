function notInCircle = isNotInCircle(xPts, yPts, center, radius) 
% supporting function for AVtrainerStim system
notInCircle = (xPts - center(1)).^2 + (yPts - center(2)).^2 > radius^2; 