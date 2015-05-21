clc; close all; clear
%% Read image and detect interest points.
I = imread('cameraman.tif');
points = detectSURFFeatures(I);
%% Display locations of interest in image.
imshow(I); hold on;
plot(points.selectStrongest(10));
% plot(points);
hold off;