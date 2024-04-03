function reorganize_folders_to_dannce()

% Define root folder
rootFolder = 'H:\DANNCE\230428\328';

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
syncSourceFolder = fullfile(rootFolder, 'trimmed_vids', 'sync');
syncTargetFolder = fullfile(dannceReadyFolder, 'sync');
if exist(syncSourceFolder, 'dir')
    if ~exist(syncTargetFolder, 'dir')
        mkdir(syncTargetFolder);
    end
    movefile(fullfile(syncSourceFolder, '*'), syncTargetFolder);
end

% Move videos folder to DANNCE_ready
videosSourceFolder = fullfile(rootFolder, 'behavior_videos');
videosTargetFolder = fullfile(dannceReadyFolder, 'videos');
if exist(videosSourceFolder, 'dir')
    if ~exist(videosTargetFolder, 'dir')
        mkdir(videosTargetFolder);
    end
    movefile(fullfile(videosSourceFolder, '*'), videosTargetFolder);
end
