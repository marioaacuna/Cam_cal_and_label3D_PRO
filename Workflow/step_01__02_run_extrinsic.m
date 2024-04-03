% run extrinsic
addpath('\multi-camera calibration')
% params
date = '';
modify_lframe = 0;
num_cams = 6
animal_ID = '';
rootfolder = uigetdir('','Select Project folder');
if rootfolder == 0
    error('No directory selected')
end
% run function
calibration_extrinsic_Lframe(date, modify_lframe, num_cams, rootfolder, animal_ID)