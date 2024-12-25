function [] = compareCDOF(videoFile, tau1, alpha, tau2, W) 
    % This function compares the output of the change detection algorithm based
    % on a running average, and the optical flow estimated with the
    % Lucas-Kanade algorithm.
    
    % Create a VideoReader object
    videoReader = VideoReader(videoFile);
    
    % Initialize variables for running average and background model
    background = []; % Will store the running average
    
    % Create optical flow object
    opticFlow = opticalFlowLK('NoiseThreshold', 0.01); % Configurazione flusso ottico
    
    % Loop through each frame of the video
    while hasFrame(videoReader)
        % Read the next frame
        frame = readFrame(videoReader);
        grayFrame = rgb2gray(frame); % Convert to grayscale for processing
    
        % Initialize the background model if not yet defined
        if isempty(background)
            background = double(grayFrame);
        end
    
        % Compute running average background
        background = alpha * double(grayFrame) + (1 - alpha) * background;
        binaryMap = abs(double(grayFrame) - background) > tau1; % Change detection
    
        % Compute optical flow using Lucas-Kanade
        flow = estimateFlow(opticFlow, grayFrame); % Stima del flusso ottico
        u = flow.Vx; % Componente orizzontale
        v = flow.Vy; % Componente verticale
        rgbOpticalFlow = convertToMagDir(u, v); % Visualize optical flow
    
        % Display the frame
        figure(1), subplot(2, 2, 1), imshow(frame, 'Border', 'tight');
        title(sprintf('Frame %d', round(videoReader.CurrentTime * videoReader.FrameRate)));
    
        % Display the optical flow visualization
        figure(1), subplot(2, 2, 2), imshow(rgbOpticalFlow, 'Border', 'tight');
        title('Optical Flow');
    
        % Display the running average (background)
        figure(1), subplot(2, 2, 4), imshow(uint8(background), 'Border', 'tight');
        title('Static Background');
    
        % Display the binary map obtained with the change detection
        figure(1), subplot(2, 2, 3), imshow(binaryMap, 'Border', 'tight');
        title('Binary Map');
    end
    
    fprintf('Finished displaying video: %s\n', videoFile);
    end
    