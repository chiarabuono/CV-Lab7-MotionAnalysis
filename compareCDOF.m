function [] = compareCDOF(videoFile, tau1, alpha, tau2, W)
    % This function compares the output of the change detection algorithm based
    % on a running average, and of the optical flow estimated with the
    % Lucas-Kanade algorithm.
    % You must visualize the original video, the background and binary map
    % obtained with the change detection, the magnitude and direction of the
    % optical flow.
    % tau1 is the threshold for the change detection
    % alpha is the parameter to weight the contribution of current image and
    % previous background in the running average
    % tau2 is the threshold for the image differencing in the running average
    % W is the side of the square patch to compute the optical flow
    
    % Create a VideoReader object
    videoReader = VideoReader(videoFile);
    
    % Initialize variables
    background = []; % To store the running average
    previousGrayFrame = []; % To store the previous frame for optical flow computation
    i = 0;
    
    % Loop through each frame of the video
    while hasFrame(videoReader)
        % Read the next frame and convert to grayscale
        frame = readFrame(videoReader);
        grayFrame = rgb2gray(frame);
    
        % Initialize the background model if not already defined
        if isempty(background)
            background = double(grayFrame);
        end
    
        % Compute the running average for background modeling
        background = alpha * double(grayFrame) + (1 - alpha) * background;
        
        % Perform change detection
        binaryMap = abs(double(grayFrame) - background) > tau1;
    
        % Compute optical flow using Lucas-Kanade
        if ~isempty(previousGrayFrame)
            [u, v] = LucasKanade(previousGrayFrame, grayFrame, W); % Lucas-Kanade algorithm
            rgbOpticalFlow = convertToMagDir(u, v); % Convert to RGB visualization
        else
            % Placeholder for the first frame
            rgbOpticalFlow = uint8(128 * ones(size(frame)));
        end
    
        % Display the original frame
        figure(1), subplot(2, 2, 1), imshow(frame, 'Border', 'tight');
        title(sprintf('Frame %d', round(videoReader.CurrentTime * videoReader.FrameRate)));
    
        % Display the optical flow visualization
        figure(1), subplot(2, 2, 2), imshow(rgbOpticalFlow, 'Border', 'tight');
        title('Optical Flow');
    
        % Display the running average (background model)
        figure(1), subplot(2, 2, 4), imshow(uint8(background), 'Border', 'tight');
        title('Running average Background');
    
        % Display the binary map obtained with the change detection
        figure(1), subplot(2, 2, 3), imshow(binaryMap, 'Border', 'tight');
        title('Binary Map');
    
        % Update the previous frame for optical flow computation
        previousGrayFrame = grayFrame;
    
        % Increment the frame counter
        i = i + 1;
    end
    close all;
    fprintf('Finished displaying video: %s\n', videoFile);
    end
