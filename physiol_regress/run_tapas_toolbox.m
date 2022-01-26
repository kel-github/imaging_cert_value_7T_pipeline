function [flag] = run_tapas_toolbox(sub_list, ses_num, spm_path, info_path)

%% this function runs the tapas tool box 
% written for use on UQ HPC e.g. wiener, cvl
% run the tapas tool box for each participant in sub_list to generate 
% physiological regressors
% kwargs:
% -- sub_list = the list of subjects submitted to the job - e.g. {'01',
% '02'...} etc. Note: is strings in a cell array
% -- ses_num = is integer. The session number for which you wish to extract
% motion regressors for
% -- spm_path = the full file path to where spm with PhySIO installed lives
% -- info_path: is string. Path to fmriprep level of BIDS derivatives folder

%% first, add critical things to path and get environment variables
nsubs = length(sub_list);
addpath(fullfile(spm_path, 'spm12'));
addpath('../JSONio-main');

%% initialise spm
spm_jobman('initcfg'); % check this for later
spm('defaults', 'FMRI');

%% start subject loop
for i_sub = 1:length(sub_list)
    %% load info structure
    % -- info = a structure of variables containing the following information:
    %    -- sess = session number: e.g. 2
    %    -- nrun = number of runs for that participant
    %    -- Nscans = number of scans (volumes) in the design matrix
    %    -- cardiac_files = a cell of the cardiac files for that participant (1,n = nrun)
    %    -- respiration_files = same as above but for the resp files
    %    -- scan_timing = info file from Siemens
    %    -- nscans = number of scans for each run: vector of size: (1, nrun)
    %    -- movement = a cell of the movement regressor files for that
    %    participant (1, nrun) [.txt in format for use with
    %    SPM]
    this_sub = sub_list{i_sub};
    load(fullfile(info_path, sprintf('sub-%s', this_sub), ...
        sprintf('ses-0%d', ses_num), 'func', ...
        sprintf('sub-%s_ses-0%d_task-attlearn_desc-physioinfo.mat', this_sub, ses_num)),...
        'info');
    
    %% collect variables from info structure et al
    sess = info.sess;
    nrun = info.nrun;
    cardiac_files = info.cardiac_files;
    respiration_files = info.respiration_files;
    scan_timing = info.scan_timing;
    nscans = repmat(info.nscans, 1, nrun);
    movement = info.movement;
    

    %% define extra fields for tapas
    save_path = cellstr(fullfile(info_path, sprintf('sub-%s', this_sub), ...
                                            sprintf('ses-0%d', sess), 'func'));
    regressors_fname_tmplt = 'sub-%s_ses-0%d_task-attlearn_run-0%d_desc-multregress_timeseries.txt';
    physio_mat_tmplt = 'sub-%s_ses-0%d_task-attlearn_run-0%d_desc-physio.mat';
   
    jobfile = cellstr(fullfile(pwd, 'run_TAPAS.m'));
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(8, nrun);
    for crun = 1:nrun
        inputs{1, crun} = save_path;
        inputs{2, crun} = cardiac_files(1, crun);
        inputs{3, crun} = respiration_files(1, crun);
        inputs{4, crun} = scan_timing(1, crun);
        inputs{5, crun} = nscans(1, crun);
        inputs{6, crun} = movement(1, crun);
    end
    spm_jobman('run', jobs, inputs{:});
    
    %% print json files
    
end   
flag = 1;
