%% load videos and make figure with real video and 3d animation
clear
clc
close all
%%
animal_ID = 'mouse2';
date = '220511';
start_frame = 3600;
n_mins_to_take = 1;
end_frame = start_frame + (n_mins_to_take*60)*30; % sec*fps


%%
% cd('C:\Users\acuna\Documents\Cam_cal_and_label3D_Nevian\')
addpath(genpath([pwd,'\Label3D\deps']))
addpath(genpath([pwd,'\Label3D\skeletons']))
rmpath(genpath([pwd,'\Label3D\deps\Animator']))

cam_to_select= 1;
data_rootpath = fullfile('T:\Mario\DANNCE\predictions', animal_ID);
videopath = fullfile('D:\_test_label3D',date, animal_ID);
%% collect mp4
vidName = '*.mp4';
vidPaths = collectVideoPaths(videopath,vidName);
ori_video = cell2mat(vidPaths(endsWith(vidPaths, [num2str(cam_to_select), '.mp4'])));
vid = VideoReader(ori_video);
%% collect 3d animation
aniName = '*.avi';
aniPaths = collectVideoPaths(data_rootpath,aniName);
ani_filename = cell2mat(aniPaths(endsWith(aniPaths, ['sk', '.avi'])));
ani =  VideoReader(ani_filename);
%% make figure
close all

Fig_vids = figure('Position',[20 20 1800 850], 'Visible','on');
ax1 = subplot(1,2,1);
ax2 = subplot(1,2,2);
% Init video

n_frames = ani.NumFrames;
iid = 0;
clear F
writerObj = VideoWriter(fullfile(data_rootpath,'Real_Ani.avi'));
writerObj.Quality = 100;
open(writerObj);
for iframe = 1:n_frames% hasFrame(vid) && hasFrame(ani) 
    this_frame_idx = start_frame + iid;
    iid = iid +1;
    % plot real
    this_frame = read(vid, this_frame_idx);
    h1 = imagesc(ax1,this_frame);
    axis off 
    title(ax1,['Real cam_',num2str(cam_to_select)], 'Interpreter','none')
    % plot animation
    this_frame = read(ani, iframe);
    h2 = imagesc(ax2,this_frame);
    axis off 
    title('Animation')
    % set
    set(ax1,'box', 'off')
    set(ax2,'box', 'off') 
    sgtitle('Real video and its animation in 3D using DANNCE') 
    F(iid) = getframe(Fig_vids);
    writeVideo(writerObj, F(iid))
end
close(writerObj);
% %% make video
% try
%     writerObj = VideoWriter(fullfile(data_rootpath,'Real_Ani.avi'));
%     writerObj.Quality = 80;
%     
%     open(writerObj);
%     writeVideo(writerObj, F(1:1000)) % for some reasons if it's the whole video it runs out of memory
%     close(writerObj);
% catch
%     close(writerObj);
%     keyboard
% end
