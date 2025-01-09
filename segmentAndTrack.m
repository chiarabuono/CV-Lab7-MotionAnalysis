function [] = segmentAndTrack(videoFile, tau1, alpha, tau2)
    % This function segments and tracks a target in a video based on change
    % detection and user input. 
    % tau1: Threshold for change detection.
    % alpha: Weight for the running average background update.
    % tau2: Threshold for image differencing in the running average.

    % Create a VideoReader object
    videoReader = VideoReader(videoFile);
    
    % Initialize variables
    background = []; % Background model for running average
    trajectory = []; % To store the trajectory of the target
    i = 0;
    
    % Loop through each frame of the video
    while hasFrame(videoReader)
        % Read the next frame
        frame = readFrame(videoReader);
        grayFrame = double(rgb2gray(frame)); % Convert to grayscale for processing
    
        % Initialize the background model if not yet defined
        if isempty(background)
            background = grayFrame;
        end
    
        % Update the running average background using tau2
        if i > 0
            diffWithPrev = abs(grayFrame - background);
            updateMask = diffWithPrev < tau2; % Update only pixels with small differences
            background(updateMask) = alpha * grayFrame(updateMask) + (1 - alpha) * background(updateMask);
        end
    
        % Perform change detection
        binaryMap = abs(grayFrame - background) > tau1;
    
        % Display the current frame
        figure(1), imshow(frame, 'Border', 'tight');
        title(sprintf('Frame %d', round(videoReader.CurrentTime * videoReader.FrameRate)));
    
        if i == 1380
            % Pause to allow user to select the target point manually
            disp('Select the target on the person (click on the figure).');
            pause(1);  % Pause for 1 second to give time for the user to focus
            
            % Get user input point with ginput
            disp('Click on the target with the left mouse button.');
            [x, y] = ginput(1); % Get user input point
            
            if isempty(x) || isempty(y)
                disp('No point selected. Exiting...');
                return; % Exit if no point is selected
            end
            
            targetCentroid = [x, y]; % Initialize the target position
            trajectory = [trajectory; targetCentroid]; % Add to trajectory
        elseif i > 1380
            % Identify connected components in the binary map
            cc = bwconncomp(binaryMap); % Find connected components
            stats = regionprops(cc, 'Centroid', 'Area'); % Get properties
            
            % Filter components by area if necessary
            minArea = 50; % Example threshold for minimum size
            stats = stats([stats.Area] > minArea);
    
            % Extract centroids
            centroids = reshape([stats.Centroid], 2, [])';
    
            % Associate the target to the closest component
            if ~isempty(centroids)
                distances = vecnorm(centroids - targetCentroid, 2, 2);
                [~, idx] = min(distances); % Find the closest centroid
                targetCentroid = centroids(idx, :); % Update target position
                trajectory = [trajectory; targetCentroid]; % Append to trajectory
            end
        end
    
        % Plot trajectory so far
        hold on;
        if ~isempty(trajectory)
            plot(trajectory(:, 1), trajectory(:, 2), 'r-', 'LineWidth', 2); % Plot trajectory
        end
        hold off;
    
        i = i + 1;
    end
    
    % At the end of the video, visualize the trajectory on the last frame
    figure, imshow(frame, 'Border', 'tight');
    hold on;
    plot(trajectory(:, 1), trajectory(:, 2), 'r-', 'LineWidth', 2);
    title('Final Trajectory');
    hold off;
    
    % Close the figure when playback is finished
    close all;
    
    fprintf('Finished displaying video: %s\n', videoFile);
end
