% to test cylinder or square
test = {'trigger_6cams_full_light_fullcamsetup'};
camera_folder = 'H:\Mario\test_6_cam_Basler\_GOOD_01__Test_full_light_fullcamsetup';
% get cameras
cameras = dir(camera_folder);
cameras = cameras(3:end);
n_cameras = length(cameras);

n_test = 1;

for itest = 1:n_test
    output_file = ['output_' test{itest} '.mp4'];	
    % input_camera = cameras(itest).name;
    input_folder = fullfile(camera_folder);

    % input_folder = ['TEST_', test{itest}];

    % Load the video readers for each camera
    cam1 = VideoReader(fullfile(input_folder,'Camera1','0.mp4'));
    cam2 = VideoReader(fullfile(input_folder,'Camera2','0.mp4'));
    cam3 = VideoReader(fullfile(input_folder,'Camera3','0.mp4'));
    cam4 = VideoReader(fullfile(input_folder,'Camera4','0.mp4'));
    cam5 = VideoReader(fullfile(input_folder,'Camera5','0.mp4'));
    cam6 = VideoReader(fullfile(input_folder,'Camera6','0.mp4'));
    
    % Create a video writer for the output video
    outputVideo = VideoWriter(output_file, 'MPEG-4');
    outputVideo.FrameRate = 120;
    open(outputVideo);
    
    % Assuming all videos have the same number of frames
    while hasFrame(cam1) && hasFrame(cam2) && hasFrame(cam3) && ...
          hasFrame(cam4) && hasFrame(cam5) && hasFrame(cam6)
        
        % Read the next frame from each video
        frame1 = readFrame(cam1);
        frame2 = readFrame(cam2);
        frame3 = readFrame(cam3);
        frame4 = readFrame(cam4);
        frame5 = readFrame(cam5);
        frame6 = readFrame(cam6);
        
        % Resize frames if they are not of the same size
        % [Assuming each frame is resized to 480x640 for example]
        frame1 = imresize(frame1, [480, 640]);
        frame2 = imresize(frame2, [480, 640]);
        frame3 = imresize(frame3, [480, 640]);
        frame4 = imresize(frame4, [480, 640]);
        frame5 = imresize(frame5, [480, 640]);
        frame6 = imresize(frame6, [480, 640]);
        

        % Concatenate frames for each row
        row1 = cat(2, frame1, frame2, frame3);
        row2 = cat(2, frame4, frame5, frame6);

        % Concatenate the two rows vertically
        combinedFrame = cat(1, row1, row2);

        % Write the combined frame to the output video
        writeVideo(outputVideo, combinedFrame);
    end

    % Close the video writer
    close(outputVideo);
end
