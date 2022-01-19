%% written by K. Garner, 2022
function [flg] = generate_sub_physio_info_file
% this code extracts the required info to run the physio toolbox for
% each subject
% -- inputs (to be defined in definitions section below): 
%    -- subject_number: is string
%    -- session_number: interger
%    -- data_dir: a string containing the data directory where 'sub-xx'
%    will be found
%    -- save_dir: where would you like the data to be saved?
% -- potential modifications that may be made if you are using this code:
%    -- file templates: you may need to change the filenames to match your
%    own
%        
% -- outputs: a matfile containing a structure called info with the
% following fields:
%    -- sess = session number: e.g. 2
%    -- nrun = number of runs for that participant
%    -- Nscans = number of scans (volumes) in the design matrix
%    -- cardiac_files = a cell of the cardiac files for that participant (1,n = nrun)
%    -- respiration_files = same as above but for the resp files
%    -- scan_timing = info file from Siemens
%    -- nscans = number of scans for each run: vector of size: (1, nrun)

%% definitions
subject_number = '01';
session_number = 2;
data_dir = '/clusterdata/uqkgarn1/scratch/data/';


%% templates
nii_4_nruns = 'sub-%s_ses-0%d_task-attlearn_run-*_bold.nii';
nii_4_scans = 'sub-%s_ses-0%d_task-attlearn_run-%d_bold.nii';
cardiac = 'sub-%s_ses-0%d_cmrr_att_learn_run-0*_PULS.log';
respiration = 'sub-%s_ses-0%d_cmrr_att_learn_run-0*_RESP.log';
scan_info = 'sub-%s_ses-0%d_cmrr_att_learn_run-0*_Info.log';

%% run code

% first get the number of runs
n_runs = get_n_runs(nii_4_nruns, data_dir, subject_number, session_number);

% now get the number of scans for each run
n_scans_per_run = get_n_scans_per_run(n_runs, nii_4_scans, data_dir, subject_number, session_number);

% get the cardiac, respiration and scan timing files
cardiac_files = get_physio_log_files(cardiac, data_dir, subject_number, session_number);
respiration_files = get_physio_log_files(respiration, data_dir, subject_number, session_number);
scan_timing = get_physio_log_files(scan_info, data_dir, subject_number, session_number);

% sanity check
sanity = length(cardiac_files) == n_runs;
if ~sanity
    msg = sprintf('stop! mismatch in file and run numbers for sub-%s', subject_number);
    error(msg)
end

% 



flg