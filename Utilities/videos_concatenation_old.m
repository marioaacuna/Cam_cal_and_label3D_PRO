function videos_concatenation(input_dir, output_dir)
% Get info on animal and sessions to analyze
overwrite = 1;
remove_raw = 1;
do_copy_files = 0; % copy to local
ori_videos_path = 'T:\Marta\test_Formalin\';
session = {'sess1'};
n_sessions = 1;


% animal_ID = '';
% ori_video_path = '';
date = {'220804'}; %'formalin;date'
% selected_sessions = cell2mat(sessions(:, 1));
% sessions = sessions(selected_sessions, :);
% n_sessions = size(sessions, 1);
FFmpeg_exe = 'M:\Software\FFmpeg\bin\ffmpeg.exe';
for i_sess = 1:n_sessions
    % Get info on this session
    this_session_date = date{i_sess};
%     this_session_date = sessions{i_sess, 2};
%     this_session_experiment = strsplit(sessions{i_sess, 3}, ';');
%     this_session_experiment = this_session_experiment{2};
    this_session_name = session{i_sess};
    % Set path to folder where videos are located
    video_path = fullfile(ori_videos_path, this_session_date, this_session_name);
    % video_path = fullfile(ori_videos_path, this_session_date, this_session_name);
    video_folder_destination = fullfile('D:/_concat_videos');
    if ~exist(video_folder_destination, 'dir'), mkdir(video_folder_destination), end
    cameras = dir(video_path);
    cameras = {cameras.name}';
    cameras = cameras(cellfun(@(x) startsWith(x, 'cam'), cameras));
    n_cameras = length(cameras);
    if n_cameras == 0
        sprintf('No videos were found for - %s', this_session_date)
        continue
    else
        sprintf('%s : found videos from %i cameras', this_session_date,n_cameras)
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
        f = strsplit(videos{1}, '_');
        filename = fullfile(video_path, [f{1}, '_', cameras{i_cam}, '.mp4']);

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

