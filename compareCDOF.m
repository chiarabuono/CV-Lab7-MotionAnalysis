function [] = compareCDOF(videoFile, tau1, alpha, tau2, W)
    % This function compares the output of the change detection algorithm based
    % on a running average, and of the optical flow estimated with the
    % Lucas-Kanade algorithm.
    % tau1 is the threshold for the change detection
    % alpha is the parameter to weight the contribution of current image and
    % previous background in the running average
    % tau2 is the threshold for the image differencing in the running average
    % W is the side of the square patch to compute the optical flow
    
    % Create a VideoReader object
    videoReader = VideoReader(videoFile);
    
    % Initialize variables
    background = []; % Running average background model
    previousGrayFrame = []; % Store the previous frame for optical flow computation
    i = 0; % frame counter
    
    % Loop through each frame of the video
    while hasFrame(videoReader)
        % Read the next frame and convert to grayscale
        frame = readFrame(videoReader);
        grayFrame = double(rgb2gray(frame)); % (as double for processing)
        
        % Initialize the background model with the first frame if not already defined
        if isempty(background)
            background = grayFrame;
        end
        
        % Compute the running average for background modeling with tau2
        if ~isempty(previousGrayFrame)
            diffWithPrev = abs(previousGrayFrame - grayFrame);
            updateMask = diffWithPrev < tau2; % Pixels with small differences
            background(updateMask) = (1 - alpha) * background(updateMask) + alpha * grayFrame(updateMask);
        end
        
        % Perform change detection
        binaryMap = abs(grayFrame - background) > tau1;
        
        % Compute optical flow using Lucas-Kanade if the previous frame exists
        if ~isempty(previousGrayFrame)
            [u, v] = LucasKanade(previousGrayFrame, grayFrame, W);
            rgbOpticalFlow = convertToMagDir(u, v); % Convert optical flow to magnitude and direction for visualization
        else
            % Placeholder for the first frame (neutral optical flow image)
            rgbOpticalFlow = uint8(128 * ones(size(frame))); %
        end
           
        
        % Display the frame
        figure(1), subplot(2, 2, 1), imshow(frame, 'Border', 'tight');
        title(sprintf('Frame %d', round(videoReader.CurrentTime * videoReader.FrameRate)));
        
        % Display the map of the optical flow
        figure(1), subplot(2, 2, 2), imshow(rgbOpticalFlow, 'Border', 'tight');
        title('Optical Flow');
        
        % Display the running average
        figure(1), subplot(2, 2, 4), imshow(uint8(background), 'Border', 'tight');
        title('Running Average Background');
        
        % Display the binary map obtained with the change detection
        figure(1), subplot(2, 2, 3), imshow(binaryMap, 'Border', 'tight');
        title('Binary Map');

        drawnow;
        
        % Update the previous frame for optical flow computation
        previousGrayFrame = grayFrame;
        i = i + 1;
    end
    
    fprintf('Finished displaying video: %s\n', videoFile);
end
