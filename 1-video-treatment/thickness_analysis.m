function [thicknesses] = thickness_analysis(thicknesses_file, frame_number, frame_time, largest_component, params)
    thicknesses = sum(largest_component, 2);

    % Output the results to the file
    for y = 1:length(thicknesses)
        y_coordinate = y + params.y_min - 1;
        thickness = thicknesses(y);
        fprintf(thicknesses_file, '%d,%.5f,%d,%d\n', frame_number, frame_time, y_coordinate, thickness);
    end
end


% function [thicknesses] = thickness_analysis(thicknesses_file, frame_number, frame_time, pixels, params)
%     % ---------- THICKNESS ANALYSIS ----------
%     y_coords = pixels(:, 2); 
%     [unique_y, ~, idy] = unique(y_coords);
%     counts = accumarray(idy, 1);
%     
%     % The coordinates are relative to the crop, so we must adapt our
%     % boundaries
%     full_y_range = 1:(params.y_max - params.y_min + 1);
%     
%     % Initialize an array to store counts for the full range
%     full_counts = zeros(1, length(full_y_range));
%     
%     % For each unique x-coordinate, place the corresponding count in the full_counts array
%     [~, loc] = ismember(unique_y, full_y_range);
%     full_counts(loc) = counts;
%     
%     % Create the result matrix with full x range and corresponding counts
%     thicknesses = [full_y_range; full_counts];
% 
%     for i = 1:length(thicknesses(1, :))
%         x_coordinate = thicknesses(1, i);
%         thickness = thicknesses(2, i);
%         fprintf(thicknesses_file, '%d,%.5f,%d,%d\n', frame_number, frame_time, x_coordinate, thickness);
%     end
% end