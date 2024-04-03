%% Preamble
% if the net was trained with 6 cams, and if you have less than 6, you will have to duplicate the cameras, by just
% copying for instance Camera1 and labeling as Camera5, and so on. 
% Additionally, you have to run this script to update the label3d_dannce.mat file.

%% Load dannce label3D
[fname, fpath] =  uigetfile('*.mat', 'Label3D_dannce.mat FILE!');
dannce_filepath = fullfile(fpath, fname);

load(dannce_filepath)
camnames = {'Camera1', 'Camera2', 'Camera3', 'Camera4', 'Camera5', 'Camera6'};
% update the values for each variable
params{5} = params{1};
params{6} = params{2};
sync{5} = sync{1};
sync{6} = sync{2};

labelData{5} = labelData{1};
labelData{6} = labelData{2};

save(fullfile(fpath, '\Label3D_dannce_6.mat'), 'camnames', 'com', 'labelData', 'params', 'sync');%'D:\Mario\Labels\mouse1\Label3D_dannce_6.mat', 'camnames', 'com', 'labelData', 'params', 'sync')
% save('D:\Mario\Labels\mouse1\Label3D_dannce.mat', 'camnames', 'labelData', 'params', 'sync')

fprintf('cameras now saved into %s \n',fullfile(fpath, '\Label3D_dannce_6.mat'))