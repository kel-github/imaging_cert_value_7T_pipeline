% define second level GLM for the spatial certainty x tgt location
% interaction
% K. Garner, 2023
% adapted from the batch save of details:
%-----------------------------------------------------------------------
% Job saved on 04-Oct-2023 03:24:57 by cfg_util (rev $Rev: 7345 $)
% spm SPM - Unknown
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
%%%%%%% command to run
%%%%%%% run_spm12.sh /opt/mcr/v97/ batch /home/jovyan/neurodesktop-storage/imaging_cert_value_7T_pipeline/scndlvlglm/N27_me_tgtside.m
%% first define specification things
save_location = '/data/VALCERT/derivatives/sl_glm/N27_me_tgtside'; % here is where you'll save the second level SPM file, is a string
subs = {'001','002','004','006','008','017','020','024','025','075','076','078','079','080','124','126','128','129','130',...
        '132','133','134','135','152','151'}; %'84','137'% sub list checked by KG Oct 4th 2023 - DO NOT COMMENT OR CHANGE THIS VARIABLE
% WITHOUT EXPLAINING WHY HERE%
% % explanation = bug testing for now - Oct 9th 2023 KG
% -----------------------------------------------------------------------

clear matlabbatch
matlabbatch{1}.spm.stats.factorial_design.dir = {save_location};
ims = {};
for isub = 1:length(subs)
 ims{isub,1} = sprintf('/data/VALCERT/derivatives/fl_glm/task/sub-%s/SPM/con_0005.nii,1',subs{isub});
end
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = ims;

matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

% now estimate the GLM
matlabbatch{2}.spm.stats.fmri_est.spmmat = cellstr([save_location,'/' 'SPM.mat']);
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);
