clear
clc
%%
warning('off')
rootpath = 'H:\DANNCE\230508\animalX';
videos_path = fullfile(rootpath,'full_length_videos/equalized');
dir_vids = dir(videos_path);
names={dir_vids.name};
videos = names(endsWith(names, '.mp4'));

n_videos = length(videos);

% Set trimmed filepath
trimmed_path =fullfile(rootpath, 'trimmed_vids');

if ~exist(trimmed_path, 'dir'), mkdir(trimmed_path);end

% check if the frames are already saved
x_filename = fullfile(videos_path, 'frames_to_trim.mat');
if ~exist(x_filename, "file")
    do_detection = 1;
else
    do_detection = 0;
end
if do_detection
    %% Loop through Vids and locate triggers
    L = [];
    x=NaN(n_videos,2);
    for iv = 5:n_videos
        this_vid = videos{iv};
        filename = fullfile(videos_path, this_vid);
        % Read video
        fprintf('Loading video for %s \n', this_vid)
        vid = VideoReader(filename);
        n_frames = vid.NumFrames;

        %% Select roi
        frame_nr = round(vid.FrameRate*((vid.NumFrames / vid.FrameRate) - 60));
        frame = read(vid, frame_nr);
        imagesc(frame)
        h =  drawcircle(gca);
        % Wait for the user to double-click on the freehand
        wait(h);
        % Create a binary mask for the ROI
        binaryMask = h.createMask();
        % Initialize a variable to store the fluorescence values per frame
        %%
        disp(['Extracting from video'])
        w = waitbar(0, 'Processing frames...');

        intensity = zeros(n_frames,1);
        intensity_div = intensity;
        intensity_diff = intensity;

        D = [];
        F = [];
        tic
        for iframe = 1:n_frames
        % for iframe = 22858:23440 % + 440
            f = (read(vid,iframe ));
            % F = cat(3,F,rgb2gray(f));
            % thisf = f(:,:,1);
            % f = rgb2gray(read(vid,iframe ));
            %extracting the Red color from grayscale image
            [R,G,B] = imsplit(f);
            diff_im = imsubtract(R,rgb2gray(f));
            %Filtering the noise
            % diff_im = medfilt2(diff_im,[3,3]);

            % D = cat(3, D, R);

            intensity_roi = diff_im(binaryMask);
            intensity_no_roi = diff_im(~binaryMask);

            intensity_div(iframe) = (mean(intensity_roi) - mean(intensity_no_roi)) / std(double(intensity_no_roi));
            intensity_diff(iframe) =  mean(intensity_roi) - mean(intensity_no_roi);
            % intensity(iframe) = mean(f(:));
            waitbar(iframe/n_frames, w); % Update status bar
        end

        toc
        close(w)
        intensity = intensity_diff;
        % % Alternative1
        % % Use ginput to get the x and y coordinates of each peak
        % x =zeros(2,1);    y =x;
        % run_input = 1;
        % 
        % % Make sure we have only 2 points
        % while run_input
        %     % Plot the figure to select the first peak
        %     p = figure;
        %     plot(intensity);
        %     title({['Video : ', this_vid];'Select the peaks manually; press enter after zoom in and after selecting the frame'});
        % 
        %     % Allow zooming in to select precise peaks
        %     zoom on;
        %     waitfor(p,'CurrentCharacter',char(13)); % Press enter to exit zoom mode
        %     zoom off;
        %     [x(1),y(1)] = ginput;
        %     close(p)
        % 
        %      % Plot the figure to select the second peak
        %      p = figure;
        %      plot(intensity);
        %      title({['Video : ', this_vid],'Select the peaks manually; press enter after zoom in and after selecting the frame'});
        % 
        %     % Zoom in again to select the second peak
        %     zoom on;
        %     waitfor(gcf, 'CurrentCharacter', char(13)); % Press enter to exit zoom mode
        %     zoom off;
        %     [x(2),y(2)] = ginput;
        % 
        %     % Round the x coordinates to integers (assuming they correspond to frame numbers)
        %     x = floor(x);
        % 
        %     s= figure;
        %     plot(intensity), hold on
        %     scatter(x, intensity(x), 'filled');
        %     title('is it good?')
        %     waitfor(s)
        %     choice = questdlg('Are the selected points correct?', 'Confirmation', 'Yes', 'No', 'Yes');
        % 
        % 
        %     if length(x)~=2 || ismember({choice}, 'No')
        %         % reset
        %         x =zeros(2,1);    y =x;
        %         continue
        %     else
        %         run_input = false;
        %     end
        % end
        % 
        % close(p)

        % Alternative 2 - find peaks
        % [~,lcs] =  findpeaks(intensity, "MinPeakProminence", 2.5*std(intensity));
        % [~, idx ] = sort(diff(lcs), 'descend');
        % pt1 = lcs(idx(1));
        % pt2 = lcs(idx(1) +1);
        % confirm duration
        % n_points= 100;
        % dist_in_sec = (pt2-pt1)/vid.FrameRate;
        % derpt1 = diff(intensity(pt1-n_points : pt1));
        der_intensity= diff(intensity);
        [~,ptsidx]= sort(der_intensity, 'descend');
        xs = sort(ptsidx(1:2), 'ascend');
        x(iv,1) = xs(1);
        x(iv,2) = xs(2);
        % n_to_go_back = n_points - find(derpt1>0, 1,'first');
        % x(iv,1) = determine_trigger_point(pt1, n_points, intensity);
        % x(iv,2) = determine_trigger_point(pt2, n_points, intensity);


        % End reading loop
        length_trimmed = x(iv,2) - x(iv,1) +1;
        fprintf('The legth of the video was %i', length_trimmed)
        L = [L;length_trimmed];
    end
    % save the x values to read them afterwards in case needed
    T = [array2table(x, VariableNames={'start', 'end'}), array2table(videos','VariableNames',{'cams'})];


    save(x_filename, 'T');
    disp('Frames to trim saved')

else
    keyboard % Check sintax
    T=load(x_filename, 'T');
end
% read frames and go on
n_frames_after_eq = T.end - T.start +1;

% Take the min value of frames
min_frames = min(n_frames_after_eq);



%% Read the ori videos and trimm them accordingly
for iv = 1:n_videos
    this_vid = videos{iv};
    % Create new video writer
    trimmed_video_filename = fullfile(trimmed_path, this_vid);
    newVid = VideoWriter(trimmed_video_filename, 'MPEG-4');
    newVid.FrameRate =vid.FrameRate;
    open(newVid);

    % read video
    filename = fullfile(videos_path, this_vid);
    vid = VideoReader(filename);

    % Trim video to frames between x(1) and x(2)
    this_frame = T.start(ismember(T.cams,this_vid));
    frames = [this_frame: ((this_frame + min_frames)-1)];



    % Write only the trimmed frames to new video
    fprintf('Writing new video for %s\n', this_vid)
    tic
    n_frames_new = length(frames);
    for ii = 1:n_frames_new
        frame = read(vid, frames(ii));
        writeVideo(newVid, frame);

        % Status bar
        if mod(ii, round(n_frames_new/10)) == 0 % Update status every 10%
            progress = ii/length(frames) * 100;
            fprintf('\r%0.0f %% \n', progress);
        end
    end
    fprintf('Finished creating the video for ')
    toc

    % Close video writer
    close(newVid);

end



