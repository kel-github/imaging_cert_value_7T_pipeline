%% written by K. Garner, 2022
% uses batch info:
%-----------------------------------------------------------------------
% Job saved on 17-Aug-2021 10:35:05 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
% load participant info, and print into the appropriate batch fields below
% before running spm jobman
% assumes data is in BIDS format

%% load participant info
sub = '01';
dat_path = '/home/kellygarner/Insync/tmp-data/phys_regress/';
task = 'attlearn';
load(fullfile(dat_path, sprintf('sub-%s', sub), 'ses-02', 'func', ...
              sprintf('sub-%s_ses-02_task-%s_desc-physioinfo', sub, task)))
          
% set variables
nrun = info.nrun;
nscans = info.nscans;
cardiac_files = info.cardiac_files;
respiration_files = info.respiration_files;
scan_timing = info.scan_timing;
movement = info.movement;
          
%% initialise spm
spm_jobman('initcfg'); % check this for later
spm('defaults', 'FMRI');
          
%% run through runs, print info and run 

for irun = 1:nrun
    
    matlabbatch{1}.spm.tools.physio.save_dir = cellstr(fullfile(dat_path, sprintf('sub-%s', sub), 'ses-02', 'func')); % 1
    matlabbatch{1}.spm.tools.physio.log_files.vendor = 'Siemens_Tics';
    matlabbatch{1}.spm.tools.physio.log_files.cardiac = cardiac_files(irun); % 2
    matlabbatch{1}.spm.tools.physio.log_files.respiration = respiration_files(irun); % 3
    matlabbatch{1}.spm.tools.physio.log_files.scan_timing = scan_timing(irun); % 4
    matlabbatch{1}.spm.tools.physio.log_files.sampling_interval = [];
    matlabbatch{1}.spm.tools.physio.log_files.relative_start_acquisition = 0;
    matlabbatch{1}.spm.tools.physio.log_files.align_scan = 'last';
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nslices = 81;
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = [];
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.TR = 1.51;
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Ndummies = 0;
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nscans = nscans(1); % 5
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.onset_slice = 1; 
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = [];
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nprep = [];
    matlabbatch{1}.spm.tools.physio.scan_timing.sync.nominal = struct([]);
    matlabbatch{1}.spm.tools.physio.preproc.cardiac.modality = 'PPU';
    matlabbatch{1}.spm.tools.physio.preproc.cardiac.filter.no = struct([]);
    matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_template.min = 0.4;
    matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_template.file = 'initial_cpulse_kRpeakfile.mat';
    matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_template.max_heart_rate_bpm = 90;
    matlabbatch{1}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off = struct([]);
    matlabbatch{1}.spm.tools.physio.preproc.respiratory.filter.passband = [0.01 2];
    matlabbatch{1}.spm.tools.physio.preproc.respiratory.despike = true;
    matlabbatch{1}.spm.tools.physio.model.output_multiple_regressors = 'mregress.txt'; %cellstr(sprintf('sub-%s_ses-02_task-%s_run-%d_desc-motionphysregress_timeseries.txt', sub, task, irun)); % 6
    matlabbatch{1}.spm.tools.physio.model.output_physio = 'physio'; %sprintf('sub-%s_ses-02_task-%s_run-%d_desc-physio', sub, task, irun); % 7
    matlabbatch{1}.spm.tools.physio.model.orthogonalise = 'none';
    matlabbatch{1}.spm.tools.physio.model.censor_unreliable_recording_intervals = true; %false; 
    matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.c = 3;
    matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.r = 4;
    matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.cr = 1;
    matlabbatch{1}.spm.tools.physio.model.rvt.no = struct([]);
    matlabbatch{1}.spm.tools.physio.model.hrv.no = struct([]);
    matlabbatch{1}.spm.tools.physio.model.noise_rois.no = struct([]);
    matlabbatch{1}.spm.tools.physio.model.movement.yes.file_realignment_parameters = {fullfile(dat_path, sprintf('sub-%s', sub), 'ses-02', 'func', sprintf('sub-%s_ses-02_task-%s_run-%d_desc-motion_timeseries.txt', sub, task, irun))}; %8
    matlabbatch{1}.spm.tools.physio.model.movement.yes.order = 6;
    matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_method = 'FD';
    matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_threshold = 0.5;
    matlabbatch{1}.spm.tools.physio.model.other.no = struct([]);
    matlabbatch{1}.spm.tools.physio.verbose.level = 2;
    matlabbatch{1}.spm.tools.physio.verbose.fig_output_file = '';
    matlabbatch{1}.spm.tools.physio.verbose.use_tabs = false;
    
    spm_jobman('run', matlabbatch);

end