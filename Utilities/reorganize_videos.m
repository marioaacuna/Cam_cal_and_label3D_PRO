function reorganize_videos(folder_in, folder_out)

% Set the paths for the original video folder and the target root folder
orig_folder = folder_in; %'H:\DANNCE\230428\328\trimmed_vids';
target_root = folder_out;%'H:\DANNCE\230428\328\behavior_videos';

% Create the target root folder if it doesn't already exist
if ~exist(target_root, 'dir')
    mkdir(target_root);
end

% Loop through each camera and create a folder for it inside the target root
for i_camera = 1:6
    % Create the name for the camera folder
    cam_folder = sprintf('Camera%d', i_camera);

    % Create the full path for the camera folder
    cam_path = fullfile(target_root, cam_folder);

    % Create the camera folder if it doesn't already exist
    if ~exist(cam_path, 'dir')
        mkdir(cam_path);
    end

    % Set the name for the video file in this camera's folder
    video_name = '0.mp4';

    % Set the full paths for the original video and the new video location
    orig_path = fullfile(orig_folder, sprintf('cam%d.mp4', i_camera));
    target_path = fullfile(cam_path, video_name);

    % Copy the video file from the original location to the new location
    copyfile(orig_path, target_path);
end