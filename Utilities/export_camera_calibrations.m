function export_camera_calibrations(rootfolder)
rootfolder=('H:\DANNCE\230428\328');

% load intrinsic
load(fillfile(rootfolder,'cam_intrinsics'))
% load extrinsic
load(fillfile(rootfolder,'camera_params'))

% re organoze them
%%H:\DANNCE\230428\328\calibration\calibration_parameters
outputFolder = fullfile(rootfolder,'\cameras_calibration\calibration');
numCams = 6;
for i = 1:numCams
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder)
    end
    r = rotationMatrix{i};
    t = translationVector{i};
    K = params_individual{i}.IntrinsicMatrix;
    RDistort = params_individual{i}.RadialDistortion;
    TDistort = params_individual{i}.TangentialDistortion;
    save(fullfile(outputFolder,['cam' num2str(i) '_params.mat']),'r','t','K','RDistort','TDistort')
end

%%