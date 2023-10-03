% to run this code in the batch command on neurodesk, go to neurodesk >
% functional imaging > spm (not gui)
% enter below at command line
% run_spm12.sh /opt/mcr/v97/ batch /home/jovyan/neurodesktop-storage/imaging_cert_value_7T_pipeline/frstlvlglm/run_motor_contrasts_over_subs.m

subfol = {'002', '004','006','008','017','020','024','025','075','076','078','079','080','084','124','126','128','129','130','132','133','134','135','137','152'};%{'001', '002', '004','006','008','017','020','024','025','075','076','078','079','080','084','124','126','128','129','130','132','133','134','135','152','151'};
% define where path for the glms
flglm_dir = '/data/VALCERT/derivatives/fl_glm/hand/sub-%s/SPM/SPM.mat';

% cycle through each participant's estimated flglm
for isub = 1:length(subfol)

    clear matlabbatch;

    if (exist(sprintf(flglm_dir, subfol{isub}), 'file')) % check if file exists

        fprintf(sprintf('estimating contrasts for sub %s', subfol{isub}));

        matlabbatch{1}.spm.stats.con.spmmat = {sprintf(flglm_dir, subfol{isub})};
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'hand1 min hand2';
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 -1 0 0];
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'replsc';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'hand2 min hand1';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [-1 0 0 1 0 0];
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'replsc';
        matlabbatch{1}.spm.stats.con.delete = 1;

    
        spm('defaults', 'FMRI');
        spm_jobman('initcfg');
        spm_jobman('run',matlabbatch);

    else % tell user file does not exist

        fprintf(sprintf('no valid spm mat file found for sub %s, check fl glm'),...
            subfol{isub});

    end % of if statement

end % of for loop
