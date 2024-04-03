clc
clear
cd('T:\Marta\Cam_cal_and_label3D_Nevian')
addpath('Label3D')
addpath(genpath([pwd,'\Label3D\deps']))
addpath(genpath([pwd,'\Label3D\skeletons']))

% input video
projectFolder='T:\Marta\test_Formalin\dannce\040822\MF_1epi';
% output temp label3d
new_file_name = ['T:\Marta\test_Formalin\dannce\040822\MF_1epi\', 'temp_label_3D_normal_plus_pain_frames.mat'];

%% load first labeling
fames_pain = load('T:\Marta\test_Formalin\dannce\040822\MF_1epi\Labeled_frames\frames_to_label_pain.mat');
label_3d_pain = load('T:\Marta\test_Formalin\dannce\040822\MF_1epi\20220830_142927_Label3D.mat');
%% load pain labeling
frames_ori = load('T:\Marta\Cam_cal_and_label3D_Nevian\Label3D\frames_to_labels_new_20min.mat');
label_3d_ori = load('T:\Marta\test_Formalin\dannce\040822\MF_1epi\20220824_132812_Label3D.mat');

%% merge labelings
% merge pain into ori
n_frames_in = size(label_3d_ori.data_3D,1);
n_new_frames = size(label_3d_pain.data_3D,1);
% add new vars
new_data3d = label_3d_pain.data_3D;
new_status = label_3d_pain.status;

% Join all vars
status = cat(3,label_3d_ori.status,new_status);
imageSize = label_3d_ori.imageSize;
cameraPoses = label_3d_ori.cameraPoses;
data_3D = cat(1,label_3d_ori.data_3D, new_data3d);
camParams = label_3d_ori.camParams;

% delete frames that are not labeled to save time
non_frames = isnan(data_3D(:,1));
status = status(:,:,~non_frames);
data_3D = data_3D(~non_frames,:);

% Skeleton
skeleton = label_3d_pain.skeleton;
% save temp file
save(new_file_name, 'status', 'imageSize', 'cameraPoses', 'data_3D', 'camParams', 'skeleton')
disp('saved temp file')

%% Concat videos
% Read the videos from the folder
vidName = '*.mp4';
vidPaths = collectVideoPaths(projectFolder,vidName);
videos = cell(length(vidPaths),1);
fprintf('Wait a sec, loading videos \n')

% get the frames
concat_frames = cat(2, frames_ori.framesToLabel, fames_pain.framesToLabel);
concat_frames = concat_frames(~non_frames);

fprintf('Num frames set to %i\n', length(concat_frames))
addpath(genpath([pwd,'\Label3D\deps']))

for nVid = 1:numel(vidPaths)
    disp(['vid ', num2str(nVid)])
    videos{nVid} = readFrames(vidPaths{nVid} ,concat_frames);
end

disp('Done loading videos')

%% run label3d
labelGui = Label3D(new_file_name, videos);


%% export label 3d
fprintf(' saving Label3D \n')
labelGui.exportDannce('framesToLabel', concat_frames)
fprintf('%%%% DONE, move forward with DANNCE %%%%\n')