addpath('/home/jovyan/neurodesktop-storage/imaging_cert_value_7T_pipeline/behav2onsets/');

% Set data root folder
rootFolder = '/data/VALCERT/derivatives/fmriprep';

% This can be changed to accomodate the control motor files:
% the format of the sub/ses/run should be the same for both types of
% json file and simply include an asterisk instead of a number
%filePattern = 'sub-*_ses-*_task-attlearn_run-*_desc-glm-onsets.json';
%filePattern = 'sub-*_ses-*_task-MOTOR_run-*_desc-glm-onsets.json';
filePattern = 'sub-*_ses-*_task-cuecert_run-*_desc-glm-onsets.json';
% Declare folder to save files
saveFolder = '/data/VALCERT/derivatives/fl_glm/spat_cert';
%saveFolder = '/data/VALCERT/derivatives/fl_glm/hand';

% run the auto .mat generate function
Auto_SPM_mat_generation(rootFolder, filePattern, saveFolder)

