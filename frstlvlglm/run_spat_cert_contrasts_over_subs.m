%-----------------------------------------------------------------------
% Job saved on 23-Sep-2023 10:36:08 by cfg_util (rev $Rev: 7345 $)
% spm SPM - Unknown
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
% K. Garner  2023
% defining 1st level contrasts to get effects of spatial certainty and value
% this script will loop over subjects and
% 1) try catch for the sub's spm file
% 2) compute contrasts for
%     -- mu fx of task (F)
%     -- cert x tgt loc int (F)
%     -- main effect of tgt side (F)
%
% to run this code in the batch command on neurodesk, go to neurodesk >
% functional imaging > spm (not gui)
% enter below at command line
% run_spm12.sh /opt/mcr/v97/ batch /home/jovyan/neurodesktop-storage/imaging_cert_value_7T_pipeline/frstlvlglm/run_spat_cert_contrasts_over_subs.m

subfol = {'001', '002', '004','006','008','017','020','024','025','075','076','078','079','080','124','126','128','129','130','132','133','134','135','152','151'};
%subfol = {'002'}
%subfol = {'001','004','006','008','017','020','024'} %,'025','075','076','078','079','080','084','124','126','128','129','130','132','133','134','135','137','152','151'};%{'001','002'}

% define where path for the glms
flglm_dir = '/data/VALCERT/derivatives/fl_glm/spat_cert/sub-%s/SPM/SPM.mat';

% prepare spm 
spm('defaults', 'FMRI');
spm_jobman('initcfg');

for isub = 1:length(subfol)
    clear matlabbatch

    if (exist(sprintf(flglm_dir, subfol{isub}), 'file'))

        fprintf(sprintf('estimating contrasts for sub %s', subfol{isub}));

        matlabbatch{1}.spm.stats.con.spmmat = {sprintf(flglm_dir, subfol{isub})};
        matlabbatch{1}.spm.stats.con.consess{1}.fcon.name = 'mu-fx';
        matlabbatch{1}.spm.stats.con.consess{1}.fcon.weights = [1 0 0 1 0 0 1 0 0 1 0 0 0 0 0 0 0 0];
        matlabbatch{1}.spm.stats.con.consess{1}.fcon.sessrep = 'replsc';
        
        %%% create separate tcons for second level effects of interest
        matlabbatch{1}.spm.stats.con.consess{2}.fcon.name = 'cert x loc';
        matlabbatch{1}.spm.stats.con.consess{2}.fcon.weights = [-1 0 0 1 0 0 1 0 0 -1 0 0 0 0 0 0 0 0]; 
        matlabbatch{1}.spm.stats.con.consess{2}.fcon.sessrep = 'replsc';

        matlabbatch{1}.spm.stats.con.consess{3}.fcon.name = 'me_tgt_loc';
        matlabbatch{1}.spm.stats.con.consess{3}.fcon.weights = [1 0 0 1 0 0 -1 0 0 -1 0 0 0 0 0 0 0 0]; 
        matlabbatch{1}.spm.stats.con.consess{3}.fcon.sessrep = 'replsc';

        matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'cert-by-loc';
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [-1 0 0 1 0 0 1 0 0 -1 0 0 0 0 0 0 0 0];
        matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'replsc';

        matlabbatch{1}.spm.stats.con.delete = 1;

        spm_jobman('run',matlabbatch);

    else
        fprintf(sprintf('no valid spm mat file found for sub %s, check fl glm'),...
            subfol{isub});
    end
end