function [u, v] = LucasKanade(im1, im2, windowSize)
    % Optical Flow - Lucas Kanade algorithm
    % INPUT: im1, im2 two adjacent image frames (instants t and t+1)
    %        windowSize the size of a local neighbourhood
    % OUTPUT: two maps (double) encoding the two components of OF
    %---------------------------------------------------------------------
    
    % Image check
    if (size(im1,1)~=size(im2,1)) || (size(im1,2)~=size(im2,2))
        error('The two images have different dimensions');
    end
    
    if (size(im1,3) ~= 1) || (size(im2, 3) ~= 1)
        error('The images must be grayscale');
    end
    
    % Compute spatial and temporal derivatives
    [fx, fy, ft] = ComputeDerivatives(im1, im2);
    
    u = zeros(size(im1));
    v = zeros(size(im1));
    
    halfW = floor(windowSize/2);
    
    % For each pixel of the image, construct a least-squares system
    for i = halfW+1 : size(fx,1)-halfW
        for j = halfW+1:size(fx,2)-halfW
            
            % Extract the local window
            fx_window = fx(i-halfW:i+halfW, j-halfW:j+halfW);
            fy_window = fy(i-halfW:i+halfW, j-halfW:j+halfW);
            
            % Construct the matrix A
            A = [reshape(fx_window, [], 1), reshape(fy_window, [], 1)]; 
            
            % Construct the vector b
            ft_window = ft(i-halfW:i+halfW, j-halfW:j+halfW);
            b = -reshape(ft_window, [], 1);
            
            % Solve the least-squares system
            U = pinv(A)*b; 
            
            u(i,j)=U(1);
            v(i,j)=U(2);
            
        end
    end
    
    % Handle NaN values
    u(isnan(u))=0;
    v(isnan(v))=0;
    
end
