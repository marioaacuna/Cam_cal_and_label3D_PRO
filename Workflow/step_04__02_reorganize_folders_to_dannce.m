function step_09__02_reorganize_folders_to_dannce()
rootFolder = uigetdir('', 'Root folder');
% Define root folder
% rootFolder = 'H:\DANNCE\230428\328';

% Create DANNCE_ready folder if it doesn't exist
dannceReadyFolder = fullfile(rootFolder, 'DANNCE_ready');
if ~exist(dannceReadyFolder, 'dir')
    mkdir(dannceReadyFolder);
end

% Create COM and DANNCE folders
comFolder = fullfile(dannceReadyFolder, 'COM');
if ~exist(comFolder, 'dir')
    mkdir(comFolder);
end
dannceFolder = fullfile(dannceReadyFolder, 'DANNCE');
if ~exist(dannceFolder, 'dir')
    mkdir(dannceFolder);
end

% Move sync folder to DANNCE_ready
% get one folder upstreal from rootfolder
[syncFolderUpstream] = fileparts(rootFolder);
syncSourceFolder = fullfile(syncFolderUpstream, 'sync');
syncTargetFolder = fullfile(dannceReadyFolder, 'sync');
if exist(syncSourceFolder, 'dir')
    if ~exist(syncTargetFolder, 'dir')
        mkdir(syncTargetFolder);
    end
    copyfile(fullfile(syncSourceFolder, '*'), syncTargetFolder);
end

% move the folders Camera* to videos
videosSourceFolder = fullfile(rootFolder);
videosTargetFolder = fullfile(dannceReadyFolder, 'videos');
if exist(videosSourceFolder, 'dir')
    if ~exist(videosTargetFolder, 'dir')
        mkdir(videosTargetFolder);
    end
    movefile(fullfile(videosSourceFolder, 'Camera*'), videosTargetFolder);
end

% move any '*_Label3D_dannce.mat' to DANNCE_ready
label3dSourceFolder = fullfile(rootFolder);
label3dTargetFolder = fullfile(dannceReadyFolder);
if exist(label3dSourceFolder, 'dir')
    if ~exist(label3dTargetFolder, 'dir')
        mkdir(label3dTargetFolder);
    end
    movefile(fullfile(label3dSourceFolder, '*_Label3D_dannce.mat'), label3dTargetFolder);
end
