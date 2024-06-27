# Define the root path
$ROOT_PATH = 'D:\DANNCE\ACC_miniscope'

# Function to process videos
function Process-Videos($directory) {
    # Find all .mp4 files and convert them
    Get-ChildItem -Path $directory -Recurse -Filter *.mp4 | ForEach-Object {
        $file = $_.FullName
        $output_file = [System.IO.Path]::Combine($_.DirectoryName, "$($_.BaseName)_quality20.mp4")
        # Convert the video
        & ffmpeg -i "$file" -c:v libx264 -crf 20 -preset slow "$output_file"
        Write-Output "Processed: $file -> $output_file"
    }
}

# Process each animal ID folder
Get-ChildItem -Path $ROOT_PATH | ForEach-Object {
    $animal_id = $_.FullName
    if (Test-Path "$animal_id") {
        # Process each subfolder within the animal ID folder
        Get-ChildItem -Path $animal_id | ForEach-Object {
            $subfolder = $_.FullName
            if (Test-Path "$subfolder\videos") {
                # Process each camera folder within the videos folder
                Get-ChildItem -Path "$subfolder\videos" -Filter "Camera*" | ForEach-Object {
                    $camera_folder = $_.FullName
                    if (Test-Path $camera_folder) {
                        # Process videos in the camera folder
                        Process-Videos $camera_folder
                    }
                }
            }
        }
    }
}

Write-Output "All videos have been processed."
