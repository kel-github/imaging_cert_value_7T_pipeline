function [n_scans_per_run] = get_n_scans_per_run(n_runs, nii_4_scans, data_dir, subject_number, session_number)
%% written by K. Garner 2022
% for each run, get the number of scans
% this should largely be the same for each participant and run, but
% sometimes there are quirks
% --inputs: 
%   -- n_runs - total number of runs for that subject, integer
%   -- nii_4_scans - string - template for the nii files from which to get
%   scan number info; e.g. 'sub-%s_ses-0%d_task-attlearn_run-%d_bold.nii'
%   -- data_dir - string; folder in which the subject's data can be found - assumes
%    BIDS format
%   -- subject_number: a string with the subject number, e.g. '01'
%   -- session_number: an integer for the session number, e.g. 2
% -- outputs:
%   -- n_scans_per_run: a [1, n_runs] vector of integers, the number of
%   scans for each run

%% run function
n_scans_per_run = zeros(1, n_runs);

for irun = 1:n_runs
   
    % define file info
   current_file = fullfile(data_dir, ...
                  sprintf('sub-%s', subject_number), ...
                  sprintf('ses-0%d', session_number), ...
                  'func', ...
                  sprintf(nii_4_scans, subject_number, session_number, irun));
   
    % get info from nifti
    current_info = niftiinfo(current_file);
    n_scans_per_run(irun) = current_info.ImageSize(4);    
end