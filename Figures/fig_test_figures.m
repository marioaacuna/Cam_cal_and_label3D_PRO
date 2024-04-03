%% Run after load_3D_DANNCE_data.m
animal_ID ='mouse2';
data_rootpath = fullfile('T:\Mario\DANNCE\predictions', animal_ID);
pts3d_path = fullfile(data_rootpath,'save_data_AVG0.mat');
comPath = fullfile(data_rootpath,'com3d_used.mat');

pts3d = load(pts3d_path);
COMs = load(comPath);
preds = pts3d.pred;
com = COMs.com;
data_3d =preds + com;
n_frames = size(data_3d,1);
fr = 30;


%% Run dim red
mk_vid_trac_vel = 1;
clc
data_n = reshape(data_3d,[], n_frames,1);
% normalize data
N = (data_n);
x = linspace(0, size(data_n,2) / fr, size(data_n,2));
%% PCA
% this will allow you to read the frame-by-frame eigenpostures
% run pca to obtain the 5 first eigenpostures
[P, eigenpostures,latent, tsquared, explained, mu] = pca(N', 'NumComponents',5, 'Algorithm', 'eig');
figure, imagesc(eigenpostures')
% matrix multiplication
% score = bsxfun(@times,pca_data,data_norm.');
% score = pca_data' .* data_norm;
% score = P * N;
% score = S.' * N;
%% TSNE
% Make tsne embeddings of pose kinematicson the eigenpostures
tsne_eigenpostures = tsne(eigenpostures, 'NumPCAComponents',2, 'Perplexity', 30);
figure, scatter(t_pca(:,1), t_pca(:,2),4,'o', 'filled')

%% CWT
% Run cwt to obtain the kinematics of variation of postures in time
% data is at 30hz, get 15 scales spaced from 33ms to 1
widths = linspace(10, 30, 15);
cwt_eigen = [];
for ip = 1:size(eigenpostures,2)
   cmatrix = cwt(eigenpostures(:,ip), 'bump',30, seconds(widths/1000));
%    cwt_d = cwtft(eigenpostures(:,1));
%    cmatrix = cwt_d.cfs;
    cwt_eigen =  [cwt_eigen,cmatrix];
end
% Concatenate and zscore wavelets
wavelest_stand = zscore(cwt_eigen);
[~,pca_wavelet] = pca(wavelest_stand', 'NumComponents',5, 'Algorithm', 'eig');
tsne_em_dynamics = tsne(pca_wavelet,'NumPCAComponents',2, 'Perplexity', 30);
% figure, imagesc(S', 'Interpolation','nearest')
%
%%
% P = tsne(N', "NumPCAComponents",2, 'Exaggeration',5, 'NumDimensions',2, 'Perplexity',20, 'LearnRate',1000, 'Distance','cityblock');
% figure, scatter(P(:,1), P(:,2), 'filled')               


%%
%%velocity

FR = 30;
t = linspace(1,n_frames / FR, n_frames);
dt = 1/FR;
%% plot velocity of all bodyparts
figure
v = [];
for ip = 1:11 %npoints
    clear x, clear y,clear z
    x = smooth(data_3d(:,1,ip),0.5*FR); % n_frames, 3d, ipoint
    y = smooth(data_3d(:,2,ip),0.5*FR);
    z = smooth(data_3d(:,3,ip),0.5*FR);
    d = [];
    for id = 1:n_frames-1
        a = [x(id), y(id), z(id)];
        b = [x(id+1), y(id+1), z(id+1)];

        d(id) = norm(a -b);
    end
    v(:, ip) = d/dt;
    %%

    plot(t(1:end-1), v(:, ip))
    hold on
end
hold off
legend(skeleton.joint_names)
ylabel('Vel (mm/s)')
xlabel('time (s)')
box off
%% study distance of nose and left leg
nose= 2;%3
l_leg = 9; %13
% nose positions
xn = data_3d(:,1,nose); % n_frames, 3d, ipoint
yn = data_3d(:,2,nose);
zn = data_3d(:,3,nose);
% leg positions
xl = data_3d(:,1,l_leg); % n_frames, 3d, ipoint
yl = data_3d(:,2,l_leg);
zl = data_3d(:,3,l_leg);

% calculate distance
dn_l = [];
for id = 1:n_frames
    a = [xn(id), yn(id), zn(id)];
    b = [xl(id), yl(id), zl(id)];

    dn_l(id) = norm(a-b);
end

%% plot distance
figure
plot(t, smooth(dn_l, 10))
title('distance between nose and left leg')
ylim([0 (max(dn_l) + (max(dn_l)/4))])
ylabel('distance (mm)')
xlabel('time (s)')
box off

%% plot average velocity
figure
plot(t(1:end-1), smooth(mean(v,2),50))
title('average velicity of all points')
% ylim([0 (max(dn_l) + (max(dn_l)/4))])
ylabel('velocity (mm/s)')
xlabel('time (s)')
box off

%% Collect animation
aniName = '*.avi';
aniPaths = collectVideoPaths(data_rootpath,aniName);
ani_filename = cell2mat(aniPaths(endsWith(aniPaths, ['sk', '.avi'])));
ani =  VideoReader(ani_filename);
%% make figure
% close all

n_frames = ani.NumFrames;


if mk_vid_trac_vel

    Fig_vids = figure('Position',[20 20 1800 850], 'Visible','on');
    ax1 = subplot(1,2,1);
    ax2 = subplot(1,2,2);
    % Init video
    vel_s = smooth(mean(v,2),50);
    clear F
    writerObj = VideoWriter(fullfile(data_rootpath,'Vel_animation2.avi'));
    writerObj.Quality = 80;

    open(writerObj);

    for iframe = 1:n_frames-1
        axes(ax1)
        hold on
        cla(ax1)
        plot(t(1:end-1), smooth(mean(v,2),50), 'b');
        hold on
        plot(t(iframe), vel_s(iframe), 'ro', 'MarkerSize',8, 'MarkerFaceColor','r');
        title('average velicity of all points')
        % ylim([0 (max(dn_l) + (max(dn_l)/4))])
        ylabel('velocity (mm/s)')
        xlabel('time (s)')
        box off
        axis square
        hold off


        this_frame = read(ani, iframe);
        h2 = imagesc(ax2,this_frame);
       
        title('Animation')
        % set
        set(ax1,'box', 'off')
        set(ax2,'box', 'off')
        sgtitle('Velocity and 3D animation')
        F(iframe)= getframe(Fig_vids);
        writeVideo(writerObj, F(iframe))
    end
    close(writerObj);
    % make vid
    %%
%     try
%         writeVideo(writerObj, F(1:1000)) % for some reasons if it's the whole video it runs out of memory
%         close(writerObj);
%     catch
%         close(writerObj);
%         keyboard
%     end








end








