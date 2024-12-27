function [rgbImage] = convertToMagDir(u, v)
    % This function produces a visualization of the optical flow based on
    % the magnitude and direction of each vector
    % u and v are the matrices with the two components of the optical flow
    
    % Calculation of the magnitude and direction of the optical flow
    magnitude = sqrt(u.^2 + v.^2); % Magnitude
    direction = atan2(v, u);       % Direction in radians
    
    % Normalization for visualization
    magnitudeNorm = magnitude / max(magnitude(:)); % Normalize the magnitude
    
    % Conversion from direction and magnitude to HSV color space
    hue = (direction + pi) / (2 * pi); % Direction normalized to [0, 1]
    saturation = ones(size(hue));      % Constant saturation
    value = magnitudeNorm;             % Intensity based on the magnitude
    
    % Conversion from HSV to RGB
    hsvImage = cat(3, hue, saturation, value);
    rgbImage = hsv2rgb(hsvImage);
    end
    