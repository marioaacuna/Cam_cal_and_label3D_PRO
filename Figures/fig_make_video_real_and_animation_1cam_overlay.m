%% Preamble
% This script willload videos and make figure with real video and 3d
% animation. It will only do half of the video. You can chose the
% downsampling factor to do it faster.
% The inputs needed are the prediction.mat file from the
% makeStructuredDataNoMocap.py
% example:$ python C:\Users\acuna\Repositories\dannce-release_development\dannce\utils\makeStructuredDataNoMocap.py 
% D:\DANNCE\240207\test_1\DANNCE_ready\DANNCE\predict_results\save_data_AVG0.mat 
% C:\Users\acuna\Repositories\Cam_cal_and_label3D_PRO\Label3D\skeletons\mouse22.mat 
% D:\DANNCE\240207\test_1\DANNCE_ready\Label3D_dannce.mat  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
global GC
clc
close all force
debug = 0;
first_frame = 1000;
end_frame = 2000;
output_video_name = '_continued_fullmodel'; % normally this is the net you trained with

warning('off')
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

% prediction_folder = 'predict_results_with_net_5';

cam_to_select= [1]; % One of the 6 cams
FR_to_downsample  = 100;% 120


%%
% data_rootpath = fullfile(root_folder, date, animal_ID, 'DANNCE_ready');
data_rootpath = uigetdir('H:\DANNCE', 'Root path for Project');
prediction_folder = uigetdir(data_rootpath,'Predict results');
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

%sklton = 'rat16.mat';
% sklton = 'jesse_skeleton.mat'; % for net weights.rat.AVG.6cam.hdf5
sklton = 'mouse22.mat';
skeleton = load(sklton);
% predictions
rootpath = prediction_folder;
filename_predictions = fullfile(rootpath,"predictions.mat");
preds = load(filename_predictions);
positions = preds.predictions;

% Positions of interest
try
    pos_interest =cat(3, positions.Snout, positions.HindpawL);
catch % special skeleton
    pos_interest =cat(3, positions.HeadF, positions.SpineM);
end
%% Cemera parameters
this_camera = preds.cameras.(['Camera', num2str(cam_to_select)]);
K = this_camera.IntrinsicMatrix;
R =  this_camera.rotationMatrix;
t = this_camera.translationVector;


M = [R; t] * K;

% load intrinsicbridg
% intrinsic = load('H:\DANNCE\230508\animalX\cameras_calibration\calibration\cam1_params.mat');
% cameraParameters
% cameraParams = cameraParameters(K=K, ...
% %       RadialDistortion=radialDistortion, ImageSize=[720 1280])
% intrinsic = cameraIntrinsics;
K1 = K';
% K1(2,1) = 0;
% K1(3,1) = 0;
% K1(3,2)= 0;

try
    camparams = cameraParameters(K = K1, RadialDistortion = this_camera.RadialDistortion,...
        TangentialDistortion= this_camera.TangentialDistortion);

catch
    camparams = cameraParameters(IntrinsicMatrix = K, RadialDistortion = this_camera.RadialDistortion,...
        TangentialDistortion= this_camera.TangentialDistortion);

end
%% get the frames to show

n_frames_ori = size(pos_interest,1);

downsample_to = round(vid1.FrameRate / FR_to_downsample);
% end_frame = round(n_frames_ori/1);


frames = [first_frame: downsample_to:end_frame];
n_frames = length(frames);



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
writerObj = VideoWriter(fullfile(data_rootpath,[date_now, '_',output_video_name]), 'MPEG-4');
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
    names = fieldnames(preds.predictions);
    names(ismember(names, 'sampleID')) = [];
    handles_here = cell(1,numel(names));
    ind_to_plot = this_frame_idx;
    pts_this_frame = NaN(numel(names),3);
    %     title(ax, str_title, 'Color','w')
    for jj = 1:numel(names)
        % don't plot markers that drop out
        % if ~isnan(sum(preds.predictions.(names{jj})(ind_to_plot,:),2))
        if (~sum(preds.predictions.(names{jj})(ind_to_plot,:),2) == 0)
            xx = squeeze(preds.predictions.(names{jj})(ind_to_plot,1));
            yy = squeeze(preds.predictions.(names{jj})(ind_to_plot,2));
            zz = squeeze(preds.predictions.(names{jj})(ind_to_plot,3));
            % handles_here{jj} = line(xx,yy,zz,'Marker','o','Color',skeleton.color(jj,:),'MarkerFaceColor',skeleton.color(jj,:),'MarkerSize',5);
            pts_this_frame(jj,:) = [xx,yy,zz];
            


            hold on
            marker_plot(jj) = 1;
        else
            marker_plot(jj) = 0;
        end

        % end
    end

    pts = pts_this_frame;
    projPts = [pts, ones(size(pts, 1), 1)] * M;
    projPts(:, 1:2) = projPts(:, 1:2) ./ projPts(:, 3);
    scatter(projPts(:,1), projPts(:,2), 'ro', 'filled', 'Marker','o')

    %% plot the links between markers
    links = skeleton.joints_idx;
    colors = skeleton.color;
    n_links = length(links);
    for mm = 1:(n_links)
        %         if numel(mocapstruct.links{mm})
        %             if (ismember(mocapstruct.links{mm}(1),1:numel(mocapstruct.markernames)) && ismember(mocapstruct.links{mm}(2),1:numel(mocapstruct.markernames)))
        %                 if (marker_plot(mocapstruct.links{mm}(1)) == 1 && marker_plot(mocapstruct.links{mm}(2)) == 1)

        xx = [squeeze(preds.predictions.(names{links(mm,1)})(ind_to_plot,1)) ...
            squeeze(preds.predictions.(names{links(mm,2)})(ind_to_plot,1)) ];
        yy = [squeeze(preds.predictions.(names{links(mm,1)})(ind_to_plot,2)) ...
            squeeze(preds.predictions.(names{links(mm,2)})(ind_to_plot,2)) ];
        zz = [squeeze(preds.predictions.(names{links(mm,1)})(ind_to_plot,3)) ...
            squeeze(preds.predictions.(names{links(mm,2)})(ind_to_plot,3)) ];

        % x
        pts = [xx(1), yy(1), zz(1)];      

        projPts = [pts, ones(size(pts, 1), 1)] * M;
        projPts(:, 1:2) = projPts(:, 1:2) ./ projPts(:, 3);

        pts2  =[xx(2), yy(2), zz(2)];
        projPts2 = [pts2, ones(size(pts2, 1), 1)] * M;
        projPts2(:, 1:2) = projPts2(:, 1:2) ./ projPts2(:, 3);
        
        xx = [projPts(1), projPts2(1)];
        yy = [projPts(2), projPts2(2)];
        zz = [projPts(3), projPts2(3)];
        this_color = colors(mm, 1:3);
        line(xx,yy,'Color',this_color,'LineWidth',1);
        
        % end
        % y

        % keyboard

        
        %                 end

        %             end
        %         end
    end

    %new
    % zlim([-20 180])
    % xlim([-200 200])
    % ylim([-220 220])
    % view([-22, 12]);
    % view([5, 5]);

    % set(ax2,'XTickLabels',[],'YTickLabels',[],'ZTickLabels',[])
    
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

end
toc
if ~debug
    close(writerObj);
end
clear F
if ~debug
    close(w)
end






