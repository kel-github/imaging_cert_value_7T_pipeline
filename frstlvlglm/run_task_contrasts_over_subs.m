%-----------------------------------------------------------------------
% Job saved on 22-Sep-2023 09:59:05 by cfg_util (rev $Rev: 7345 $)
% spm SPM - Unknown
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
% run this script to define all contrasts for the task comparisons, over
% all subjects
% K. Garner, 2023
% run_spm12.sh /opt/mcr/v97/ batch /home/jovyan/neurodesktop-storage/imaging_cert_value_7T_pipeline/frstlvlglm/run_task_contrasts_over_subs.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Define subject parameters and file locations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('/home/jovyan/neurodesktop-storage/imaging_cert_value_7T_pipeline/frstlvlglm/'); % for contrast building functions

% this is where all the SPM mat files live (in BIDS format
% sub-x/ses-0x/func/)
rootfolder = '/data/VALCERT/derivatives/fl_glm/';

%subs = {'01','04','06','08','17','20','24','25','75','76','78','79','80', '84','124','126','128','129','130','132','133','134','135','152','151'};
%subfol00 = {'001','004','006','008','017','020','024','025','075','076','078','079','080','084','124','126','128','129','130','132','133','134','135','152','151'};
% test run
subs = {'01'};
subfol00 = {'001'};

% load base contrasts
load('/home/jovyan/neurodesktop-storage/imaging_cert_value_7T_pipeline/frstlvlglm/task_contrasts.mat')

for isub = 1:length(subs)
    
    clear matlabbatch
    this_sub = subs{isub}; % get this subject number        
    fprintf("current subject: %s", this_sub)
    fprintf("\n")

    sub_fol = subfol00{isub};

    % first get the n of nuisance regressors per run for this sub
    n_nuisance = contrast_zero_count(rootfolder, 'SPM.mat', sub_fol, 'task');

    matlabbatch{1}.spm.stats.con.spmmat = {'/data/VALCERT/derivatives/fl_glm/task/sub-001/SPM/SPM.mat'};

    matlabbatch{1}.spm.stats.con.consess{1}.fcon.name = 'certbyloc';
    % use base contrast certbyloc to generate sub contrast
    sub_certbyloc = contrast_matrix_builder(certbyloc, n_nuisance);

    % add it to the info
    matlabbatch{1}.spm.stats.con.consess{1}.fcon.weights = sub_certbyloc;
    matlabbatch{1}.spm.stats.con.consess{1}.fcon.sessrep = 'replsc';

    matlabbatch{1}.spm.stats.con.consess{2}.fcon.name = 'me_val_conf';
    sub_me_val_conf = contrast_matrix_builder(me_val_conf, n_nuisance);

    matlabbatch{1}.spm.stats.con.consess{2}.fcon.weights = sub_me_val_conf;
    matlabbatch{1}.spm.stats.con.consess{2}.fcon.sessrep = 'replsc';

    matlabbatch{1}.spm.stats.con.consess{3}.fcon.name = 'cf_noconf';
    sub_cf_noconf = contrast_matrix_builder(cf_noconf, n_nuisance);
    matlabbatch{1}.spm.stats.con.consess{3}.fcon.weights = sub_cf_noconf;
    matlabbatch{1}.spm.stats.con.consess{3}.fcon.sessrep = 'replsc';

    matlabbatch{1}.spm.stats.con.consess{4}.fcon.name = 'cf_conf';
    sub_cf_conf = contrast_matrix_builder(cf_conf, n_nuisance);
    matlabbatch{1}.spm.stats.con.consess{4}.fcon.weights = sub_cf_conf;
    matlabbatch{1}.spm.stats.con.consess{4}.fcon.sessrep = 'replsc';

    matlabbatch{1}.spm.stats.con.delete = 0;

    spm('defaults', 'FMRI');
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end
