function [labelGui, framesToLabel] = RunLabel3D(danncePath,date, mouse_label, run_existing)
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

addpath(genpath([pwd,'\Label3D\deps']))
addpath(genpath([pwd,'\Label3D\skeletons']))
% danncePath = 'T:\Mario\DANNCE';
% danncePath = 'D:\_test_label3D';
% date ='220414';
%% Load in the calibration parameter data
projectFolder = fullfile(danncePath,date, mouse_label);
% calib_path = fullfile(danncePath);
% calib_path = fullfile(danncePath, date);
% cal_path = 'D:\cam_calibration\calibration';
calib_path =['D:\_test_label3D\',date];


%% Load the videos into memory
vidName = '*.mp4';
vidPaths = collectVideoPaths(projectFolder,vidName);
videos = cell(length(vidPaths),1);
% exception due to different folders /| fix later
if run_existing
    sync = collectSyncPaths(projectFolder);
    sync = cellfun(@(X) {load(X)}, sync);
else
    sync = collectSyncPaths(projectFolder,'*.mat');
    sync = cellfun(@(X) {load(X)}, sync);
end
% In case the demo folder uses the dannce.mat data format.
if isempty(sync)
    error('PLEASE CHECK THE SYNC FILES! OR MAKE NEW ONES DIRECLY ON PYTHON!!')
%     error('sync files were not detected, fix it!!')
%     dannce_file = dir(fullfile(projectFolder, '*dannce.mat'));
%     dannce = load(fullfile(dannce_file(1).folder, dannce_file(1).name));
%     sync = dannce.sync;
%     params_dannce = dannce.params;
end
n_frames = size(sync{1}.data_frame,1);
% framesToLabel = 1:100;

%% Get the frames to label
% Here you can actually get some frames of interest and run training with
% specific frames. 

% framesToLabel = [1:3];
frames_path = fullfile(projectFolder, 'Labeled_frames');
if ~exist(frames_path, 'dir')
    mkdir(frames_path)
end

input_frames= input('do you want to LOAD certain frames in the .mat format? (1 yes; 0 no) \n');
if input_frames
    where_frames = input(['Select the path and filename here ' ...
        '(like : "frames_to_label_PAIN.mat") or so \n']);
else
    label_name = input('give a SUFFIX name to the file? if empty it uses the default frames_to_label.mat \n ');
    if ~isempty(label_name)
        where_frames = fullfile(frames_path, ['frames_to_label_',label_name,'.mat']);
    else
        where_frames = fullfile(frames_path, 'frames_to_label.mat');

    end
end

frames_to_label_filename = where_frames;
do_save_new_label_3d_temp =0;
if exist(frames_to_label_filename, 'file')
    
    load(frames_to_label_filename)%, 'frames_to_labels.mat');%, 'frames_to_labels_new_20min.mat');
    create_frames = 0;
    input_table = input('do you want to add new frames to the already saved frame file? (1 yes, 0 no) \n ');

    if input_table
        input_table_dir = input('type the directory of the table, including the table name and extension \n ');
        T = readtable(input_table_dir);
        frovs = T.frameStart(1):T.frameStart(1)+100-1;

        
        framesToLabel  = [framesToLabel, frovs];
        create_frames = 1;
        do_save_new_label_3d_temp =1;
    end

else
    inputframes = input('Do you want to load any specific frame ids to label?? (1 yes, 0 no) \n ');
    if inputframes
        %         input_table = input('do you want to add new frames to an already saved frame file? (1 yes, 0 no) \n ');
        framesToLabel = input('write the frames : in a format like 120:200 OR [123,125,623,etc] \n');
    else
        framesToLabel = randperm(n_frames, 100);
    end
    create_frames = 1;
    
end
% save frames
if create_frames
    save(frames_to_label_filename, 'framesToLabel')
end



%% Load videos and params
fprintf('Wait a sec, loading videos \n')
for nVid = 1:numel(vidPaths)
    disp(['vid ', num2str(nVid)])
    frameInds = sync{nVid}.data_frame(framesToLabel);
    videos{nVid} = readFrames(vidPaths{nVid} , frameInds+1);
end


% load params
calibPaths = collectCalibrationPaths(calib_path);
if isempty(calibPaths), error('You told me no need for calibration, but no calibration files were found!!!!'), end
params = cellfun(@(X) {load(X)}, calibPaths);

%% Get the skeleton
skeleton = load('rat16.mat');
% skeleton = load('com');
f = warndlg('Close ONLY when you finish, do not close the other windows. This will go on saving the data!!', 'A Warning Dialog');

if ~run_existing
    %% Start Label3D from scratch
    close all
   
    %       disp('This prints immediately');
    %       waitfor(f);
    %       disp('This prints after the warning dialog is closed');


    labelGui = Label3D(params, videos, skeleton);
%     waitfor(evalin('caller', 'exist(''labelGui.h'',''var'')'), 0)
%     waitfor(f);
    open('labelGui')
    % labelGui = Label3D(params, videos, skeleton, 'sync', sync, 'framesToLabel', framesToLabel);
else
    %% From file
    close all
    file_name = input('Please provede the FULLPATH name of the label3D file: (something like: ''D:/test/20220417_143732_Label3D.mat'') \n');
    if ~ischar(file_name), keyboard, error('Please provide name with quotation marks'), end
%     file_name = '20220417_143732_Label3D.mat';
    full_file_name = [file_name];

    if do_save_new_label_3d_temp
        temp = load(full_file_name);
        % read frames that have been analyzed already
        n_frames_in = size(temp.data_3D,1);
        n_new_frames = length(frovs);
        % add new vars
        new_data3d = nan(n_new_frames, size(temp.data_3D,2));
        s_status = size(temp.status);
        new_status = zeros(s_status(1), s_status(2), n_new_frames);

        temp_str = strsplit(file_name, '.');
        new_file_name = [temp_str{1}, '_pain_frames.mat'];
        
        % save vars
        skeleton = temp.skeleton;
        status = cat(3,temp.status,new_status);
        imageSize = temp.imageSize;
        cameraPoses = temp.cameraPoses;
        data_3D = cat(1,temp.data_3D, new_data3d);
        camParams = temp.camParams;
        save(new_file_name, 'status', 'imageSize', 'cameraPoses', 'data_3D', 'camParams', 'skeleton')

        full_file_name = new_file_name;
    end
    labelGui = Label3D(full_file_name, videos);
%     waitfor(f);
end
waitfor(f);

%% save dannce
dannce_save = questdlg('Do you want to save as Dannce?');
if strcmp(dannce_save, 'Yes')
%     load('frames_to_labels_new.mat');
    fprintf(' saving Label3D \n')
    labelGui.exportDannce('framesToLabel', framesToLabel)
    fprintf('%%%% DONE, move forward with DANNCE %%%%\n')
end

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


end