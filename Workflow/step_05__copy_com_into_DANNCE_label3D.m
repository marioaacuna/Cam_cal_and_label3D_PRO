%%
clear
% animal_ID= 'MF_2epi';
com_filedir = uigetdir('D:\DANNCE', 'COM predictions dir');

% get dir from 2 folders upstream
project_folder = fullfile(fileparts(fileparts(com_filedir)));

[fname, fpath] =  uigetfile([project_folder,'\*.mat'],'MATLAB Files');
dannce_filepath = fullfile(fpath, fname);


%'H:\DANNCE\230428\328\DANNCE_ready\COM\predict_results\com3d.mat';
com_filepath = fullfile(com_filedir, 'com3d.mat');
% load(['D:\Mario\Labels\',animal_ID,'\COM\predict_results\com3d.mat'])
load(com_filepath)
com3d0 = com;
% clear com
com2 = struct();
com2.com3d = com3d0;
com2.sampleID = sampleID;

clear metadata sampleID com3d0 com

%% Load dannce label3D
% dannce_filepath = fullfile(dannce_filedir, 'Label3D_dannce.mat');%
% 'H:\DANNCE\230428\328\DANNCE_ready\Label3D_dannce.mat';
% load(['D:\Mario\Labels\',animal_ID,'\Label3D_dannce.mat'])
load(dannce_filepath)
clear com
com = com2;
% save(['D:\Mario\Labels\',animal_ID,'\Label3D_dannce.mat'], 'camnames', 'com', 'labelData', 'params', 'sync')
save([dannce_filepath], 'camnames', 'com', 'labelData', 'params', 'sync')
% save('D:\Mario\Labels\mouse1\Label3D_dannce.mat', 'camnames', 'labelData', 'params', 'sync')
fprintf('Com saved into %s \n',dannce_filepath)