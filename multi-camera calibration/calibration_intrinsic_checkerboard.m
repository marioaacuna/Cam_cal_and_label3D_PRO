function calibration_intrinsic_checkerboard(date, num_cams, rootfolder, animal_ID)
%% Find the camera intrinsic parameters
% Input Parameters

close all
clc
tic
fprintf('%%%% Running Intrinsic calibration %%%%\n')
%%
% addpath(genpath('C:\Users\acuna\Documents\dannce\calibration'))
%date = '220414';
plot_projections = 1;
% basedir = fullfile(rootfolder,date,animal_ID,'intrinsic');
basedir = fullfile(rootfolder);
d = {dir(basedir).name}; d = d(endsWith(d, '.mp4'));
% basedir = fullfile('D:\cam_calibration', filesep, [date, '_calibration'], filesep, 'intrinsic');
% cd(basedir)
numcams = numel(d);

squareSize = 10.0; % Size of Checkerboard squares in mm
ext = '.mp4';
maxNumImages = 1500;
% videoName = '0';
%% Automated Checkerboard Frame Detection
% Pre-allocate
params_individual = cell(1,numcams);
estimationErrors = cell(1,numcams);
imagePoints = cell(1,numcams);
boardSize = cell(1,numcams);
imagesUsed = cell(1,numcams);
imageNums = cell(1,numcams);

clear video_temp
for kk = 1:numcams
    tic
    this_cam = d{kk};
    video_temp = VideoReader(fullfile(basedir, this_cam)); %#ok<*TNMLP>
    maxFrames = floor(video_temp.FrameRate*video_temp.Duration);
      
%     frames_to_take = 1:maxFrames;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % frames_to_take = randperm(maxFrames-1,round(maxFrames/2));
    % video_base = cell(length(frames_to_take),1);
    % for iframe = 1:length(frames_to_take)
        % this_frame = frames_to_take(iframe);
        % video_base{iframe}= read(video_temp, this_frame);
    % end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% OLD
    video_base = cell(maxFrames,1);
    cnt = 1;
    while hasFrame(video_temp)
        video_base{cnt} = readFrame(video_temp,'native');
        cnt = cnt + 1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    % num2use = length(video_base)/2;
    num2use = 1250;
    % clear video_temp

    imUse1 = round(linspace(1,length(video_base),num2use));
    fprintf('Finding checkerboard points for view %i \n', kk)
    [imagePoints{kk}, boardSize{kk}, imagesUsed{kk}] = ...
        detectCheckerboardPointsPar(cat(4,video_base{imUse1}));
    
    %%%%%%%
    % Mario (fix a problem with image idxs)
    im_idx_temp = zeros(length(video_base),1);
    im_idx_temp(imUse1) = 1;
    imagesUsed{kk} = im_idx_temp;
    %%%%%%%%
    
    worldPoints = generateCheckerboardPoints(boardSize{kk},squareSize);
    % imagesUsedTemp = find(imagesUsed{kk});
    imagesUsedTemp = 1:numel(imagePoints{kk}(1,1,:));
    numImagesToUse = min([maxNumImages numel(imagesUsedTemp)]);
    % numImagesToUse = maxFrames;
    [~,imageNums{kk}] = datasample(imagesUsedTemp,numImagesToUse,'Replace',false);
    
    disp(['Images used for view ' num2str(kk) ': ' num2str(numel(imageNums{kk}))]);
    I = video_base{1};
    imageSize = [size(I,1),size(I,2)];
    [params_individual{kk},pairsUsed,estimationErrors{kk}] = estimateCameraParametersPar(imagePoints{kk}(:,:,imageNums{kk}),worldPoints, ...
        'ImageSize',imageSize,'EstimateSkew',true,'EstimateTangentialDistortion',true,...
        'NumRadialDistortionCoefficients',3);
%     toc
end


%% Visualize Preprojections
% cd(basedir)
% load([basedir,  filesep 'cam_intrinsics.mat'])
% numcams = 3;
if plot_projections
    for kk = 1:numcams
        this_cam = d{kk};
        video_temp = VideoReader(fullfile(basedir, this_cam)); %#ok<*TNMLP>
        % video_temp = VideoReader([basedir filesep 'cam' num2str(kk),'.mp4']);
        %     video_temp = VideoReader([basedir 'view_cam' num2str(kk) '.mp4']);
        maxframes = floor(video_temp.FrameRate*video_temp.Duration);
        video_base = cell(maxframes,1);
        cnt = 1;
        while hasFrame(video_temp)
            video_base{cnt} = readFrame(video_temp,'native');
            cnt = cnt + 1;
        end

        clear M
        figure;
        %     imagesUsed_ = find(imagesUsed{kk});
        imagesUsed_ = imageNums{kk};
        imagesUsedFull_ = find(imagesUsed{kk});
        % imagesUsedFull_ = imUse1;
        imagesUsedFull_ = imagesUsedFull_(imagesUsed_);
        title(this_cam)
        for im2use = 1:20%numel(imagesUsed_)
            imUsed = imagesUsed_(im2use);
            imDisp = imagesUsedFull_(im2use);
            pts = imagePoints{kk}(:,:,imUsed);
            repro = params_individual{kk}.ReprojectedPoints(:,:,im2use);
            imagesc(video_base{imDisp});colormap(gray)
            hold on;
            plot(pts(:,1),pts(:,2),'or');
            plot(repro(:,1),repro(:,2),'xg');
            drawnow;
            M(im2use) = getframe(gcf);
        end

        % write reproject video
        %vidfile = [basedir 'reproject_view' num2str(kk) '.mp4'];
        %vk = VideoWriter(vidfile);
        %vk.Quality = 100;
        %open(vk)
        %writeVideo(vk,M);
        %close(vk);

    end
    %% View Undistorted Images
    % load([basedir, filesep, 'cam_intrinsics.mat'])
%     load('D:\cam_calibration\220414_calibration\intrinsic\cam_intrinsics.mat')
    for kk=1:numcams
        this_cam = d{kk};
        imFiles1 = VideoReader(fullfile(basedir, this_cam),'CurrentTime',25);% 0.6
        figure(kk);
        im = readFrame(imFiles1,'native');
        subplot(121);imagesc(im);
        
        subplot(122);imagesc(undistortImage(im,params_individual{kk}));
        title(this_cam)
    end


end
toc
%% Check for distorted camera parameters
% Radial Distortion - its 1x3 vector. with values of  -0.3571    0.2140
% -0.1034
keyboard
% Loop through cameras
for kk=1:numcams
    flag_bad_params = any(params_individual{kk}.RadialDistortion>1);
    % We flag for larger than 1 values, and [neg,pos,neg] sequence
    flag_bad_sequence = sum([params_individual{kk}.RadialDistortion(1)<0, ...
        params_individual{kk}.RadialDistortion(2)>0,...
        params_individual{kk}.RadialDistortion(3)<0])~=3;

    if flag_bad_sequence || flag_bad_params
        keyboard
        % change Radial Distortion or Run the camera again
        init_rad = [-0.3571, 0.2140, -0.1034];
        
        % Convert parameters into a struct
        param_struct = params_individual{kk}.toStruct();
        param_struct.RadialDistortion = init_rad;

        % Convert it back to CameraParameters
        params_individual{kk} = cameraParameters(param_struct);

        % Plot it
        imFiles1 = VideoReader([basedir filesep 'cam' num2str(kk),'.mp4'],'CurrentTime',0.6);
        figure;
        im = readFrame(imFiles1,'native');
        subplot(121);imagesc(im);
        subplot(122);imagesc(undistortImage(im,params_individual{kk}));
        title(['cam', num2str(kk)])
    end
end
% keyboard

%% Save the camera parameters
save(fullfile(basedir,'cam_intrinsics.mat'),'params_individual','imagePoints','boardSize','imagesUsed','imageNums', 'estimationErrors');


end

















