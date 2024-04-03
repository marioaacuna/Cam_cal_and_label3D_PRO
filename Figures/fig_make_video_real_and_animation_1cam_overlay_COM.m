%% Preamble
% This script willload videos and make figure with real video and 3d
% com. It will only do part of the video. You can chose the
% downsampling factor to do it faster.
% 
clear
global GC

clc
close all force
debug = 0;
if debug
    visibility = 'on';
else
    visibility = 'off';
    w = waitbar(0, 'Processing frames...');
end

%% Inputs
% animal_ID = 'animalX';
% date = '230508';
% root_folder = 'H:\DANNCE\';
% 'H:\DANNCE\230508\animalX\DANNCE_ready\DANNCE\predict_results'
prediction_folder = 'predict_results';
cam_to_select= [3]; % One of the 6 cams
FR_to_downsample  = 30;% 120

% select frames
downsample_to = round(120 / FR_to_downsample);

end_frame = 7000;
first_frame = 1;
frames = [first_frame: downsample_to:end_frame];
n_frames = length(frames);

%%
temp_root = fullfile(GC.temp_root, 'out_videos');
if ~exist(temp_root, 'dir')
    mkdir(temp_root)
end
% data_rootpath = fullfile(root_folder, date, animal_ID, 'DANNCE_ready');
data_rootpath = uigetdir(GC.temp_root, 'Root path for Project');
repo_path = GC.repository_root_path;
addpath(repo_path)
addpath(genpath(fullfile(repo_path,'Label3D', 'deps')))
addpath(genpath(fullfile(repo_path,'Label3D' , 'skeletons')))
rmpath(genpath(fullfile(repo_path,'Label3D','deps','Animator')))

%% collect mp4
vidName = '*.mp4';
vidPaths = collectVideoPaths(data_rootpath,vidName);
% ori_video = cell2mat(vidPaths(endsWith(vidPaths, [num2str(cam_to_select), '.mp4'])));
if length(cam_to_select) == 1
    vid1 = VideoReader(vidPaths{cam_to_select});
else
    vid1 = VideoReader(vidPaths{cam_to_select(1)});
    vid2 = VideoReader(vidPaths{cam_to_select(2)});
end
%% collect 3d animation
FR = 30;

% sklton = 'com.mat';
% skeleton = load(sklton);
% predictions
rootpath = fullfile(data_rootpath,'COM', prediction_folder);
filename_predictions = fullfile(rootpath,"com3d.mat");
preds = load(filename_predictions);
positions = preds.com;


%% Cemera parameters
% this_camera = preds.cameras.(['Camera', num2str(cam_to_select)]);
label3d = load(fullfile(data_rootpath, "Label3D_dannce.mat"));
campars = label3d.params;
this_camera = campars{cam_to_select};
K = this_camera.K;
R =  this_camera.r;
t = this_camera.t;


M = [R; t] * K;

% load intrinsic
% intrinsic = load('H:\DANNCE\230508\animalX\cameras_calibration\calibration\cam1_params.mat');
% cameraParameters
% cameraParams = cameraParameters(K=K, ...
% %       RadialDistortion=radialDistortion, ImageSize=[720 1280])
% intrinsic = cameraIntrinsics;
K1 = K';
% K1(2,1) = 0;
% K1(3,1) = 0;
% K1(3,2)= 0;

% for some reason when running from GPU pc K is not recognize
camparams = cameraParameters(IntrinsicMatrix=K, RadialDistortion = this_camera.RDistort,...
    TangentialDistortion= this_camera.TDistort);

% camparams = cameraParameters(K=K1, RadialDistortion = this_camera.RDistort,...
%     TangentialDistortion= this_camera.TDistort);
%% get the frames to show

% n_frames_ori = size(pos_interest,1);




%% make figure
close all

Fig_vids = figure('Position',[20 20 1800 850], 'Visible',visibility);
ax1 = subplot(1,1,1);
% ax2 = subplot(1,3,2);
% if length(cam_to_select) > 1
%     ax3 = subplot(1,3,3);
% end

%% Init video
tic
% iid = 0;
clear F
data_now =  datestr(now);
date_now = strrep(data_now, ':', '_');
writerObj = VideoWriter(fullfile(data_rootpath,['Check_preds_Overlay','_COM_-', date_now]), 'MPEG-4');
writerObj.Quality = 100;
writerObj.FrameRate = FR_to_downsample;
if ~debug
    open(writerObj);
end

for iframe = 1:n_frames% hasFrame(vid) && hasFrame(ani)
    % iid = iid +1;
    % plot real
    this_frame_idx = frames(iframe);
    this_frame = read(vid1, this_frame_idx);

    h1 = imagesc(ax1,undistortImage(this_frame, camparams));
    hold on
    % h1 = imagesc(ax1,this_frame);
    % this_frame = read(vid2, this_frame_idx);
    % h3 = imagesc(ax2,this_frame);
    %     axis off
    %     title(ax1,['Real cam_',num2str(cam_to_select)], 'Interpreter','none')

    % axis(ax2, 'square')
    % axis(ax2, 'square')
    %% Plot the animation next to it
    % axis(ax3,'manual')
    % set(ax3,'Color','k')
    % grid off;
    % axis off
    % set(ax3,'Xcolor',[1 1 1 ]);
    % set(ax3,'Ycolor',[1 1 1]);
    % set(ax3,'Zcolor',[1 1 1]);
    % cla(ax3)
    % set(ax3,'Nextplot','ReplaceChildren');
    pts_this_frame = positions(this_frame_idx,:);
    pts = pts_this_frame;
    projPts = [pts, ones(size(pts, 1), 1)] * M;
    projPts(:, 1:2) = projPts(:, 1:2) ./ projPts(:, 3);
    scatter(projPts(:,1), projPts(:,2), 'ro', 'filled', 'Marker','o')

    
    axis off
    drawnow
    hold off

    try
        text(-80.1,-50.10,num2str(this_frame_idx), 'color', 'w')
    catch
        keyboard
    end

    sgtitle({prediction_folder;['Frame : ', num2str(this_frame_idx)]})
    % axis(ax3, 'square')
    % axis(ax2, 'square')
    axis(ax1, 'square')
    % set
    set(ax1,'box', 'off')
    % set(ax2,'box', 'off')
    % set(ax3,'box', 'off')
    %     set(ax1,'axis', 'off')
    %     set(ax2,'axis', 'off')

    %     sgtitle('Real video and its animation in 3D using DANNCE')
    %     F(iid) = ;
    if ~debug
        writeVideo(writerObj,getframe(Fig_vids))
        waitbar(iframe/n_frames, w); % Update status bar
    end
%     keyboard
end
toc
if ~debug
    close(writerObj);
end
clear F
close w






