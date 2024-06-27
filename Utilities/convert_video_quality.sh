#!/bin/bash

# Define the root path
ROOT_PATH='/mnt/d/DANNCE/ACC_miniscope'

# Function to process videos
process_videos() {
    local directory="$1"
    # Find all .mp4 files and convert them
    find "$directory" -type f -name "*.mp4" | while read -r file; do
        # Define output filename
        output_file="${file%.*}_quality20.mp4"
        # Convert the video
        ffmpeg -i "$file" -c:v libx264 -crf 20 -preset slow "$output_file"
        echo "Processed: $file -> $output_file"
    done
}

# Process each animal ID folder
for animal_id in "$ROOT_PATH"/*; do
    if [ -d "$animal_id" ]; then
        # Process each subfolder within the animal ID folder
        for subfolder in "$animal_id"/*; do
            if [ -d "$subfolder/videos" ]; then
                # Process each camera folder within the videos folder
                for camera_folder in "$subfolder/videos/Camera*"; do
                    if [ -d "$camera_folder" ]; then
                        # Process videos in the camera folder
                        process_videos "$camera_folder"
                    fi
                done
            fi
        done
    fi
done

echo "All videos have been processed."

# make the script executable
#chmod +x Utilities/convert_video_quality.sh
