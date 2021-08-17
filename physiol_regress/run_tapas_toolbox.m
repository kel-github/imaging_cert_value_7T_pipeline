function [flag] = run_tapas_toolbox(sub_list, info)

%% this function runs the tapas tool box 
% written for use on UQ HPC e.g. awoonga

% kwargs:
% -- sub_list = the list of subjects submitted to the job - e.g. {'01',
% '02'...} etc
% -- info = a structure of variables containing the following information:
%    -- sess = session number: e.g. 2
%    -- nrun = number of runs for that participant
%    -- Nscans = number of scans (volumes) in the design matrix
%    -- cardiac_files = a cell of the cardiac files for that participant (1,n = nrun)
%    -- respiration_files = same as above but for the resp files
%    -- scan_timing = info file from Siemens
%    -- nscans = number of scans for each run: vector of size: (1, nrun)

%% first, add critical things to path and get environment variables
%tmpdir = getenv('TMPDIR');
tmpdir = pwd; % for debugging
arr_num = str2num(getenv('PBS_ARRAY_INDEX'));
arr_num = 1; % for debugging
this_sub = sub_list{arr_num};
addpath(fullfile(tmpdir, 'spm12', 'spm12'));


% variables from info structure
sess = info.sess;
nrun = info.nrun;
cardiac_files = info.cardiac_files;
respiration_files = info.respiration_files;
scan_timing = info.scan_timing;
nscans = repmat(info.nscans, 1, nrun);

%% initialise spm
spm_jobman('initcfg'); % check this for later
spm('defaults', 'FMRI');

%% define extra fields for tapas
save_path = cellstr(fullfile('tmp', sprintf('sub-%s', this_sub), ...
                             sprintf('ses-0%d', sess), 'func'));
regressors_fname_tmplt = 'sub-%s_ses-0%d_task-attlearn_run-0%d_multregress.txt';
   
jobfile = cellstr(fullfile(tmpdir, 'run_TAPAS_job.m'));
jobs = repmat(jobfile, 1, nrun);
inputs = cell(7, nrun);
for crun = 1:nrun
    inputs{1, crun} = save_path; 
    inputs{2, crun} = cardiac_files(1, crun); 
    inputs{3, crun} = respiration_files(1, crun); 
    inputs{4, crun} = scan_timing(1, crun); 
    inputs{5, crun} = nscans(1, crun); 
    inputs{6, crun} = 1; % onset_slice
    inputs{7, crun} = sprintf(regressors_fname_tmplt, this_sub, sess, crun); 
end
spm_jobman('run', jobs, inputs{:});
flag = 1;
