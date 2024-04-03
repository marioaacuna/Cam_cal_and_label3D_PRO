function copy_io_yaml(experiment_path)
experiment_path = 'H:\DANNCE\230428\328';
in = 'H:\DANNCE\io.yaml';
out = fullfile(experiment_path, "DANNCE_ready", "io.yaml");
copyfile(in,out,"f")
disp('io file copied')
