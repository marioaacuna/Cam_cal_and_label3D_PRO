% this script will load the GUI and from previous saveed version
%
clear
% [~, p] = fileparts(pwd);
% if ~strcmp(p, 'Cam_cal_and_label3D_Nevian')
%     error('Please cd to Cam_cal_and_label3D_Nevian and start from there')
% end
%%
addpath(genpath('Label3D'))
close all
% load label3d
[file_name, path] = uigetfile('.mat', 'Label3D.mat you want to load (Usually in _temp folder)');
full_file_name = fullfile(path, file_name);
% load videos
[videosfile, path] = uigetfile('videos.mat', 'Where videos are (Usually in Labeled_frames folder)');
videos_fullfile = fullfile(path, videosfile);

videos = load(videos_fullfile, 'videos');
videos = videos.videos;
% Frames
frames_fullfile  = fullfile(path, 'frames_to_label.mat');
framesToLabel = load(frames_fullfile);
framesToLabel  = framesToLabel.framesToLabel;

%% increase brightness videos
% this is because some videos are kinda dark
% disp('increasing brightness')
% videos_high = cell(6,1);
% for icam = 1:size(videos,1)
%     m1 = videos{icam};
% 
%     for iframe = 1:size(m1,4)
%         this_frame=   m1(:,:,:,iframe) + 50;
%         mhigh(:,:,:,iframe) = this_frame;
% 
%     end
%     videos_high(icam)= {mhigh};
%     clear mhigh
% end
% clear mhigh
% disp('done')

%% Run label gui
disp('Loading GUI')
% f = warndlg('Close ONLY when you finish, do not close the other windows. This will go on saving the data!!', 'A Warning Dialog');
labelGui = Label3D(full_file_name, videos);
waitfor(labelGui);
labelGui.exportDannce('framesToLabel', framesToLabel)
disp('Label3D_dannce.mat file Exported')
