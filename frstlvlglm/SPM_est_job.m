%-----------------------------------------------------------------------
% Job saved on 26-Oct-2022 12:30:38 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown

%%% initialise spm
spm_jobman('initcfg'); 
spm('defaults', 'FMRI');
%-----------------------------------------------------------------------

subs= [109];
% Loop through subjects to estimate session 2 SPM
for subj = 1:length(subs)

    subN = subs(subj); % Assigning current sub number to subN

    % define spm.mat file location
    dat_path = '/scratch/cvl/uqywards/data/derivatives/ses-02_SPM/sub-%d/frstlvl/s2ROIdef';
    spm_mat_file_dir = cellstr(fullfile(sprintf(dat_path, subN), 'SPM.mat'));


    clear matlabbatch

    matlabbatch{1}.spm.stats.fmri_est.spmmat = spm_mat_file_dir;
    matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

    spm_jobman('run', matlabbatch);


end