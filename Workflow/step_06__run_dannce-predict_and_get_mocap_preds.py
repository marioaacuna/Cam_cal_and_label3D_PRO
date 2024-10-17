import subprocess
import os
from tkinter import Tk
from tkinter.filedialog import askdirectory
import yaml

# Constants
# Get current path
current_path = os.path.dirname(os.path.realpath(__file__))
repo_path = os.path.dirname(current_path) # Assuming that it is inside Workflow

SKELETON_PATH = os.path.join(repo_path,"Label3D", "skeletons", "mouse22.mat")
#r"C:\Users\acuna\Repositories\Cam_cal_and_label3D_PRO\Label3D\skeletons\mouse22.mat"

# Function to run dannce-predict
def run_dannce_predict(config_path, project_path):
    # Run dannce-predict with cwd parameter
    command = f"dannce-predict {config_path}"
    try:
        subprocess.run(command, check=True, shell=True, cwd=project_path)
    except subprocess.CalledProcessError as e:
        print(f"Error running dannce-predict: {e}")

# Function to run makeStructuredDataNoMocap.py
def run_make_structured_data(mat_file_path, output_path):
    script_path = r"C:\Users\acuna\Repositories\dannce-release_development\dannce\utils\makeStructuredDataNoMocap.py"
    command = f"python {script_path} {mat_file_path} {SKELETON_PATH} {output_path}"
    try:
        subprocess.run(command, check=True, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running makeStructuredDataNoMocap.py: {e}")

# Example usage
if __name__ == "__main__":
    # Get project path
        
        
    # Get the current file's directory
    current_dir = os.path.dirname(os.path.realpath(__file__))

    # Move two directories up
    two_up_path = os.path.dirname(os.path.dirname(current_dir))

    # Initialize dannce_path as None
    dannce_path = None

    # Search for the 'dannce-release_development' directory first
    for folder_name in os.listdir(two_up_path):
        if folder_name.lower() == 'dannce-release_development':
            dannce_path = os.path.join(two_up_path, folder_name)
            break  # Stop searching once found

    # If 'dannce-release_development' wasn't found, look for a folder containing 'dannce'
    if not dannce_path:
        for folder_name in os.listdir(two_up_path):
            if 'dannce' in folder_name.lower():
                dannce_path = os.path.join(two_up_path, folder_name)
                break  # Stop searching once found

        
    Tk().withdraw()
    # set config path inside dannce path
    #config_path = os.path.join(dannce_path, "configs\dannce_mouse_config.yaml")
    config_path = r"D:\DANNCE\DANNCE_TRAINING_3\configs\dannce_rig_dannce_config.yaml"
    
    project_path = os.path.join(askdirectory(title="Select Project Path")) # show an "Open" dialog box and return the path to the selected folder

    # Read the mat file
    io_yaml_path = os.path.join(project_path, 'io.yaml')
    
    # Read the io.yaml file
    with open(io_yaml_path, 'r') as f:
        io_data = yaml.safe_load(f)

    # Extract the dannce_predict_dir variable
    dannce_predict_dir = io_data['dannce_predict_dir']

    # Obtain the folder name after the last '/'
    predict_folder_name = dannce_predict_dir.split('/')[-2]

    # Modify the mat_file_path accordingly
    mat_file_path = os.path.join(project_path, 'DANNCE', predict_folder_name, 'save_data_AVG0.mat')
    #mat_file_path = os.path.join(project_path, "DANNCE\predict_results\save_data_AVG0.mat")

    ANIMAL_ID_LABEL3D = os.path.join(project_path, "Label3D_dannce.mat")
    
    output_path = ANIMAL_ID_LABEL3D

    # Run commands
    run_dannce_predict(config_path, project_path)
    run_make_structured_data(mat_file_path, output_path)
