%% written by K. Garner, 2022
function [flg] = generate_sub_physio_info_file(subject_number, session_number, data_dir, fprep_folder)
% this code extracts the required info to run the physio toolbox for
% each subject
% -- inputs (to be defined in definitions section below): 
%    -- subject_number: is string
%    -- session_number: integer
%    -- data_dir: a string containing the data directory where 'sub-xx'
%    will be found
%    -- fprep_folder: where is the derivative/pre-processed data?
% -- potential modifications that may be made if you are using this code:
%    -- file templates: you may need to change the filenames to match your
%    own
%        
% -- outputs: a matfile containing a structure called info with the
% following fields:
%    -- sub_num = subject number: a string of form '01' '11' or '111'
%    -- sess = session number: e.g. 2
%    -- nrun = number of runs for that participant
%    -- nscans = number of scans (volumes) in the design matrix for each
%    run [vector size 1, nrun]
%    -- cardiac_files = a cell of the cardiac files for that participant
%    (1,n = nrun) - attained by using extractCMRRPhysio()
%    -- respiration_files = same as above but for the resp files - attained by using extractCMRRPhysio()
%    -- scan_tcurrent_subiming = info file from Siemens - attained by using extractCMRRPhysio()
%    -- movement = a cell of the movement regressor files for that
%    participant (.txt, formatted for SPM)
%
% dependencies - JSONio in the directory above or added to path
% data in BIDS v1.0

% use participant csv list and load here - for loops this...
%sub_list_dir = '/data/VALCERT/derivatives/complete-participants.csv';

%sub_list = readtable(sub_list_dir);

%sub_list = table2array(sub_list);

%sub_list = int2str(sub_list);

%sub_list = readmatrix(sub_list_dir);

% sublist(row,col)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for later generalisability of code
% strip away any leading zeros now to make it easier to account for
% n, or no, leading zeros later when matching to files

% remove any input leading zeros to account for n zeros later
% subject_number_numeric = str2double(subject_number);
% subject_number = num2str(subject_number_numeric);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%for current_sub = 1:numel(sub_list)

%     fprintf("contents of current_sub")
%     current_sub
%     fprintf("contents of sub_list(current_sub)")
%     sub_list(current_sub)
               

    %% definitions (possibly set some defaults contingent on input
    if ~nargin
        subject_number = int2str(sub_list(current_sub));
        session_number = 2;
        data_dir = '/clusterdata/uqkgarn1/scratch/data/';
        fprep_folder = 'derivatives/fmriprep/'; % has to be relative to (within) data_dir
    elseif nargin == 1
        session_number = 2;
        data_dir = '/clusterdata/uqkgarn1/scratch/data/';
        fprep_folder = 'derivatives/fmriprep/'; % has to be relative to (within) data_dir  
    elseif nargin == 2
        data_dir = '/clusterdata/uqkgarn1/scratch/data/';
        fprep_folder = 'derivatives/fmriprep/'; % has to be relative to (within) data_dir  
    elseif nargin == 3
        fprep_folder = 'derivatives/fmriprep/'; % has to be relative to (within) data_dir  
    end
        
    
    
    %% templates
    nii_4_nruns = 'sub-%s_ses-0%d_task-attlearn_run-*_bold.nii';
    nii_4_scans = 'sub-%s_ses-0%d_task-attlearn_run-0%d_bold.nii'; % Paul adjusting to be dynamic
    cardiac = 'sub-%s_ses-0%d_cmrr_att_learn_run-0*_PULS.log';
    respiration = 'sub-%s_ses-0%d_cmrr_att_learn_run-0*_RESP.log';
    scan_info = 'sub-%s_ses-0%d_cmrr_att_learn_run-0*_Info.log';
    movement_info = 'sub-%s_ses-0%d_task-attlearn_run-*_desc-motion_timeseries.txt';
    
   

    %% dependencies
    addpath('../JSONio-main')
    
    %% run code
    
   % sub_pattern = ['^0*(' subject_number '\d*)']; for leading zeros?

    % first get the number of runs
    n_runs = get_n_runs(nii_4_nruns, data_dir, subject_number, session_number);
    %n_runs = get_n_runs(nii_4_nruns, data_dir, sub_pattern, session_number);
    
    fprintf("contents of n_runs")
    n_runs

    % now get the number of scans for each run
    n_scans_per_run = get_n_scans_per_run(n_runs, nii_4_scans, data_dir, subject_number, session_number);
    
    % get the cardiac, respiration and scan timing files
    cardiac_files = get_physio_log_files(cardiac, data_dir, subject_number, session_number);
    respiration_files = get_physio_log_files(respiration, data_dir, subject_number, session_number);
    scan_timing = get_physio_log_files(scan_info, data_dir, subject_number, session_number);
    movement = get_physio_log_files(movement_info, [data_dir, fprep_folder], subject_number, session_number);
    % sanity check
    sanity = length(cardiac_files) == n_runs;
    if ~sanity
        msg = sprintf('stop! mismatch in file and run numbers for sub-%s', subject_number);
        error(msg)
    end
    
    % put together into info structure
    info.sub_num = subject_number;
    info.sess = session_number;
    info.nrun = n_runs;
    info.nscans = n_scans_per_run;
    info.cardiac_files = cardiac_files;
    info.respiration_files = respiration_files;
    info.scan_timing = scan_timing;
    info.movement = movement;
    
    % now save the info structure for that participant
    save(fullfile(data_dir, fprep_folder, ...
                 sprintf('sub-%s', subject_number), ...
                 sprintf('ses-0%d', session_number), ...
                 'func',...
                 sprintf('sub-%s_ses-0%d_task-attlearn_desc-physioinfo', subject_number, session_number)),...
         'info');
     
    % and write a json sidecar file to go with it
    jdat.TaskName = "attlearn";
    jdat.Source = 'applied to output of extractCMRRPhysio and spm compatible motion regressor files to get info for physIO workflow';
    jdat.Info = info;
    jsonwrite(fullfile(data_dir, fprep_folder, ...
                    sprintf('sub-%s', subject_number), ...
                    sprintf('ses-0%d', session_number), ...
                    'func',...
                    sprintf('sub-%s_ses-0%d_task-attlearn_desc-physioinfo.json', subject_number, session_number)), ...
                    jdat);
         
    flg = sprintf('PhysIO info structure saved to: %s', ...
                   fullfile(data_dir, fprep_folder, ...
                   sprintf('sub-%s', subject_number), ...
                   sprintf('ses-0%d', session_number), ...
                   'func',...
                   sprintf('sub-%s_ses-0%d_task-attlearn_desc-physioinfo', subject_number, session_number)));

