clc;
close all;
clear

% SCRIPT PARAMETERS

video_path = "data/honey_3.avi";
video_init = 100;
video_end = 1000;

channel = 3;
threshold = 180;

min_y = 1000;
max_y = 2000;

debug=0;

% BEGINNING OF THE CODE
v = VideoReader(video_path);
num_frames = floor(v.FrameRate*v.Duration)-10; 

results_file = fopen('results/data.csv', 'w');
fprintf(results_file, 'frame,time,area (px)\n');

% Building the time vector
duration = video_end - video_init + 1;
init_t = video_init/v.FrameRate;
end_t = video_end/v.FrameRate;
t=linspace(init_t, end_t, duration);

% Showing the image and all three channels separately to determine which
% one has the best contrast
% With a white background setup and an orange honey, the blue channel is
% the most appropriate one (complementary color)
%subplot(2, 2, 1)
%imshow(frame)
%for i=1:3
%    subplot(2, 2, i + 1)
%    imshow(frame(:, :, i))
%end

areas = zeros(video_end - video_init + 1, 1);

for i=video_init:video_end
    frame = read(v, i);
    % We need to get only one channel for processing
    spoon = frame(min_y:max_y, :, channel);
    % Applying a threshold to get relevant pixels -> will be white if object,
    % dark if not
    spoon = spoon > threshold;
    if debug
        imshow(spoon)
    end

    spoon_CC = bwconncomp(spoon, 8);
    %crop=regionprops(Z_crop,'BoundingBox').BoundingBox

    % Get all the surfaces ; we need to select the bigger one (the spoon)
    points = regionprops(spoon_CC,'PixelList');
    surfaces = regionprops(spoon_CC, 'Area');
    sizes=ones(1,size(points,1));
    for j=1:size(points,1)
        sizes(j)=size(points(j).PixelList,1);
    end

    [M, i_spoon]=max(sizes);

    area = surfaces(i_spoon).Area;
    areas(i - video_init + 1) = area;
    % TODO: get the area of the spoon on the image to remove it and only
    % have a Delta surface
    fprintf(results_file, "%d,%.5f,%d\n", i, i/v.FrameRate, area);
end

fclose(results_file);

grid('on')
plot(t, areas)
title('Area of honey and spoon over time')
