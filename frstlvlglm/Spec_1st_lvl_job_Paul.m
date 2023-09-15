%-----------------------------------------------------------------------
% Job saved on 21-Oct-2022 17:13:48 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
% Defining spm batch for defining 1st level GLM

% run_spm12.sh /opt/mcr/v97/ /home/jovyan/PaulsStuff/Yohans_Scripts/Spec_1st_lvl_job_Paul.m

%addpath '/home/jovyan/PaulsStuff/spm12'

%% define variables that are looped over, or stay the
% identifying
%subs = {'01'}%{'01','02','04','06','08','17','20','22','24','25','75','76','78','79','80','84','92','124','126','128','129','130','132','133','134','135','139','140','152','151'}
%sub00 = {'001'}%{'001','002','004','006','008','017','020','022','024','025','075','076','078','079','080','084','092','124','126','128','129','130','132','133','134','135','139','140','152','151'}

subs = {'01'};%{'01','02','04','06','08','17','20','22','24','25','75','76','78','79','80','84','92','124','126','128','129','130','132','133','134','135','139','140','152','151'};
subfol00 = {'001'};%{'001','002','004','006','008','017','020','022','024','025','075','076','078','079','080','084','092','124','126','128','129','130','132','133','134','135','139','140','152','151'}; 
runs = [1, 2, 3];
nrun = length(runs);
sess = 2; % 2, or 3
nscans = 518;

% where stuff is:

% will save SPM.mat file here:
spm_mat_file_dir = '/data/VALCERT/derivatives/fl_glm/hand';%ses-02_SPM'; % top level for spm mat files % 

% SPM onsets are at this location
task_info_mat_file_dir = '/data/VALCERT/derivatives/fl_glm/hand';%task_info'; % top level for task info files
%task_info_mat_file_dir = 'data/derivatives/fl_glm/task;'

% this is where the smoothed data is stored
fmri_data_dir = 'data/VALCERT/derivatives/fmriprep';%'C:\Users\pboyce\OneDrive - UNSW/func/data/VALCERT/derivatives/fl_glm/smooth_data';%/preproc_task_fmri/'; % where the fmri data is
smoothed_data_dir = '/data/VALCERT/derivatives/fl_glm/smooth_data';
sub_fol = 'sub-%s'; % sub folder
ses_fol = 'ses-02'; % session folder
frst_lvl_fol = 'func';%'frstlvl'; % nxt sub folder


spm_fol = 'SPM'; % this GLM

% filter for scans - this is smoothed files pattern
file_filt = 'ssub-%s_ses-02_task-attlearn_run-%d_space-MNI152NLin2009cAsym_desc-preproc_bold.nii';%'^ssub.*run-%d.*.nii$'; % how to get files
%'^swraf.*\.nii$'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% count number of participants with empty condition arrays
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% create an empty struct with cell arrays

miss_resp_cond = struct('sub', {}, 'run', {}, 'cond', {});

% iterate total number of participants
for i = 1:length(subs)

    % loop through each run specified
    for irun = 1:nrun
    
        onset_file = fullfile(task_info_mat_file_dir, sprintf('sub-%s/ses-02', subfol00{i}),...
                                                                      'func', sprintf('sub-%s_ses-02_run-%d_desc-SPM-onsets.mat', subs{i}, runs(irun))); % Select the task info (ie. names/onsets/durations) for this run 
    
        % do stuff with file

        temp_data_holder = load (onset_file);
        
        % loop through each condition durations

        for idur = 1:length(temp_data_holder.durations)

        
            if isempty(temp_data_holder.durations{idur})

               sprintf("sub-%s has an empty duration array in run-%d in condition %s", subs{i}, runs(irun), temp_data_holder.names{idur})
               temp_data_holder.durations{idur}
               
               
               % append useful information to cell array...

                nextIndex = numel(miss_resp_cond) + 1;
                miss_resp_cond(nextIndex).sub = {subs{i}};
                miss_resp_cond(nextIndex).run = {runs(irun)};
                miss_resp_cond(nextIndex).cond = {temp_data_holder.names{idur}};

                % replace empty array with zero -> duration and onset
                temp_data_holder.onsets(idur) = {0};
                temp_data_holder.durations(idur) = {0};

                % save updated file to original name
                save(onset_file, '-struct', 'temp_data_holder')
                %save('CHECKzero', '-struct', 'temp_data_holder')
                

            end

        end

        % code to replace a given onset and durations to zero
%         temp_data = load ('C:/Users/pboyce/OneDrive - UNSW/func/Temp_sub-01_ses-02_run-2_desc-SPM-onsets.mat');
%         temp_data.onsets(1)={0};
%         temp_data.durations(1)={0};
%         save('C:/Users/pboyce/OneDrive - UNSW/func/Temp_data_run2.mat', '-struct', 'temp_data');


    end

end

% view struct as table
struct2table(miss_resp_cond)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "define spm job"
% What does this code do?
% jobfile = {'/home/jovyan/PaulsStuff/Yohans_Scripts/Spec_1st_lvl_job_Paul.m'}; % referencing this script?
% jobs = repmat(jobfile, 1, nrun);
% inputs = cell(4, nrun);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% /data/VALCERT/derivatives/fl_glm/smooth_data

% define the size of inputs up here - number of subs?
for subj = 1:length(subs)
    clear matlabbatch
  %% defining inputs for one subject
    this_sub = subs{subj}; % get this subject number

    % builds pathname for SPM.mat output file
    spm_fol_full = fullfile(spm_mat_file_dir, sprintf(sub_fol, subfol00{subj}), ...
                            spm_fol); % define where I want the spm fol to go
    % note the next line of code assumes that the folders up to and
    % including 'fl_glm' exist already
%     if not(isfolder(spm_fol_full)) % check if the folder exists
%         mkdir(spm_fol_full); % if it doesn't exist then make it already
%     end

%end

% Set matlab batch directory, timing units, TR, and timing resolution 
matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr([spm_fol_full,'/']); % where output is saved
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';%'scans'; % 'seconds'? it's 'secs' in the example batch file
% RT -> (TR lol) repetition time
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.5100;
% unsure -> default value
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
% unsure -> default value
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;


% now loop through runs
% 
for irun = 1:nrun

    this_data_fol = fullfile(smoothed_data_dir, sprintf(sub_fol, subfol00{subj}), ses_fol, ...
                             'func');

    this_file_filt = sprintf(file_filt, this_sub, irun); % populate the filter for this run

    matlabbatch{1}.spm.stats.fmri_spec.sess(irun).scans = cellstr(spm_select('ExtFPList',this_data_fol,this_file_filt,1:nscans)); % get spm to select the scans for you;
   
    
    % paramaters after 'duration' are only needed for SPM to recognise
    % sturcture or something
    matlabbatch{1}.spm.stats.fmri_spec.sess(irun).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});

    % /data/VALCERT/derivatives/fl_glm/hand/sub-001/ses-02/func
    % this is the file pattern that contains the onsets, durations, names: sub-151_ses-02_run-1_desc-SPM-onsets.mat
    matlabbatch{1}.spm.stats.fmri_spec.sess(irun).multi = cellstr(fullfile(task_info_mat_file_dir, sprintf('sub-%s/ses-02', subfol00{subj}),...
                                                                  'func', sprintf('sub-%s_ses-02_run-%d_desc-SPM-onsets.mat', this_sub, irun))); % Select the task info (ie. names/onsets/durations) for this run 
   

    % create structure for regression: may not need to change this for
    % motion phys regressmatlabbatch
    matlabbatch{1}.spm.stats.fmri_spec.sess(irun).regress = struct('name', {}, 'val', {}); % task-attlearn

    % change this to call in motion and phys regressors
    % sub-01_ses-02_task-attlearn_run-1_desc-motion-physregress_timeseries.txt
    % /data/VALCERT/derivatives/fmriprep/sub-01/ses-02/func
    matlabbatch{1}.spm.stats.fmri_spec.sess(irun).multi_reg  =  {'sub-01_ses-02_task-attlearn_run-1_desc-motion-physregress_timeseries.txt'};%cellstr(fullfile(fmri_data_dir, sprintf('sub-%s/ses-02/func/sub-%s_ses-02_task-attlearn_run-%d_desc-motion-physregress_timeseries.txt',...
                                                              % this_sub, this_sub, irun))); % Select the regressors for this run 




    % high pass filter - default value
    matlabbatch{1}.spm.stats.fmri_spec.sess(irun).hpf = 128;



end
%end

%     this_data_fol = fullfile(fmri_data_dir, sprintf(sub_fol, this_sub), sprintf(ses_fol, sess), ...
%                              'func');
%     this_file_filt = sprintf(file_filt); % populate the filter for this run        
%     matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_select('ExtFPList',this_data_fol,this_file_filt,1:390)); % get spm to select the scans for you;
%     matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
%     matlabbatch{1}.spm.stats.fmri_spec.sess.multi = cellstr(fullfile(task_info_mat_file_dir, sprintf('sub-%d/ses-03', this_sub),...
%                                                                   'frstlvl', sprintf('task_info_sub-%d_ses-02_run-3.mat', this_sub))); % Select the task info (ie. names/onsets/durations) for this run 
%     matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
%     matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = cellstr(fullfile(fmri_data_dir, sprintf('sub-00%d/ses-03/func/sub-00%d_ses-03_task-6afc_run-3_desc-motion_timeseries.txt',...
%                                                                 this_sub, this_sub))); % Select the regressors for this run 
%     matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;

matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 1]; % Canonical HRF + time and dispersion derivatives
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
  
% SPM creates own masks which is ultra conservative -> default mask;
% probably need change?
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'FAST';

% missing
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);

end