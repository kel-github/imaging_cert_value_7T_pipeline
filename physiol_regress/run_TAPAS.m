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

% ope

% run in physio bash
% run_spm12.sh /opt/mcr/v99/ batch /home/jovyan/neurodesktop-storage/imaging_cert_value_7T_pipeline/physiol_regress/run_TAPAS.m

clear all

figure_control_switch = 0;
%figure_control_switch = 1; % must press key while in terminal to progress

% define subject strings here
% full list
sub_list = {'01','02','04','06','08','17','20','22','24','25','75','76','78','79','80','84','92','124','126','128','129','130','132','133','134','135','137','139','140','152','151'};
% {'02','84','92'}%

% to see subs that don't run go to: https://docs.google.com/spreadsheets/d/1Qn6wB7nNfiiPS34IYNtGHWTbe3mS12T34Ka6vbPqmUI/edit#gid=632063575
% fails to load phusioinfo for {'02','84','92'} [...]desc-physioinfo.mat not existing

for i = 1:numel(sub_list)
    
    % close all current figures before next iteration as it clogs up
    % desktop with windows
    close all;


    % %% load participant info
    sub = sub_list{i};
    
    fprintf("Current subject: %s", sub)
    
    dat_path = '/data/VALCERT/derivatives/fmriprep/';
    task = 'attlearn';


    % check if file exists
    physioinfo_exist_check = exist(fullfile(dat_path, ...
                                 sprintf('sub-%s', sub), ...
                                'ses-02', 'func',...
                                 sprintf('sub-%s_ses-02_task-%s_desc-physioinfo.json', sub, task)), 'file');

    fprintf("CONTENTS of physioinfo_exist_check %d", physioinfo_exist_check)
 
    % load file if it exists
    if physioinfo_exist_check

        load(fullfile(dat_path, sprintf('sub-%s', sub), 'ses-02', 'func', sprintf('sub-%s_ses-02_task-%s_desc-physioinfo', sub, task)))      

    else % otherwise continue to next iteration

        fprintf('Could not load physioinfo file for pariticpant %s, file may not exist', sub);
        
        continue

    end

        
%         load(fullfile(dat_path, sprintf('sub-%s', sub), 'ses-02', 'func', ...
%             sprintf('sub-%s_ses-02_task-%s_desc-physioinfo', sub, task)))
%         fprintf("GETS HERE FOR subject: %s", sub)
%     
%     catch ME
%     
%         fprintf('Could not load %s for pariticpant %s, run %d, physiological file/s may not exist', fullfile(dat_path, sprintf('sub-%s', sub), 'ses-02', 'func', ...
%             sprintf('sub-%s_ses-02_task-%s_desc-physioinfo', sub, task)), sub, irun);
%         
%         continue
% 
%     end

    

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

        clear matlabbatch

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
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nscans = nscans(irun); % 5
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
        matlabbatch{1}.spm.tools.physio.model.output_multiple_regressors = sprintf('sub-%s_ses-02_task-%s_run-%d_desc-motion-physregress_timeseries.txt', sub, task, irun);
        matlabbatch{1}.spm.tools.physio.model.output_physio = sprintf('sub-%s_ses-02_task-%s_run-%d_desc-physio', sub, task, irun); % 7
        matlabbatch{1}.spm.tools.physio.model.orthogonalise = 'none';
        matlabbatch{1}.spm.tools.physio.model.censor_unreliable_recording_intervals = false; %true;
        matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.c = 3;
        matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.r = 4;
        matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.cr = 1;
        matlabbatch{1}.spm.tools.physio.model.rvt.no = struct([]);
        matlabbatch{1}.spm.tools.physio.model.hrv.no = struct([]);
        matlabbatch{1}.spm.tools.physio.model.noise_rois.no = struct([]);
        %matlabbatch{1}.spm.tools.physio.model.movement.yes.file_realignment_parameters = {fullfile(dat_path, sprintf('sub-%s', sub), 'ses-02', 'func', sprintf('sub-%s_ses-02_task-%s_run-%d_desc-motion_timeseries.txt', sub, task, irun))}; %8
        matlabbatch{1}.spm.tools.physio.model.movement.yes.file_realignment_parameters = {fullfile(dat_path, sprintf('sub-%s', sub), 'ses-02', 'func', sprintf('sub-%s_ses-02_task-%s_run-%d_desc-motion_timeseries.txt', sub, task, irun))}; %8
        matlabbatch{1}.spm.tools.physio.model.movement.yes.order = 12; % then run with 12
        matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_method = 'FD';
        matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_threshold = 0.5;%0.2;
        matlabbatch{1}.spm.tools.physio.model.other.no = struct([]);
        matlabbatch{1}.spm.tools.physio.verbose.level = 1;
        matlabbatch{1}.spm.tools.physio.verbose.fig_output_file = sprintf('sub-%s_ses-02_task-%s_run-%d_desc-physio-fig', sub, task, irun);
        matlabbatch{1}.spm.tools.physio.verbose.use_tabs = false;
        
        try

            spm_jobman('run', matlabbatch);

        catch

            fprintf('Could not execute spm_jobman for pariticpant %s, run %d, physiological file/s may not exist', sub, irun);
            continue

        end

    end
    
    % so, this switch pauses exectuable until a key is pressed. This will
    % allow user to inspect current figures. Once continued it will loop
    % back around and kill all current figures and move onto the next subject.    
    if figure_control_switch == 1
        
        fprintf("Press Enter key to continue...")  
        input('');

    end % end of if statement figure_control_switch

end % end of subject for loop