%% Preamble
% This script willload videos and make figure with real video and 3d
% animation. It will only do half of the video. You can chose the
% downsampling factor to do it faster.
% The inputs needed are the prediction.mat file from the
% makeStructuredDataNoMocap.py (done in GPU PC)

clear
clc
close all
debug = 1;
if debug
    visibility = 'on';
else
    visibility = 'off';
end

%% Inputs
animal_ID = '328';
date = '230428';
root_folder = 'H:\DANNCE\';
% 'H:\DANNCE\230508\animalX\DANNCE_ready\DANNCE\predict_results'
prediction_folder = 'predict_results';
cam_to_select= [1,3]; % One of the 6 cams
FR_to_downsample  = 30;% 3


%%
data_rootpath = fullfile(root_folder, date, animal_ID, 'DANNCE_ready');
repo_path = pwd;
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

sklton = 'rat16.mat';
skeleton = load(sklton);
% predictions
rootpath = fullfile(data_rootpath,'DANNCE', prediction_folder);
filename_predictions = fullfile(rootpath,"predictions.mat");
preds = load(filename_predictions);
positions = preds.predictions;

% Positions of interest
pos_interest =cat(3, positions.Snout, positions.HindpawL);

%% get the frames to show

n_frames_ori = size(pos_interest,1);

downsample_to = round(vid1.FrameRate / FR_to_downsample);
end_frame = round(n_frames_ori/2);
first_frame = end_frame;
frames = [first_frame: downsample_to:n_frames_ori];
n_frames = length(frames);



%% make figure
close all

Fig_vids = figure('Position',[20 20 1800 850], 'Visible',visibility);
ax1 = subplot(1,3,1);
ax2 = subplot(1,3,2);
if length(cam_to_select) > 1
    ax3 = subplot(1,3,3);
end

%% Init video
tic
% iid = 0;
clear F
data_now =  datestr(now);
date_now = strrep(data_now, ':', '_');
writerObj = VideoWriter(fullfile(data_rootpath,['Check_preds_',animal_ID, '-', date_now]), 'MPEG-4');
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
    h1 = imagesc(ax1,this_frame);
    this_frame = read(vid2, this_frame_idx);
    h3 = imagesc(ax2,this_frame);
    %     axis off
    %     title(ax1,['Real cam_',num2str(cam_to_select)], 'Interpreter','none')

    axis(ax2, 'square')
    axis(ax2, 'square')
    %% Plot the animation next to it
    axis(ax3,'manual')
    set(ax3,'Color','k')
    grid off;
    axis off
    set(ax3,'Xcolor',[1 1 1 ]);
    set(ax3,'Ycolor',[1 1 1]);
    set(ax3,'Zcolor',[1 1 1]);
    cla(ax3)
    set(ax3,'Nextplot','ReplaceChildren');
    names = fieldnames(preds.predictions);
    names(ismember(names, 'sampleID')) = [];
    handles_here = cell(1,numel(names));
    ind_to_plot = this_frame_idx;
    %     title(ax, str_title, 'Color','w')
    for jj = 1:numel(names)
        % don't plot markers that drop out
        % if ~isnan(sum(preds.predictions.(names{jj})(ind_to_plot,:),2))
        if (~sum(preds.predictions.(names{jj})(ind_to_plot,:),2) == 0)
            xx = squeeze(preds.predictions.(names{jj})(ind_to_plot,1));
            yy = squeeze(preds.predictions.(names{jj})(ind_to_plot,2));
            zz = squeeze(preds.predictions.(names{jj})(ind_to_plot,3));
            handles_here{jj} = line(xx,yy,zz,'Marker','o','Color',skeleton.color(jj,:),'MarkerFaceColor',skeleton.color(jj,:),'MarkerSize',5);



            hold on
            marker_plot(jj) = 1;
        else
            marker_plot(jj) = 0;
        end

        % end
    end

    %% plot the links between markers
    links = skeleton.joints_idx;
    for mm = 1:numel(names)
        %         if numel(mocapstruct.links{mm})
        %             if (ismember(mocapstruct.links{mm}(1),1:numel(mocapstruct.markernames)) && ismember(mocapstruct.links{mm}(2),1:numel(mocapstruct.markernames)))
        %                 if (marker_plot(mocapstruct.links{mm}(1)) == 1 && marker_plot(mocapstruct.links{mm}(2)) == 1)

        xx = [squeeze(preds.predictions.(names{links(mm,1)})(ind_to_plot,1)) ...
            squeeze(preds.predictions.(names{links(mm,2)})(ind_to_plot,1)) ];
        yy = [squeeze(preds.predictions.(names{links(mm,1)})(ind_to_plot,2)) ...
            squeeze(preds.predictions.(names{links(mm,2)})(ind_to_plot,2)) ];
        zz = [squeeze(preds.predictions.(names{links(mm,1)})(ind_to_plot,3)) ...
            squeeze(preds.predictions.(names{links(mm,2)})(ind_to_plot,3)) ];
        line(xx,yy,zz,'Color','k','LineWidth',1);
        %                 end

        %             end
        %         end
    end

    %new
    zlim([-20 180])
    xlim([-200 200])
    ylim([-220 220])
    % view([-22, 12]);
    view([5, 5]);

    set(ax2,'XTickLabels',[],'YTickLabels',[],'ZTickLabels',[])
    
    axis off
    drawnow
    hold off

    try
        text(-80.1,-50.10,num2str(this_frame_idx), 'color', 'w')
    catch
        keyboard
    end

    sgtitle({prediction_folder;['Frame : ', num2str(this_frame_idx)]})
    axis(ax3, 'square')
    axis(ax2, 'square')
    axis(ax1, 'square')
    % set
    set(ax1,'box', 'off')
    set(ax2,'box', 'off')
    set(ax3,'box', 'off')
    %     set(ax1,'axis', 'off')
    %     set(ax2,'axis', 'off')

    %     sgtitle('Real video and its animation in 3D using DANNCE')
    %     F(iid) = ;
    if ~debug
        writeVideo(writerObj,getframe(Fig_vids))
    end

end
toc
if ~debug
    close(writerObj);
end
clear F






