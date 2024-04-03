%% In case matlab crashes or something goes wrong
% load saved files (assuming there is already at least one triangulation).
%% Get directories
addpath(fullfile(pwd,'Label3D'))
addpath(genpath(fullfile(pwd,'Label3D\deps')))
addpath(genpath(fullfile(pwd,'Label3D\skeletons')))
%% Saved directory - requires User input
% temp_dir = 'D:\_temp_Label3D';
% temp_file = '20230511_172238_Label3D.mat';
% temp_filepath = fullfile(temp_dir, temp_file);
temp_filepath = uigetfile('', 'Select last temp saved');

%% read from DANNCE
danncePath = 'H:\DANNCE';
date = '230508';
animal_ID = 'animalX';
projectFolder = uigetdir('', 'Select Project folder');


%% LOAD VIDEOS 

frames_path = fullfile(projectFolder, 'Labeled_frames');

% check if videos are saved
videos_filename = fullfile(frames_path, 'videos.mat');
if any(~exist(videos_filename, 'file'))
    % Load frames
    where_frames = fullfile(frames_path, 'frames_to_label.mat');
    framesToLabel = load(where_frames, 'framesToLabel');
    framesToLabel = framesToLabel.framesToLabel;
   
    % collect Sync
    sync = collectSyncPaths(fullfile(projectFolder,'trimmed_vids'));
    sync = cellfun(@(X) {load(X)}, sync);

    % Get the videos
    vidName = '*.mp4';
    vidPaths = collectVideoPaths(fullfile(projectFolder,'trimmed_vids'), vidName);
    videos = cell(length(vidPaths),1);
    fprintf('Wait a sec, loading videos \n')
    parfor nVid = 1:numel(vidPaths)
        disp(['vid ', num2str(nVid)])
        % frameInds = sync{nVid}.data_frame(framesToLabel);
        videos{nVid} = readFrames(vidPaths{nVid} , framesToLabel);
    end
    % save
    save(videos_filename, 'videos', '-v7.3')
else
    % load previously saved videos
    videos = load(videos_filename, 'videos');
    videos = videos.videos;
end

%% Run label3d from state
labelGUI = Label3D(temp_filepath, videos);

%labelGUI.exportDannce('framesToLabel', framesToLabel)
