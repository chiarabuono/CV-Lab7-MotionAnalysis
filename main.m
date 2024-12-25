clear all
close all
clc

%% Part 1.1 - Comparison between static and moving average background
%compareCDAlgo('videos/luce_vp.mp4', 30, 0.1, 25, 10);

%% Part 1.2 - Comparison between moving average and optical flow 
%compareCDOF('videos/tennis.mp4', 30, 0.2, 25, 10);

%% Part 2 - Tracker of fixed target
segmentAndTrack('videos/DibrisHall.mp4', 30, 0.2, 25);