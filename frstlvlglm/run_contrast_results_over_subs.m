% to run this code in the batch command on neurodesk, go to neurodesk >
% functional imaging > spm (not gui)
% enter below at command line
% run_spm12.sh /opt/mcr/v97/ batch /home/jovyan/neurodesktop-storage/imaging_cert_value_7T_pipeline/frstlvlglm/run_contrast_results_over_subs.m

subfol = {'076'};%{'004','006','008','017','020','024','025','075','076','078','079','080','084','124','126','128','129','130','132','133','134','135','137','152','151'};%{'001','002'}
% define where path for the glms
%flglm_dir = '/data/VALCERT/derivatives/fl_glm/hand/sub-%s/SPM/SPM.mat';
flglm_dir = '/data/VALCERT/derivatives/fl_glm/task/sub-%s/SPM/SPM.mat';

% print one and two for hands and one for tasks

%contrast_num = {1,2};
contrast_num = {1};

for con_num = 1:length(contrast_num)

    % cycle through each participant's estimated flglm
    for isub = 1:length(subfol)
    
        clear matlabbatch;
    
       if (exist(sprintf(flglm_dir, subfol{isub}), 'file')) % check if file exists
    
            fprintf(sprintf('building results PDF for sub %s', subfol{isub}));
            
            %spm('defaults', 'FMRI');
            %spm_jobman('run', jobs, inputs{:});        
            
            matlabbatch{1}.spm.stats.results.spmmat = {sprintf(flglm_dir, subfol{isub})};
            matlabbatch{1}.spm.stats.results.conspec.titlestr = '';
            matlabbatch{1}.spm.stats.results.conspec.contrasts = contrast_num{con_num};% specify outside of loop and therefore can print contrast n
            matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
            matlabbatch{1}.spm.stats.results.conspec.thresh = 0.001;
            matlabbatch{1}.spm.stats.results.conspec.extent = 0;
            %matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
            matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
            matlabbatch{1}.spm.stats.results.units = 1;
            matlabbatch{1}.spm.stats.results.export{1}.pdf = true;
    
            spm('defaults', 'FMRI');
            spm_jobman('initcfg');
            spm_jobman('run',matlabbatch);
    
        else % tell user file does not exist
    
            fprintf(sprintf('no valid spm mat file found for sub %s, check fl glm'),...
                subfol{isub});
       
        end % of if/else statement
    
    end % of sub for loop

end % contrast loop

