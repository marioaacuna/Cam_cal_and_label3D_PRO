function   calibration_extrinsic_Lframe(date, modify_lframe, num_cams, rootfolder, animal_ID)
%% Use predetermined crop ROI parameters to crop a single image of the
% calibration lframe We will use these
% cropped images to determine view extrinsic parameters.

clc
fprintf('%%%% Running extrinsic calibration l-frame %%%%\n')
% Load in the crop params
% date = '220414';

%basedir = fullfile(rootfolder, [date, '_calibration']); %where the lframe videos are
% basedir = fullfile(rootfolder,date,animal_ID);
basedir = fullfile(rootfolder);

% basedir = ['D:\cam_calibration\', [date, '_calibration']]; %where the lframe videos are
numCams = num_cams;
% ext = '.tiff';
ext = '.mp4';

extrinsic_filepath = fullfile(basedir);

% Input the physical (x,y,z) dimensions for each of the post tops on the
% L-frame device.
if modify_lframe
    LFrame_coordinates = input('enter the Lframe post tops = \n');
else
    % new
     LFrame_coordinates = [
         -5.5 0 1;... % 1
        -2.75 0 1;... % 2
        0 0 1;... % ref
        0 3 1;... % 4
        0 6 1;... % 5
        0 8.5 10.1]; % 6
    % old 
%     LFrame_coordinates = [
%          0 -5 0.6;... % 1
%         -0.2, -2.4, 0.02;... % 2
%         0 0 1;... % ref
%         5 -0.2 0.55;... % 4
%         8.5 -0.25 3.5]; % 5
end
%                        8.7 -0.5 3.7];
%                         5 5 10.5];
LFrame_coordinates = 10*(LFrame_coordinates); % cm to mm

numPoints = size(LFrame_coordinates,1);

%convert first frame of each video to tiff
% fileloc = fullfile(extrinsic_filepath, filesep, 'videos');%, filesep 'extrinsic'];
fileloc = extrinsic_filepath;
vidName = '*.mp4';
vidPaths = collectVideoPaths(fullfile(fileloc), vidName);

% cd(fileloc)
for kk = 1:numCams
    %     filename = ['view_' num2str(kk)];
%     filename =  [fileloc, filesep, 'cam',num2str(kk),'_lframe'];
    filename =  [fileloc, filesep, 'cam',num2str(kk)];

    video_temp = VideoReader(vidPaths{kk},'CurrentTime',1); % Take the 20th frame (before set to 1st)
    frame_temp = readFrame(video_temp);
    %imshow(frame_temp)
    imwrite(frame_temp,[filename,'.tiff'])
end

lframe = cell(numCams,1);
for i = 1:numCams
    %     lframe{i} = imread([basedir filesep 'extrinsic' filesep 'view_cam' num2str(i) ext]);
%     lframe{i} = imread([fileloc filesep 'cam' num2str(i) '_lframe.tiff']);
    lframe{i} = imread([fileloc filesep 'cam' num2str(i) '.tiff']);
end

% intrinsic_path = fullfile(basedir, 'trimmed_vids','intrinsic');
% Load Intrinsic for all cams
intrinsic_path = fullfile('H:\DANNCE\BaslerCamerasCalibration\Intrinsic');
load(fullfile(intrinsic_path,'cam_intrinsics.mat'));

%% Click points for each post top in order for each view
figure('Position',[10 10 1200 1000]);
for kk = 1:numel(lframe)
    camparams = params_individual{kk};
    LFrame_image{kk} = undistortImage(lframe{kk},camparams);
    imagesc(LFrame_image{kk});colormap(gray)
    [xi,yi] = getpts;
    point_coordinates{kk} = [xi yi];
end
close
% Remove any extra points at the end that were accidentally marked
for kk = 1:numel(lframe)
    point_coordinates{kk} = point_coordinates{kk}(1:numPoints,:);
end

% Plot point coordinates
figure('Position',[10 10 1200 1000]);
for kk = 1:numel(lframe)
    hold off; imagesc(LFrame_image{kk});colormap(gray)
    hold on; plot(point_coordinates{kk}(:,1),point_coordinates{kk}(:,2),'or')
    waitforbuttonpress;
end
close
% If we mis-labeled a point, remove it here
% rmf = 5;
% for kk = 1:numel(lframe)
%     point_coordinates{kk}(4,:) = [];
% end

% Also remove from LFrame_coordinates
%LFrame_coordinates(5:end,:) = [];

%% Use selected points to calculate camera extrinsics
for kk = 1:numel(lframe)
    %kk
    % Do grid search over parms
    curr_err = 1e10;
    c_save = 0;
    mr_save = 0;
    mn_save = 10;
    for c = 99:-3:90
        %c
        for mr = [0.5 1 1.5 2 2.5 3 3.5 4 4.5 5:5:50]
            for mn = 1e10
                try
                    [worldO,worldL] = estimateWorldCameraPose(double(point_coordinates{kk}),...
                        double(LFrame_coordinates),params_individual{kk},'Confidence',c,'MaxReprojectionError',mr,'MaxNumTrials',mn);
                    for i = 1:200
                        [worldO,worldL] = estimateWorldCameraPose(double(point_coordinates{kk}),...
                            double(LFrame_coordinates),params_individual{kk},'Confidence',c,'MaxReprojectionError',mr,'MaxNumTrials',mn);
                        [rotationM,translationV] = cameraPoseToExtrinsics(worldO,worldL);
                        imagePoints = worldToImage(params_individual{kk},rotationM,translationV,double(LFrame_coordinates));
                        err = mean(sqrt(sum((imagePoints-point_coordinates{kk}).^2,2)));
                        if err < curr_err
                            ["Found better repro error: " num2str(err)]
                            curr_err = err;
                            c_save = c;
                            mr_save = mr;
                            mn_save = mn;
                        end

                    end
                end
            end
        end
    end

    curr_err = 1e10
    for i=1:200
        try
            [worldO,worldL] = estimateWorldCameraPose(double(point_coordinates{kk}),...
                double(LFrame_coordinates),params_individual{kk},'Confidence',c_save,'MaxReprojectionError',mr_save,'MaxNumTrials',mn_save);
            [rotationM,translationV] = cameraPoseToExtrinsics(worldO,worldL);
            imagePoints = worldToImage(params_individual{kk},rotationM,translationV,double(LFrame_coordinates));
            err = mean(sqrt(sum((imagePoints-point_coordinates{kk}).^2,2)));
            if err < curr_err
                rotationMatrix{kk} = rotationM;
                translationVector{kk} = translationV;
                worldOrientation{kk} = worldO;
                worldLocation{kk} = worldL;
                curr_err = err;
            end
        end
    end

    figure(222)
    plotCamera('Location',worldLocation{kk},'Orientation',worldOrientation{kk},'Size',50,'Label',num2str(kk));
    hold on
end
print('-dpng',[extrinsic_filepath filesep 'cameraArrangement.png']);
%%
% Save full camera parameters: intrinsics, extrinsics
save([extrinsic_filepath filesep 'camera_params.mat'],'params_individual','worldOrientation','worldLocation','rotationMatrix','translationVector');

%% Find closed form solution for rotation and translation.
% for kk = 1:numel(lframe)
% [rotationMatrix{kk}, translationVector{kk}] = extrinsics(double(point_coordinates{kk}),double(LFrame_coordinates(:,1:2)),params_individual{kk});
% end
%% Examine reprojections
%y_reflect = [-1 0 0; 0 -1 0; 0 0 1];
for kk = 1:numel(lframe)
    figure(233+kk)
    imagesc( LFrame_image{kk});colormap(gray);
    hold on

    tmp_v = translationVector{kk};
    % tmp_v(3) = -1*tmp_v(3);
    %tmp_v = -1*tmp_v;
    %     tmp_v
    tmp_r = rotationMatrix{kk};
    % tmp_r(:,1) = -1*tmp_r(:,1);
    imagePoints = worldToImage(params_individual{kk},tmp_r,tmp_v,double(LFrame_coordinates));

    colorarray = jet(size(imagePoints,1));%{'r','g','b','y','m','w','k'};
    for llll = 1:size(imagePoints,1)
        plot(imagePoints(llll,1),imagePoints(llll,2),'o','MarkerSize',4,...
            'MarkerEdgeColor',colorarray(llll,:),'MarkerFaceColor',colorarray(llll,:))
    end
    for llll = 1:size(imagePoints,1)
        plot(point_coordinates{kk}(llll,1),point_coordinates{kk}(llll,2),'x','MarkerSize',4,...
            'MarkerEdgeColor',colorarray(llll,:),'MarkerFaceColor',colorarray(llll,:))
    end
    hold off
    print('-dpng',[extrinsic_filepath filesep 'camerareproject',num2str(kk),'.png']);
    mean(sqrt(sum((imagePoints-point_coordinates{kk}).^2,2)))
end

%%camera to world image
for kk = 1:numCams
    figure(223)
    plotCamera('Location',worldLocation{kk},'Orientation',worldOrientation{kk},'Size',5,'Label',num2str(kk));
    hold on;
end

%% Run join all parameters
%paramCams()
% clear
% clc
outputFolder =fullfile(basedir, 'calibration');%
% ['D:\_test_label3D\',date,'\calibration'];
if ~exist(outputFolder, 'dir'), mkdir(outputFolder),end

disp('Gathering all parameters')
for i = 1:numCams
    
    r = rotationMatrix{i};
    t = translationVector{i};
    K = params_individual{i}.IntrinsicMatrix;
    RDistort = params_individual{i}.RadialDistortion;
    TDistort = params_individual{i}.TangentialDistortion;
    save([outputFolder filesep 'cam' num2str(i) '_params.mat'],'r','t','K','RDistort','TDistort')
end
disp('done!')

fprintf('%%%% Done extrinsic calibration and done with merging both %%%%\n')

end