#### Pre-process DANNCE instructions
** UPDATE Apr 2024 ** 
Author: Mario Acuna

NOTES:

	* This repo contains other git repositories, which are not merged into this one (ie. no git anymore for the other ones).
	* This are:
		- Label3D - git: https://github.com/diegoaldarondo/Label3D/tree/master
		- multicamera calibration = https://github.com/spoonsso/dannce/tree/master/multi-camera-calibration	
	* [--This repo works until here DANNCE repo is located externally --]
	

# Introduction:
This repo contains scripts to run the pre-processing for DANNCE. 
Here we can do the multicamera calibration procedures, and the labeling of bodyparts.
It also includes a script to synchronize the cameras, so far supporting arduino frame by frame triggered acquisition.
The main folder to run is 'Workflow/'. the following is a description of each step


## STEP 1 - Run camera calibrations
# Preamble
	This needs to be done only if cameras have been moved or you start a new experiment in a new set up. Otherwise skip this step
	1. Intrinsic second
	* script : step_01__01_run_intrinsic.m
	2. Extrinsic first
	* script: step_01__02_run_extrinsic.m
	3. Final goal: get the parameters to pass to Label3D
	* Acheived at the end of the script: step_01__02_run_extrinsic.m
		- The parameters are saved in the Server H, therefore can be used across computers


## STEP 2 - Synchronization
# Preamble
	This code syncronizes the cameras, works only if cameras are triggered externally frame by frame
	The user must create an environment for this containing the modules present in the requirements.txt file

	* Python code: step_06__makeSyncFiles_Mario.py
	* Environment : env_prepro_DANNCE
	* Important: the system needs to have anaconda installed
	- requiremnts = imageio, ffmpeg, scipy -> in requirements.txt
	* create conda environment
	
	$ conda -n env_prepro_DANNCE
	$ pip install -r requirements.txt
	
	'''
	$ pip install imageio[pyav]
	$ pip install imageio[ffmpeg]
	$ pip install scipy
	$ pip freeze > requirements.txt
	'''
	
	# activate the environment
	$ conda activate env_camera_sync

	$ python step_06__makeSyncFiles_Mario.py vidpath=['path/to/vids'] fps=XX num_landmarks=YY
	- i.e. = python makeSyncFiles_Mario.py vidpath=H:\DANNCE\230428\328\trimmed_vids fps=100 num_landmarks=22
	* This runs with the cams still as cam[n].mp4
	**Important**: *If you decide to run it directrly from the script in VScode for instance, please do not commit/push*.


## STEP 3 - Run Label3D
# Preamble:
	This step is for doing the labeling of bodyparts or of the center of mas (COM)
	Here you can set if you want to run a mock label (only to create the label3D_dannce.mat file), which then is used to predict from a trained net.
	Or, you can indeed run the labelings. For this, I recommend to run first the COM label.
	Steps:
	1. Run com labeling
	2. Reorganize folders if needed
	3. #In DANNCE# run com prediction.
	4. Add the com to the label3D_dannce.mat file
	5. Run dannce body part labeling (could be done in parallel)
	6. Run dannce

	- (OPTIONAL) Do labels (if finetuning is needed)
	- step_03__01_run_COM_label3d.m # this runs the labeling of the center of mass (COM) needed for COM network finetuning
	- step_03__02_run_DANNCE_label3d.m  # this runs the labeling of the bodyparts needed for dannce network finetuning
	
	'''
	% t: triangulate points in current frame that have been labeled in at least two images and reproject into each image
	% r: reset gui to the first frame and remove Animator restrictions
	% u: reset the current frame to the initial marker positions
	% z: Toggle zoom state
	% p: Show 3d animation plot of the triangulated points.
	'''
	labelGUI.exportDannce('framesToLabel', framesToLabel) # will export the current positions to an output folder.
		 1. It will ask you to locate where the sync folder is.	
		 2. It will ask you to locate where the output folder is. 


## STEP 4 - Re-organization of the directory based on what DANNCE needs
# Preamble
	This will organize the folders as needed for the DANNCE steps.
	Important: this might not be necessary, if the user manually organizes the folders (very easy)

	1. Organize Videos. script: step_09__01_reorganize_videos(folder_in, folder_out) 
		example: step_09__01_reorganize_videos('H:\DANNCE\230508\animalX\trimmed_vids','H:\DANNCE\230508\animalX\DANNCE_ready\videos')
	2. Organize folder. script: step_09__02_reorganize_folders_to_dannce(rootdir)
		step_09__02_reorganize_folders_to_dannce('H:\DANNCE\230428\328')



## STEP 5 - Copy com into dannce mat file
# Preamble
	This script will take the com predictions and put it into the label3d_dannce.mat file for subsequent dannce predictions
	* script: step_05__copy_com_into_DANNCE_label3D.m



## STEP 6 - Run dannce predict and mocap at the same time
# Preamble
	This script is actually part of the DANNCE procedure, therefore **the dannce environment must be activated in the terminal**
	It only runs once you have a net that works well.

	* script:  step_06__run_dannce-predict_and_get_mocap_preds.py


###### END ########