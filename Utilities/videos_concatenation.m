function videos_concatenation(input_dir, output_dir)
%% Preamble
% This function takes the input dir and concatenates videos inside the
% folder and saves them in the outputdir folder.
%       Input: 
%           input_dir: folder where the videos are. The organization is one folder per
%               camera, i.e., cam1, cam2, etc. Within each forlder there must be at least
%               2 .mp4 videos to be concatenated
%           output_dir :The folder where the cameras are going to be saved. It will
%               contain all the camera files. cam1.mp4, cam2.mp4, etc.
%%
% Get info on animal and sessions to analyze
overwrite = 0;
n_sessions = 1;
remove_raw = 1;
do_copy_files = 0;

FFmpeg_exe = 'M:\Software\FFmpeg\bin\ffmpeg.exe';

for i_sess = 1:n_sessions
    % Get info on this session

    video_path = input_dir;
    % video_path = fullfile(ori_videos_path, this_session_date, this_session_name);
    video_folder_destination = output_dir;
    if ~exist(video_folder_destination, 'dir'), mkdir(video_folder_destination), end
    cameras = dir(video_path);
    cameras = {cameras.name}';
    cameras = cameras(cellfun(@(x) startsWith(x, 'cam'), cameras));
    n_cameras = length(cameras);
    if n_cameras == 0
        sprintf('No videos were found')
        continue
    else
        sprintf('Found videos from %i cameras',n_cameras)
    end
    %             folder_items = dir(video_path);
    %             if sum(endsWith({folder_items.name}, '.mp4')) == 2 && ~overwrite
    %                 log(sprintf('Videos already concatenated for %s - %s - %s', animal_ID, this_session_date, this_session_experiment))
    %                 continue
    %             end
    % Loop through cameras
    for i_cam = 1:n_cameras
        % Get video
        camera_folder = fullfile(video_path, cameras{i_cam});
        videos = dir(camera_folder);
        videos = {videos.name}';
        videos = videos(cellfun(@(x) endsWith(x, '.mp4'), videos));
        n_videos = length(videos);
        if n_videos == 0
            log(sprintf('\tNo videos from camera %i', i_cam))
            continue
        end

        % Make new filename
        % f = strsplit(videos{1}, '.mp4');
        filename = fullfile(video_folder_destination, [cameras{i_cam}, '.mp4']);

        if ~exist(filename, 'file') || overwrite
            % Prepend folder
            videos = strcat(camera_folder, filesep, videos);

            if n_videos == 1
                log(sprintf('Copying ''%s''', filename), 'contains_path',true)
                copyfile(videos{1}, filename)

            else
                videos_list_filename = [tempname(), '.txt'];
                % Write videos list to disk
                fileID = fopen(videos_list_filename, 'w');
                for i_video = 1:n_videos
                    fprintf(fileID, 'file ''%s''\n', videos{i_video});
                end
                fclose(fileID);

                % Run conversion in FFmpeg
                cmd = sprintf('%s -safe 0 -f concat -i %s -c copy "%s"', FFmpeg_exe, videos_list_filename, filename);
                system(cmd)
                delete(videos_list_filename)
            end

        else
            sprintf('\tAlready processed videos from camera %i', i_cam)
        end

        % Delete folder with raw videos
        if remove_raw
            fprintf('\tRemoving raw files ...')
            rmdir(camera_folder, 's')
            fprintf('\t\tdone')
        end

        % Copy concatenated file to local folder
        if do_copy_files
            sprintf('\tCopying video to ''%s''', video_folder_destination)
            copyfile(filename, video_folder_destination)
            log('\t\tdone')
        end
    end
end

end