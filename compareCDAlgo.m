function [] = compareCDAlgo(videoFile, tau1, alpha, tau2, N)
    % This function compares the output of the change detection algorithm using
    % two possible background models: static and running average.
    
    % Create a VideoReader object
    videoReader = VideoReader(videoFile);
    
    % Initialize variables for the static background computation
    staticBackground = 0; % Accumulator for averaging
    frameCount = 0;
    
    % Compute the static background (average of the first N frames)
    while hasFrame(videoReader) && frameCount < N
        frame = readFrame(videoReader); % Read the next frame
        frameGray = rgb2gray(frame); % Convert to grayscale
        staticBackground = staticBackground + double(frameGray); % Accumulate
        frameCount = frameCount + 1;
    end
    
    % Compute the average background after processing N frames
    staticBackground = uint8(staticBackground / frameCount);
    
    % Reset the VideoReader to process the video again from the start
    videoReader.CurrentTime = 0;
    
    % Initialize running average background model
    runningAverage = double(staticBackground); % Start with static background
    
    % Loop through each frame of the video for comparison
    while hasFrame(videoReader)
        % Read the next frame
        frame = readFrame(videoReader);
        frameGray = rgb2gray(frame); % Convert to grayscale
        
        % Binary map for static background model
        binaryMap1 = abs(double(frameGray) - double(staticBackground)) > tau1;
        
        % Update the running average
        runningAverage = (1 - alpha) * runningAverage + alpha * double(frameGray);
        
        % Binary map for running average model
        binaryMap2 = abs(double(frameGray) - runningAverage) > tau2;
        
        % Visualization
        figure(1), subplot(2, 3, 1), imshow(frame, 'Border', 'tight');
        title(sprintf('Frame %d', round(videoReader.CurrentTime * videoReader.FrameRate)));
        
        figure(1), subplot(2, 3, 2), imshow(staticBackground, 'Border', 'tight');
        title('Static background');
        
        figure(1), subplot(2, 3, 3), imshow(binaryMap1, 'Border', 'tight');
        title('Binary map 1');
        
        figure(1), subplot(2, 3, 5), imshow(uint8(runningAverage), 'Border', 'tight');
        title('Running average');
        
        figure(1), subplot(2, 3, 6), imshow(binaryMap2, 'Border', 'tight');
        title('Binary map 2');
    end
    
    % Close the figure when playback is finished
    close all;
    
    fprintf('Finished displaying video: %s\n', videoFile);
end
