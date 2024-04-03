run_existing = 0;
run_label  = 0; % in case we label to train a net, otherwise get a few nr of frames at the beginning


% function [labelGui, framesToLabel] = TEST(danncePath,date, mouse_label)
%% Example setup for Label3D
% Label3D is a GUI for manual labeling of 3D keypoints in multiple cameras.
%
% Its main features include:
% 1. Simultaneous viewing of any number of camera views.
% 2. Multiview triangulation of 3D keypoints.
% 3. Point-and-click and draggable gestures to label keypoints.
% 4. Zooming, panning, and other default Matlab gestures
% 5. Integration with Animator classes.
% 6. Support for editing prelabeled data.
%
% Instructions:
% right: move forward one frameRate
% left: move backward one frameRate
% up: increase the frameRate
% down: decrease the frameRate
% t: triangulate points in current frame that have been labeled in at least two images and reproject into each image
% r: reset gui to the first frame and remove Animator restrictions
% u: reset the current frame to the initial marker positions
% z: Toggle zoom state
% p: Show 3d animation plot of the triangulated points.
% backspace: reset currently held node (first click and hold, then
%            backspace to delete)
% pageup: Set the selectedNode to the first node
% tab: shift the selected node by 1
% shift+tab: shift the selected node by -1
% h: print help messages for all Animators
% shift+s: Save the data to a .mat file

close all;clc;

fprintf('%%%% Running Label3D %%%%\n')

addpath(fullfile(pwd,'Label3D'))
addpath(genpath(fullfile(pwd,'Label3D\deps')))
addpath(genpath(fullfile(pwd,'Label3D\skeletons')))

% danncePath = 'T:\Mario\DANNCE';
% danncePath = 'D:\_test_label3D';
% date ='220414';
%% Load in the calibration parameter data
projectFolder = uigetdir('', 'Animal Project Dir');%fullfile(danncePath,date, animal_ID);
% calib_path = fullfile(danncePath);
% calib_path = fullfile(danncePath, date);
% cal_path = 'D:\cam_calibration\calibration';
% calib_path =fullfile(projectFolder, 'calibration');
calib_path = fullfile('H:\DANNCE\BaslerCamerasCalibration');


%% Load the videos into memory
vidName = '*.mp4';
%vidPaths = collectVideoPaths(fullfile(projectFolder,'trimmed_vids'), vidName);
vidPaths = collectVideoPaths(fullfile(projectFolder), vidName);
videos = cell(length(vidPaths),1);
% exception due to different folders /| fix later


% collect Sync
%sync = collectSyncPaths(fullfile(projectFolder,'trimmed_vids'));
sync = collectSyncPaths(fullfile(projectFolder));
sync = cellfun(@(X) {load(X)}, sync);

n_frames = size(sync{1}.data_frame,1);
% n_frames = round(n_frames / 3);
% framesToLabel = 1:100;

%% Get the frames to label
% Here you can actually get some frames of interest and run training with
% specific frames. 

% framesToLabel = [1:3];
frames_path = fullfile(projectFolder, 'Labeled_frames');
if ~exist(frames_path, 'dir')
    mkdir(frames_path)
end

where_frames = fullfile(frames_path, 'frames_to_label.mat');
if any(exist(where_frames, "file"))
    framesToLabel = load(where_frames);
    framesToLabel=framesToLabel.framesToLabel;
    create_frames = 0;

else
    frames_to_label_filename = where_frames;
    
    if ~run_label
        framesToLabel = 1:100;
    else
        framesToLabel = randperm(n_frames, 200);
%         framesToLabel=linspace(1,n_frames, 200);
%         framesToLabel = sort(framesToLabel);
    end
    create_frames = 1;
end
% save frames
if create_frames
    save(frames_to_label_filename, 'framesToLabel')
end



%% Load videos and params
videos_filename = fullfile(frames_path, 'videos.mat');
if any(exist(videos_filename, "file"))
    videos = load(videos_filename);
    videos= videos.videos;
else

    fprintf('Wait a sec, loading videos \n')
    parfor nVid = 1:numel(vidPaths)
        disp(['vid ', num2str(nVid)])
        frameInds = sync{nVid}.data_frame(framesToLabel);
        videos{nVid} = readFrames(vidPaths{nVid} , frameInds+1);
    end
    disp('done loading vids')


    save(videos_filename, 'videos')
end

%% Load calibration ; in case done for all experiments, collect from projecfolder
calibPaths = collectCalibrationPaths(calib_path);
if isempty(calibPaths), error('You told me no need for calibration, but no calibration files were found!!!!'), end
params = cellfun(@(X) {load(X)}, calibPaths);

%% Get the skeleton
% skeleton = load('rat16.mat');
skeleton = load('com');

%% Start label3d from scratch
f = warndlg('Close ONLY when you finish, do not close the other windows. This will go on saving the data!!', 'A Warning Dialog');
labelGui = Label3D(params, videos, skeleton);
waitfor(f);
labelGui.exportDannce('framesToLabel', framesToLabel)
disp('Label3D_dannce.mat file Exported')
% %%
% f = warndlg('Close ONLY when you finish, do not close the other windows. This will go on saving the data!!', 'A Warning Dialog');
% 
% if ~run_existing
%     %% Start Label3D from scratch
%     close all
% 
%     %       disp('This prints immediately');
%     %       waitfor(f);
%     %       disp('This prints after the warning dialog is closed');
% 
% 
%     labelGui = Label3D(params, videos, skeleton);
% %     waitfor(evalin('caller', 'exist(''labelGui.h'',''var'')'), 0)
% %     waitfor(f);
%     open('labelGui')
%     % labelGui = Label3D(params, videos, skeleton, 'sync', sync, 'framesToLabel', framesToLabel);
% else
%     %% From file
%     close all
%     file_name = input('Please provede the FULLPATH name of the label3D file: (something like: ''D:/test/20220417_143732_Label3D.mat'') \n');
%     if ~ischar(file_name), keyboard, error('Please provide name with quotation marks'), end
% %     file_name = '20220417_143732_Label3D.mat';
%     full_file_name = [file_name];
% 
%     if do_save_new_label_3d_temp
%         temp = load(full_file_name);
%         % read frames that have been analyzed already
%         n_frames_in = size(temp.data_3D,1);
%         n_new_frames = length(frovs);
%         % add new vars
%         new_data3d = nan(n_new_frames, size(temp.data_3D,2));
%         s_status = size(temp.status);
%         new_status = zeros(s_status(1), s_status(2), n_new_frames);
% 
%         temp_str = strsplit(file_name, '.');
%         new_file_name = [temp_str{1}, '_pain_frames.mat'];
% 
%         % save vars
%         skeleton = temp.skeleton;
%         status = cat(3,temp.status,new_status);
%         imageSize = temp.imageSize;
%         cameraPoses = temp.cameraPoses;
%         data_3D = cat(1,temp.data_3D, new_data3d);
%         camParams = temp.camParams;
%         save(new_file_name, 'status', 'imageSize', 'cameraPoses', 'data_3D', 'camParams', 'skeleton')
% 
%         full_file_name = new_file_name;
%     end
%     labelGui = Label3D(full_file_name, videos);
% %     waitfor(f);
% end
% waitfor(f);

% %% save dannce
% dannce_save = questdlg('Do you want to save as Dannce?');
% if strcmp(dannce_save, 'Yes')
% %     load('frames_to_labels_new.mat');
%     fprintf(' saving Label3D \n')
%     labelGui.exportDannce('framesToLabel', framesToLabel)
%     fprintf('%%%% DONE, move forward with DANNCE %%%%\n')
% end

%% Save properties
% labelGui.savePath = fullfile (projectFolder, filesep, '_Label3D_COM');
% labelGui.saveAll();
%% Check the camera positions
% labelGui.plotCameras

%% If you just wish to view labels, use View 3D
% close all
% viewGui = View3D(params, videos, skeleton);

%% You can load both in different ways
% close all;
% View3D()


% end