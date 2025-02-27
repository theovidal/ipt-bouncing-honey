function open_videos(params)
    % Check if folder path is provided, if not use current directory
    if nargin < 1
        params.videos_folder = pwd;
    end

    % Get a list of all .avi files in the folder
    video_files = dir(fullfile(params.videos_folder, '*.avi'));

    % Check if there are any .avi files in the folder
    if isempty(video_files)
        disp('No .avi files found in the specified folder.');
        return;
    end

    if strcmp(params.reference_path, "")
        reference_frame = []
    else
        reference_frame = imread(fullfile(params.videos_folder, params.reference_path));
        reference_frame = rot90(reference_frame, -1);
    end

    % Iterate over each .avi file
    for i = 1:length(video_files)
        name = video_files(i).name;
        % Get the full path of the video file
        video_path = fullfile(params.videos_folder, name);

        v = VideoReader(video_path);
        num_frames = floor(v.FrameRate*v.Duration)-10;
        
        info_file = fopen(fullfile(params.results_folder, sprintf('%s.csv', name)), 'w');
        fprintf(info_file, 'name,num_frames,framerate,duration,width,height,temperature,rate,beginning,oscillations_beginning,comments\n');
        fprintf(info_file, sprintf('%s,%d,%d,%.2f,%d,%d,,,,,\n', name, num_frames, v.FrameRate, v.Duration, v.Width, v.Height));
        fclose(info_file);
        
        params.video_end = v.Duration;
        fprintf('Processing video: %s\n', name);
        honey_dynamic(v, reference_frame, name, num_frames, params);
    end

    disp('Processing of all videos is complete.');
end