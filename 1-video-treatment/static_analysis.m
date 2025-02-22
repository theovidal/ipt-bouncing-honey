function [centroid, perimeter, pixels, tip] = static_analysis(results_file, frame_number, frame_time, largest_component)
    % ---------- POINTS ANALYSIS ----------
    %all_centroids = regionprops(honey_CC, 'Centroid');
    %centroid = all_centroids(honey_index).Centroid;
    centroid = calculateCentroid(largest_component);

    % ---------- AREA ANALYSIS ----------
    area = calculateArea(largest_component);

    % ---------- PERIMETER ANALYSIS ----------
    %all_perimeters = regionprops(honey_CC, 'Perimeter');
    %perimeter = all_perimeters(honey_index).Perimeter;
    perimeter = calculatePerimeter(largest_component);

    % ---------- TIP ANALYSIS ----------
    % The tip is defined as the bottom most pixel, so which has the
    % greatest y value
    %all_pixels = regionprops(honey_CC,'PixelList');
    %pixels = all_pixels(honey_index).PixelList;
    pixels = listTrueCoordinates(largest_component);

    % Find the maximum image y-coordinate (which is on the x axis of the matrix)
    max_y = max(pixels(:,1));
    
    % Extract points with maximum y-coordinate
    max_y_points = pixels(pixels(:,1) == max_y, :);
    
    % If there are multiple points, find the ones with the minimum and maximum x
    if size(max_y_points, 1) > 1
        min_x_point = min(max_y_points(:,2));
        max_x_point = max(max_y_points(:,2));
        left_point = max_y_points(max_y_points(:,2) == min_x_point, :);
        right_point = max_y_points(max_y_points(:,2) == max_x_point, :);
        
        % Calculate the midpoint
        tip = (left_point + right_point) / 2;
    else
        % If only one point, the midpoint is just that point
        tip = max_y_points;
    end

    % ---------- RESULTS WRITING ----------
    % TODO: get the area of the spoon on the image to remove it and only
    % have a Delta surface
    % DO NOT FORGET to invert the components of arrays: matrix indexing
    % corresponds to (y, x) in the usual cartesian base
    fprintf(results_file, "%d,%.3f,%d,%d,%d,%d,%d,%d\n", frame_number, frame_time, round(area), round(perimeter), round(centroid(2)), round(centroid(1)), round(tip(2)), round(tip(1)));
end

function perimeter = calculatePerimeter(boolMatrix)
    % Create a kernel to find boundary pixels
    kernel = [1 1 1; 1 -8 1; 1 1 1];
    
    % Convolve to find boundaries
    boundary = conv2(double(boolMatrix), kernel, 'same') > 0;
    
    % Sum boundary pixels
    perimeter = sum(boundary(:));
end

function centroid = calculateCentroid(boolMatrix)
    % Find coordinates of true components
    [rows, cols] = find(boolMatrix);
    
    % Calculate the centroid
    centroid = [mean(rows), mean(cols)];
end

function area = calculateArea(boolMatrix)
    % Count the number of true elements
    area = sum(boolMatrix(:));
end

function coords = listTrueCoordinates(boolMatrix)
    % Find coordinates of true components
    [rows, cols] = find(boolMatrix);
    
    % Combine rows and columns into a list of coordinates
    coords = [rows, cols];
end
