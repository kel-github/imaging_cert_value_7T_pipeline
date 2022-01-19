function [n_runs] = get_n_runs(nii_4_nruns, data_dir, subject_number, session_number)
%% written by K. Garner, 2022
% see how many runs exist for 1 participant
% -- inputs:
%    -- nii_4_runs: a template for the filenames to be counted, e.g. 'sub-%s_ses-0%d_task-attlearn_run-*_bold.nii'
%    -- data_dir: folder in which the subject's data can be found - assumes
%    BIDS format
%    -- subject_number: a string with the subject number, e.g. '01'
%    -- session_number: an integer for the session number, e.g. 2
% -- outputs:
%    -- n_runs: number of runs for a given subject (integer)

fs = dir(fullfile(data_dir, ...
                  sprintf('sub-%s', subject_number), ...
                  sprintf('ses-0%d', session_number), ...
                  'func', ...
                  sprintf(nii_4_nruns, subject_number, session_number)));
n_runs = length(fs);
