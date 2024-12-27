clear 
close all
clc

%% Part 1.1 - Comparison between static and running average background
compareCDAlgo('videos/luce_vp.mp4', 30, 0.1, 50, 10);

%% Part 1.2 - Comparison between running average and optical flow 
compareCDOF('videos/tennis.mp4', 30, 0.2, 30, 8);

%% Part 2 - Tracker of fixed target
segmentAndTrack('videos/DibrisHall.mp4', 50, 0.25, 10);