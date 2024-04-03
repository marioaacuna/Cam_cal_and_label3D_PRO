%%
clear
% animal_ID= 'MF_2epi';
com_filepath = 'H:\DANNCE\230508\animalX\DANNCE_ready\COM\predict_results\com3d.mat';
% load(['D:\Mario\Labels\',animal_ID,'\COM\predict_results\com3d.mat'])
load(com_filepath)
com3d0 = com;
% clear com
com2 = struct();
com2.com3d = com3d0;
com2.sampleID = sampleID;

clear metadata sampleID com3d0 com

%% Load dannce label3D
dannce_filepath = 'H:\DANNCE\230508\animalX\DANNCE_ready\Label3D_dannce.mat';
% load(['D:\Mario\Labels\',animal_ID,'\Label3D_dannce.mat'])
load(dannce_filepath)
clear com
com = com2;
% save(['D:\Mario\Labels\',animal_ID,'\Label3D_dannce.mat'], 'camnames', 'com', 'labelData', 'params', 'sync')
save([dannce_filepath], 'camnames', 'com', 'labelData', 'params', 'sync')
% save('D:\Mario\Labels\mouse1\Label3D_dannce.mat', 'camnames', 'labelData', 'params', 'sync')