%-----------------------------------------------------------------------
% Job saved on 21-Oct-2022 17:13:48 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
% Defining spm batch for defining 1st level GLM

% run_spm12.sh /opt/mcr/v97/ batch /home/jovyan/neurodesktop-storage/imaging_cert_value_7T_pipeline/frstlvlglm/run_frst_lvl_glm.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% subs' runs that exceed framerate displacement 60% or >
%

% part_num	run	perc

% 22	    1	66.6023166023166
% 22	    2	71.2355212355212
% 22	    3	65.6370656370656

% 84	    2	63.1274131274131

% 92	    2	63.4989200863931
% 92	    3	68.9189189189189

% 139	    1	60.8108108108108
% 139	    2	64.0926640926641

% 140	    1	64.8648648648649
% 140	    2	72.5868725868726
% 140	    3	69.1119691119691


%% define subject and session info

% excluding the following subs entirely due to motion etc:
% 22, 92, 139, 140


subs = {'01', '02', '04','06','08','17','20','24','25','75','76','78','79','80','124','126','128','129','130','132','133','134','135','152','151'};
subfol00 = {'001', '002', '004','006','008','017','020','024','025','075','076','078','079','080','124','126','128','129','130','132','133','134','135','152','151'};
% test run
% subs = {'01'};
% subfol00 = {'001'};

nrun = 3;
runs = [1, 2, 3];


% awkward subject with only 2 runs, run separately
% subs = {'84'};
% subfol00 = {'084'};
% nrun = 2;
% runs = [1, 3];

% subs = {'137'};
% subfol00 = {'137'};
% nrun = 2;
% runs = [1, 2];


% sanity_switch = 0; % run task code

sanity_switch = 0; % run motor/hand sanity check code

% session + nscan stuff
sess = 2; % 2
nscans = 518;

% where stuff is:
% will save SPM.mat file here:
%spm_mat_file_dir = '/data/VALCERT/derivatives/fl_glm/hand';%ses-02_SPM'; % top level for spm mat files % 
spm_mat_file_dir = '/data/VALCERT/derivatives/fl_glm/task';% top level for spm mat files % 

% SPM onsets are at this location
%task_info_mat_file_dir = '/data/VALCERT/derivatives/fl_glm/hand';%task_info'; % top level for task info files
task_info_mat_file_dir = '/data/VALCERT/derivatives/fl_glm/task';

% this is where the multiple nuisance regressors (motion, heart rate) are
% stored
fmri_data_dir = '/data/VALCERT/derivatives/fmriprep';%'C:\Users\pboyce\OneDrive - UNSW/func/data/VALCERT/derivatives/fl_glm/smooth_data';%/preproc_task_fmri/'; % where the fmri data is

% this is where the smoothed data is stored
smoothed_data_dir = '/data/VALCERT/derivatives/fl_glm/smooth_data';
% filter for scans - this is smoothed files pattern
% fwhm_6.0_sub-01_ses-02_task-attlearn_run-3_space-MNI152NLin2009cAsym_desc-preproc_bold
file_filt = 'fwhm_6.0_sub-%s_ses-02_task-attlearn_run-%d_space-MNI152NLin2009cAsym_desc-preproc_bold.nii';%'^ssub.*run-%d.*.nii$'; % how to get files

% BIDS-esque info - i.e. subject and session folder names
sub_fol = 'sub-%s'; % sub folder
ses_fol = 'ses-02'; % session folder
frst_lvl_fol = 'func';%'frstlvl'; % nxt sub folder

spm_fol = 'SPM'; % this GLM

%'^swraf.*\.nii$'
%irun

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define and run first level glms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% /data/VALCERT/derivatives/fl_glm/smooth_data

% define the size of inputs up here - number of subs?
for subj = 1:length(subs)
    clear matlabbatch
  %% defining inputs for one subject
    this_sub = subs{subj}; % get this subject number
        
    fprintf("Current subject: %s", this_sub)
    fprintf("\n")

    % builds pathname for SPM.mat output file
    spm_fol_full = fullfile(spm_mat_file_dir, sprintf(sub_fol, subfol00{subj}), ...
                            spm_fol); % define where I want the spm fol to go

    % note the next line of code assumes that the folders up to and
    % including 'fl_glm' exist already
    if not(isfolder(spm_fol_full)) % check if the folder exists
        mkdir(spm_fol_full); % if it doesn't exist then make it already
    end

% set the template for the motion + nuisance regressors file
% first step, does the merged motion + PhysIO outputs file exist?
phys_exist_check = exist(fullfile(fmri_data_dir, ...
                                sprintf(sub_fol, this_sub), ...
                                'ses-02', 'func',...
                                 sprintf('sub-%s_ses-02_task-attlearn_run-1_desc-motion-physregress_timeseries.txt',...
                                 this_sub)), 'file');
if phys_exist_check
    motion_tmplt = 'sub-%s_ses-02_task-attlearn_run-%d_desc-motion-physregress_timeseries.txt';
else
    %motion_tmplt = 'sub-%s_ses-02_task-attlearn_run-%d_desc-motion_timeseries.txt';
    fprintf("Physio file missing for subject %s", this_sub)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE MATLAB JOBS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set matlab batch directory, timing units, TR, and timing resolution 
matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr([spm_fol_full,'/']); % where output is saved
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';%'scans'; % 'seconds'? it's 'secs' in the example batch file
% RT -> (TR lol) repetition time
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.51;
% default values re: slice timing
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

% now loop through runs
% 
for irun = 1:nrun

    this_data_fol = fullfile(smoothed_data_dir, sprintf(sub_fol, subfol00{subj}), ses_fol, ...
                             'func');
    this_file_filt = sprintf(file_filt, this_sub, runs(irun)); % populate the filter for this run

    %%%%%%%
    %%% get mask if needed
    %%%%%%%
    fullmaskname = fullfile(smoothed_data_dir, sprintf(sub_fol, subfol00{subj}), ...
        'ses-02', 'func',...
        sprintf('sub-%s_ses-02_task-attlearn_run-1_space-MNI152NLin2009cAsym_desc-brain_mask.nii', ...
        this_sub));
    % if needed, unzip the subject's brain mask for this run
    if irun == 1
        if(~exist(fullmaskname, 'file')) % if it doesn't exist yet, then...
            fprintf(sprintf('unzipping brain mask for sub %s run %d', this_sub, irun))
            msk4unzp = fullfile(fmri_data_dir, sprintf(sub_fol, this_sub),...
                'ses-02', 'func',...
                sprintf('sub-%s_ses-02_task-attlearn_run-%d_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz', ...
                this_sub, irun));
            gunzip(msk4unzp, fullfile(smoothed_data_dir, sprintf(sub_fol, subfol00{subj}), ...
                'ses-02', 'func'));
        end
    end

    matlabbatch{1}.spm.stats.fmri_spec.sess(irun).scans = cellstr(spm_select('ExtFPList',this_data_fol,this_file_filt,1:nscans)); % get spm to select the scans for you;
   
    
    % paramaters after 'duration' are only needed for SPM to recognise
    % sturcture or something
    matlabbatch{1}.spm.stats.fmri_spec.sess(irun).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});

    % /data/VALCERT/derivatives/fl_glm/hand/sub-001/ses-02/func
    % this is the file pattern that contains the onsets, durations, names: sub-151_ses-02_run-1_desc-SPM-onsets.mat
    matlabbatch{1}.spm.stats.fmri_spec.sess(irun).multi = cellstr(fullfile(task_info_mat_file_dir, sprintf('sub-%s/ses-02', subfol00{subj}),...
                                                                  'func', sprintf('sub-%s_ses-02_run-%d_desc-SPM-onsets.mat', this_sub, runs(irun)))); % Select the task info (ie. names/onsets/durations) for this run 
   

    % create structure for regression: may not need to change this for
    % motion phys regressmatlabbatch
    matlabbatch{1}.spm.stats.fmri_spec.sess(irun).regress = struct('name', {}, 'val', {}); % task-attlearn
    matlabbatch{1}.spm.stats.fmri_spec.sess(irun).multi_reg  =  cellstr(fullfile(fmri_data_dir, sprintf(sub_fol, this_sub), 'ses-02', 'func',...
                                                                             sprintf(motion_tmplt,...
                                                                             this_sub, runs(irun))));
    % high pass filter - default value
    matlabbatch{1}.spm.stats.fmri_spec.sess(irun).hpf = 128;

end


matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 1]; % Canonical HRF + time and dispersion derivatives
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
% add participant brain mask
matlabbatch{1}.spm.stats.fmri_spec.mask = cellstr(fullmaskname);
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'FAST'; % correct for serial correlations

% switch for task vs motor

if sanity_switch == 0 % run task code
% 
%     % will specify own contrasts,
%       no need for code here
% 
end

if sanity_switch == 1 % run sanity motor/task code

    % will specify own contrasts
    matlabbatch{1}.spm.stats.fmri_spec.fact.name = 'hand';
    matlabbatch{1}.spm.stats.fmri_spec.fact.levels = 2;

end


% now estimate the GLM
matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr([spm_fol_full,'/' 'SPM.mat']);
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);

end