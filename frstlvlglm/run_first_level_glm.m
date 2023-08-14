


%% unzip participant's bold files
%filePattern = 'sub-*_ses-*_MOTOR_run-*_desc-SPM-onsets.json';
gfile_ptn = ['/data/VALCERT/derivatives/fmriprep/sub-01/ses-02/func/' ...
             'sub-01_ses-02_task-attlearn_run-*_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'];
gdir = '/data/VALCERT/derivatives/fl_glm/smooth_data/sub-01/ses-02/func/';
% get file list
flist = dir(gfile_ptn)
for i = 1:length(flist)
    gunzip(fullfile(flist(i).folder, flist(i).name), gdir)
end

%-----------------------------------------------------------------------
% Job saved on 19-Oct-2022 15:28:51 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
% dat_path = 'scratch/cvl/uqywards/data/derivatives/preproc_task_fmri';
% subs= [197];
% runs = [1 2 3];
% sess = [3];
 
subs = '01'
runs = [1,2,3]

%%% initialise spm
spm_jobman('initcfg'); % check this for later
spm('defaults', 'FMRI');
%-----------------------------------------------------------------------
for subj = 1:length(subs)

    subN = sprintf('%d',subs(subj)); % Assigning current sub number to subN

    %for sesj = 1:length(sess) % Assigning current session number to sesN
        sesN = 02;%sess(sesj);


        for runj = 1:length(runs) % Assigning current run number to runN
            runN = runs(runj);
            % assign functional image to ims variable 
            ims = cellstr(fullfile(sprintf('/data/VALCERT/derivatives/fl_glm/smooth_data/sub-%s/ses-0%d/func/sub-%s_ses-0%d_task-attlearn_run-%d_space-MNI152NLin2009cAsym_desc-preproc_bold.nii', subN, sesN, subN, sesN, runN)));



clear matlabbatch

%%
matlabbatch{1}.spm.spatial.smooth.data = ims;
%%
matlabbatch{1}.spm.spatial.smooth.fwhm = [4 4 4];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = '';

spm_jobman('run', matlabbatch);

        end 
    end
end

