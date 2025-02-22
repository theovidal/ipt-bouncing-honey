function honey_dynamic(v, reference_frame, name, num_frames, params)
    now = datetime('now','Format','yyyy-MM-dd_HH-mm-ss');

    if params.static_analysis
        static_file = fopen(fullfile(params.results_folder, sprintf("%s.%s.csv", name, now)), 'a+');
        fprintf(static_file, 'frame,time,area,perimeter,centroid_x,centroid_y,tip_x,tip_y\n');
    end
    
    if params.thickness_analysis
        thicknesses_file = fopen(fullfile(params.results_folder, sprintf("%s.%s.thickness.csv", name, now)), 'a+');
        fprintf(thicknesses_file, 'frame,time,y,thickness\n');
    end
    
    % Building the time vector
    frame_init = int64(params.video_init*v.FrameRate) + 1;
    frame_end = min(num_frames, int64(params.video_end*v.FrameRate));       

    for i=frame_init:(frame_end - 1)
        if params.debug
            fprintf('Treating frame %d/%d\r', i - frame_init + 1, frame_end - frame_init + 1);
        end
    
        frame = read(v, i);
        frame_number = i;
        frame_time = double(i - 1)/v.FrameRate;
    
        if params.x_max == -1
            params.x_max = size(frame, 2);
        end
        if params.y_max == -1
            params.y_max = size(frame, 1);
        end
    
        [largest_component] = extract_frame(frame, reference_frame, params);
    
        if params.static_analysis
            static_analysis(static_file, frame_number, frame_time, largest_component);
        end

        if params.thickness_analysis
            thickness_analysis(thicknesses_file, frame_number, frame_time, largest_component, params);
        end
    end
    
    if params.static_analysis
        fclose(static_file);
    end

    if params.thickness_analysis
        fclose(thicknesses_file);
    end
end
