function make_empty_label3d_dannce(rootfolder)
%% variables
%   camnames: cell(1,n_cams) = Camera1, ...
%   labelData: cell(n_cams,1) = data_2d, data_3d, data_frame, data_sampleID = [];
%    params : cell(n_cams,1) = k,Rdistort,..., etc
%   sync: cell(n_cams,1) = data_2d, data_3d, data_frame, data_sampleID

%% read files
rootfolder = 'H:\DANNCE\230428\328';
addpath("deps\")
% sync

syncFolder =fullfile(rootfolder,'trimmed_vids\') ;
sync = collectSyncPaths(syncFolder,'*.mat');
sync = cellfun(@(X) {load(X)}, sync);

% Calibration params
calib_path = fullfile(rootfolder, 'cameras_calibration');
calibPaths = collectCalibrationPaths(calib_path);
params = cellfun(@(X) {load(X)}, calibPaths);

% Cam names
camnames = {'Camera1', 'Camera2', 'Camera3', 'Camera4', 'Camera5', 'Camera6'};

%label data
l = struct();
l.data_2d  = [];
l.data_3d = [];
l.data_frame = [];
l.data_sampleID = [];
labelData = cell(6,1);
for ic =1:6
    labelData(ic) ={l};

end

save_to = fillfile(rootfolder,'DANNCE_ready');
if ~exist("save_to","dir")
    mkdir(save_to)
end

save(fullfile(save_to, 'Label3D_dannce.mat'), ...
    'sync', 'camnames', 'labelData', 'params')

disp('DANNCE label3D file saved!')

