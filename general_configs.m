% This file contains a set of general configurations. All variables should
% be loaded into a structure called GC.

function GC = general_configs()
    % Initialize structure
    GC = struct();
    
    % Set version of repository
    GC.version = '0.0.1';
    %% Get path of this file
    current_path = mfilename('fullpath');
    % Remove filename to get root path of the repository
    repository_root_path = regexp(current_path, filesep(), 'split');
    GC.repository_root_path = fullfile(repository_root_path{1:end-1});
    % Temp root folder for outputs
    if ispc
        temp_root = 'D:/DANNCE';
    else
        keyboard
    end
    if ~exist(temp_root, 'dir')
        mkdir(temp_root)
    end
    GC.temp_root = temp_root; 
   

    % Python
    GC.python = struct();
    GC.python.environment_name = 'base';
    [~, msg] = system(sprintf('activate %s && python -c "import sys; print(sys.executable)"', GC.python.environment_name));
    GC.python.interpreter_path = msg(1:end-1);
    GC.python.scripts_path = fullfile(GC.repository_root_path, 'Utilities', 'python');
    
    % R
    GC.R = struct();
    GC.R.scripts_path = fullfile(GC.repository_root_path, 'Code', 'R');

    
    %% PREPROCESSING   
   
    %% PLOTS
   
    % Set plotting options for graphs made in python
    GC.python.font_size_labels  = 16;
    GC.python.scatterplot_small = 7;
    GC.python.scatterplot_large = 10;
    
    
    
    %% TO BE FILLED IN GUI
    GC.experiment_name = '';
    

%% MLint exceptions
%#ok<*CTCH>
