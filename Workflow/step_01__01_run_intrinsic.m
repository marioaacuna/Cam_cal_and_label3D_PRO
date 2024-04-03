% run_instrinsic
addpath('H:\Cam_cal_and_label3D_Nevian\multi-camera calibration' )
% addpath(fullfile(pwd, 'multi-camera calibration'))

date = '';
num_cams = 6;
rootfolder = '';
animal_ID = '';

rootfolder = uigetdir('', 'Select Root Folder where the trimmed vids are');
% run function
calibration_intrinsic_checkerboard(date, num_cams, rootfolder, animal_ID)
