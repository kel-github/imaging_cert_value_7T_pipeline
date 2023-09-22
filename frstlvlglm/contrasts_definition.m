addpath('/home/jovyan/neurodesktop-storage/imaging_cert_value_7T_pipeline/frstlvlglm/');

% Set data root folder
rootFolder = '/data/VALCERT/derivatives/fl_glm';

subject_folder = '001';

test_folder = 'task';

filename = 'SPM.mat';

% create table with subject, file path, run number, and covariate total
% for a given participant
newTable = contrast_zero_count(rootFolder, filename, subject_folder, test_folder);

cond_contrast = [1 0 1; 1 0 1; 0 -1 -1; 0 -1 -1];

% create contrast matrix using cond_contrast and newTable.
newContrast = contrast_matrix_builder(cond_contrast, newTable);

% /data/VALCERT/derivatives/fl_glm/hand/sub-002/SPM
% /data/VALCERT/derivatives/fmriprep/hand/sub-002/SPM/SPM.mat 