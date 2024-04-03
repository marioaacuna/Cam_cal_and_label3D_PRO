% Get the cameras path
clc

cam_path = uigetdir();
project_dir = fileparts(cam_path);
trim_dir = fullfile(project_dir,"trimmed_vids");
ex_filepath = fullfile(trim_dir,'extrinsic');
in_filepath = fullfile(trim_dir,'intrinsic');

if ~exist(ex_filepath, "dir"), mkdir(ex_filepath), end
if ~exist(in_filepath, "dir"), mkdir(in_filepath), end

names = dir(cam_path);
names = {names.name};
cameras = names(endsWith(names, '.mp4'));
n_cameras = length(cameras);

% get mat files
suffix = 'cal_frames_to_trim';
matfiles = names(endsWith(names, '.mat'));
% loop through the cameras
parfor icam = 1:n_cameras
    % read video
    video_filename = fullfile(cam_path, cameras{icam});
    vid = VideoReader(video_filename); %#ok<*TNMLP>
    this_name = strsplit(cameras{icam}, '.mp4');
    % read table with frames
    t_name = matfiles(startsWith(matfiles, this_name{1}));
    t_filepath = fullfile(cam_path, t_name{1});
    t = load(t_filepath, 'T');
    % trim extrinsic
    ex_start= t.T.("Extrinsic Start");
    ex_end = t.T.("Extrinsic End");
    % Init new video
    ex_vid = VideoWriter(fullfile(ex_filepath, cameras{icam}), "MPEG-4");
    ex_vid.Quality = 100;
    ex_vid.FrameRate = 30;
    frames = ex_start:ex_end;
    % run make video
    fprintf("writing video for extrinsic to \n %s \n", fullfile(ex_filepath, cameras{icam}))
    make_vid(ex_vid, vid, frames)

    % trim intrinsic
    in_start= t.T.("Intrinsic Start");
    in_end = t.T.("Intrinsic end");
    
    in_vid = VideoWriter(fullfile(in_filepath, cameras{icam}), "MPEG-4");
    in_vid.Quality = 100;
    in_vid.FrameRate = 30;
    frames = in_start:in_end;
    % run make video
    fprintf("writing video for extrinsic to \n %s \n", fullfile(ex_filepath, cameras{icam}))
    make_vid(in_vid, vid, frames)
    

end
fprintf("\n\n done! \n")


function make_vid(vid_obj,video,frames)
% open object
open(vid_obj)
n_frames = numel(frames);
for iframe = 1:n_frames
    % write video
    this_frame = frames(iframe);
    this_frame = read(video,this_frame);
    % frame = getframe(video, this_frame);
    writeVideo(vid_obj, this_frame)

end
% close vid object
close(vid_obj)
end