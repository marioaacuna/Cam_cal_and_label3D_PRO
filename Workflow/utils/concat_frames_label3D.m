%% Test to add new frames
clear
clc
%%
addpath('Workflow/utils')
addpath(genpath([pwd,'/Label3D/deps']))
addpath(genpath([pwd,'/Label3D/skeletons']))
addpath('Label3D\')
%% Run it
% set new frames
frovs = [1000:1010, ...
    1570,...
    1834,...
    1955,...
    5220,...
    115269,...
    117869,...
    117924,...
    118265,...
    118381,...
    118347,...
    118410,...
    118432,...
    118460,...
    142434,...
    143471,...
    144623,...
    145895,...
    158995,...
    159008,...
    160059,...
    170767,...
    173467,...
    181947,...
    184901,...
    193749,...
    ];
% frovs = [700:780];

% get file
[f, p] = uigetfile(fullfile(pwd, '_temp_Label3D'), 'Load temp_label3D');

% load old version
full_file_name = fullfile(p, f);
temp = load(full_file_name);

% load videos
[fv, pv ]= uigetfile('H:\DANNCE', 'Get the videos');


% read frames that have been analyzed already
n_frames_in = size(temp.data_3D,1);
n_new_frames = length(frovs);
% add new vars
new_data3d = nan(n_new_frames, size(temp.data_3D,2));
s_status = size(temp.status);
new_status = zeros(s_status(1), s_status(2), n_new_frames);

temp_str = strsplit(full_file_name, '.');
new_file_name = [temp_str{1}, '_new_frames.mat'];

% save vars
skeleton = temp.skeleton;
status = cat(3,temp.status,new_status);
imageSize = temp.imageSize;
cameraPoses = temp.cameraPoses;
data_3D = cat(1,temp.data_3D, new_data3d);
camParams = temp.camParams;
if ~exist(new_file_name, 'file')
    save(new_file_name, 'status', 'imageSize', 'cameraPoses', 'data_3D', 'camParams', 'skeleton')
end
% set frames
frames_to_label_filename = fullfile(pv, 'frames_to_label.mat');
framesToLabel = load(frames_to_label_filename);
framesToLabel = framesToLabel.framesToLabel;

% check if already done for these frames
if sum(ismember(framesToLabel, frovs)) ~= length(frovs)
    % concatenate only if these new frames were not saved
    framesToLabel  = [framesToLabel, frovs];
else
    error('Frames already saved in videos. Continue with normal label3d from state')
end
% Take only non repeated values
% framesToLabel = (unique(framesToLabel));
% Load videos
disp('Loading previous vids')
mat_videos_fiilename = fullfile(pv, fv);
videos = load(mat_videos_fiilename);
videos = videos.videos;
n_vids = length(videos);
% add new videos
new_vids = cell(n_vids, 1);
fprintf('Wait a sec, concatenating videos \n')
% get the ori videos
[pov] = uigetdir('H:\DANNCE\', 'Dir full vids'); % usually in trimmed videos
for nVid = 1:n_vids
    disp(['vid ', num2str(nVid)])
    this_vid = videos{nVid};
    % concat new frames
    vidPath = fullfile(pov, ['cam',num2str(nVid),'.mp4']);
    this_vid_new_frames = readFrames(vidPath , frovs );

    % concatenate the videos
    new_vids(nVid) = {cat(4, this_vid, this_vid_new_frames)};
end

% rename the videos
videos = new_vids;

disp('saving new frames to label and new videos')
save(frames_to_label_filename, 'framesToLabel')
save(mat_videos_fiilename, 'videos','-v7.3')
disp('saved')

disp('Loading Label3D')
% Run label gui with new frames
labelGui = Label3D(new_file_name, videos);

keyboard



labelGui.exportDannce('framesToLabel', framesToLabel)