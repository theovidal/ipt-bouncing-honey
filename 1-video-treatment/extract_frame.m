% TODO: make a complete script to debug the behavior of the extraction

function [largest_component] = extract_frame(frame, reference, params)
% We need to get only one channel for processing    
    if isempty(reference)
        difference = frame(:, :, params.pixels_channel);
    else
        difference = abs(frame(:, :, params.pixels_channel) - reference(:, :, params.pixels_channel)); % Convert to double for proper subtraction
    end

    trickle_frame = difference(params.y_min:params.y_max, params.x_min:params.x_max, :);
    %trickle_frame = rgb2gray(trickle_frame);
    % Applying a threshold to get relevant pixels -> will be white if object,
    % dark if not
    trickle_frame_comp = trickle_frame > params.threshold;

    honey_CC = bwconncomp(trickle_frame_comp, 8);

    % Get all the surfaces ; we need to select the bigger one (the spoon)
    all_areas = regionprops(honey_CC, 'Area');
    sizes=[all_areas.Area];

    [~, honey_index]=max(sizes);

    largest_component = false(size(trickle_frame_comp));
    largest_component(honey_CC.PixelIdxList{honey_index}) = true;

    if params.pixels_filling
        for row = 1:size(largest_component, 1)
            % Find border pixels
            borderIndices = find(largest_component(row, :) > 0);
            
            % Check if there are at least two border pixels
            if numel(borderIndices) >= 2
                % Fill between the first and last border pixel
                largest_component(row, borderIndices(1):borderIndices(end)) = true;
            end
        end
    end

    if params.debug
        f = figure(1);
        if params.fullscreen
            f.WindowState = 'maximized';
        end
        subplot(1, 4, 1)
        imshow(frame(params.y_min:params.y_max, params.x_min:params.x_max, :))
        title('Frame')

        subplot(1, 4, 2)
        imshow(trickle_frame)
        title('Frame (with applied difference)')

        subplot(1, 4, 3)
        imshow(trickle_frame_comp);
        title('Raw trickle filtering')

        subplot(1, 4, 4)
        imshow(largest_component);
        title('Filled Largest Connected Component');

        drawnow;
    end
end
