%-----------------------------------------------------------------------
% Job saved on 19-Oct-2022 15:28:51 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
dat_path = 'scratch/cvl/uqywards/data/derivatives/preproc_task_fmri'; % 
subs= [197];
runs = [1 2 3];
sess = [3];

%%% initialise spm
spm_jobman('initcfg'); % check this for later
spm('defaults', 'FMRI');
%-----------------------------------------------------------------------
for subj = 1:length(subs)

    subN = sprintf('%d',subs(subj)); % Assigning current sub number to subN

    for sesj = 1:length(sess) % Assigning current session number to sesN
        sesN = sess(sesj);


        for runj = 1:length(runs) % Assigning current run number to runN
            runN = runs(runj);
            % assign functional image to ims variable 
            ims = cellstr(fullfile(sprintf('/scratch/cvl/uqywards/data/derivatives/preproc_task_fmri/sub-%s/ses-0%d/func/sub-%s_ses-0%d_task-6afc_run-%d_echo-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii', subN, sesN, subN, sesN, runN)));



clear matlabbatch

%%
matlabbatch{1}.spm.spatial.smooth.data = ims;
%%
matlabbatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';

spm_jobman('run', matlabbatch);

        end 
    end
end

