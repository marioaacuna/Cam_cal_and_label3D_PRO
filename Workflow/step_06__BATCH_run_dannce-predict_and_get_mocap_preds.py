import subprocess
import os
import yaml

# Constants
current_path = os.path.dirname(os.path.realpath(__file__))
repo_path = os.path.dirname(current_path)
SKELETON_PATH = os.path.join(repo_path, "Label3D", "skeletons", "mouse22.mat")

# Function to run dannce-predict
def run_dannce_predict(config_path, project_path):
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

# Function to find dannce path
def find_dannce_path():
    current_dir = os.path.dirname(os.path.realpath(__file__))
    two_up_path = os.path.dirname(os.path.dirname(current_dir))
    
    for folder_name in os.listdir(two_up_path):
        if folder_name.lower() == 'dannce-release_development':
            return os.path.join(two_up_path, folder_name)
    
    for folder_name in os.listdir(two_up_path):
        if 'dannce' in folder_name.lower():
            return os.path.join(two_up_path, folder_name)
    
    return None

# Main execution
if __name__ == "__main__":
    root_folder = 'D:/DANNCE'
    animals = [ 'AK_553']#, 'AK_667'] # 'AK_552', 'AK_553', DO AK_553 1 manually
    conditions = ['1']  # 0 for condition saline, and 1 for condition Formalin

    dannce_path = find_dannce_path()
    if not dannce_path:
        print("DANNCE path not found. Please check the installation.")
        exit(1)

    config_path = os.path.join(dannce_path, "configs", "dannce_mouse_config.yaml")

    for animal in animals:
        for condition in conditions:
            project_path = os.path.join(root_folder, animal, condition)
            
            if not os.path.exists(project_path):
                print(f"Skipping non-existent path: {project_path}")
                continue

            print(f"Processing: {project_path}")

            # Read the io.yaml file
            io_yaml_path = os.path.join(project_path, 'io.yaml')
            if not os.path.exists(io_yaml_path):
                print(f"io.yaml not found in {project_path}. Skipping...")
                continue

            with open(io_yaml_path, 'r') as f:
                io_data = yaml.safe_load(f)

            dannce_predict_dir = io_data.get('dannce_predict_dir')
            if not dannce_predict_dir:
                print(f"dannce_predict_dir not found in io.yaml for {project_path}. Skipping...")
                continue

            predict_folder_name = dannce_predict_dir.split('/')[-2]
            mat_file_path = os.path.join(project_path, 'DANNCE', predict_folder_name, 'save_data_AVG0.mat')
            ANIMAL_ID_LABEL3D = os.path.join(project_path, "Label3D_dannce.mat")

            # Run commands
            run_dannce_predict(config_path, project_path)
            run_make_structured_data(mat_file_path, ANIMAL_ID_LABEL3D)

    print("Batch processing completed.")