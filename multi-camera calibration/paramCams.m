% clear
% clc
disp('Gathering all parameters')

% numCams = 3;
% baseFolder = 'D:\cam_calibration';

% load(['D:\_test_label3D\220413\calibration\extrinsic\camera_params.mat'])
% load([baseFolder filesep 'intrinsic\cam_intrinsics.mat'])
% extrinsics
% r = rotation matrix
% t = translation matrix

% intrinsics
% K = intrinsic matrix
% RDistort = RadialDistortion
% TDistort = TangentialDistortion

for i = 1:numCams
    outputFolder = ['D:\_test_label3D\',date,'\calibration'];
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder)
    end
    r = rotationMatrix{i};
    t = translationVector{i};
    K = params_individual{i}.IntrinsicMatrix;
    RDistort = params_individual{i}.RadialDistortion;
    TDistort = params_individual{i}.TangentialDistortion;
    save([outputFolder filesep 'cam' num2str(i) '_params.mat'],'r','t','K','RDistort','TDistort')
end


disp('done!')


