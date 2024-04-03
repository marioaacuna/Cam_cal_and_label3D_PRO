## Preamble
# This script will help you selecting the animal to train/predict bodyparts
# so far is still in beta, but the idea is to run all from here, then it's easier to use
# But for any modification of weights, you need to change them in the config or io.yaml file
##
import os
import subprocess
import shutil

## Inputs
animal_ID = 'MF_2epi'
date = '040822' 
server_exp_folder_str =  os.path.join(r"T:\Marta\test_Formalin\dannce", date,animal_ID,'DANNCE')

# What to do (predict, train)

step_to_do = 'predict' # com-predict; com-train; dannce-predict; dannce-train

default_folder = 'D:\\Mario\\Labels\\' + animal_ID

# If also doing mocap
prediction_folder = 'predict_results'
experiment_folder = 'T:/Marta/test_Formalin/dannce/'
AVG0_file = os.path.join(default_folder, 'DANNCE', prediction_folder,'save_data_AVG0.mat')


################################ DO NOT MODIFY ####################################


config_file = 'C:\\Users\\Public\\Repos\\dannce-master\\configs\\dannce_mouse_config.yaml' # Config filepath is never changed 
bodyparts_file = 'T:/Marta/Cam_cal_and_label3D_Nevian/Label3D/skeletons/rat16.mat' # So far, body skeleton file is not changed

str_cd = 'cd ' + default_folder
str_to_do =  step_to_do + ' ' + config_file

## Call Bash for trainig or predicting
# Change directory to where the data is
os.chdir(default_folder)
# call the function to do
subprocess.call(str_to_do, shell=True)

if step_to_do == 'predict':
    run_mocap = True
else:
    run_mocap = False

## Run Mocap & copy folder to Experiment Dir
if run_mocap:
   label3D_file = os.path.join(default_folder,'Label3D_dannce.mat')
   print('Running Mocap predictions')
   # Cd to the main repo folder
   main_dir = 'C:/Users/Public/Repos/dannce-master'
   os.chdir(main_dir)
   python_script = 'dannce/utils/makeStructuredDataNoMocap.py'
   AVG0_file = AVG0_file
   mocap_cmd = 'python ' + python_script + ' ' +  AVG0_file + ' ' + bodyparts_file + ' ' + label3D_file
   subprocess.call(mocap_cmd, shell=True)

   ## Copy folder to Main Experiment folder
   server_experiment_folder = os.path.join(r'T:\Marta\test_Formalin\dannce', date,animal_ID,'DANNCE')
   #path = os.path.join(parent_dir, directory)    
   #os.mkdir(path)

   source_dir = os.path.join(default_folder, 'DANNCE', prediction_folder)
   destination_dir = server_experiment_folder
   shutil.copytree(source_dir, destination_dir)
   print('Prediction data copy to ' +  destination_dir)
   
print('All done! Move forward with the analysis')