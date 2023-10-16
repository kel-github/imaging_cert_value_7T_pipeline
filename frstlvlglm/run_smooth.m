


%% unzip participant's bold files
%filePattern = 'sub-*_ses-*_MOTOR_run-*_desc-SPM-onsets.json';

% 
% gfile_ptn = ['/data/VALCERT/derivatives/fmriprep/sub-01/ses-02/func/' ...
%              'sub-01_ses-02_task-attlearn_run-*_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'];
% gdir = '/data/VALCERT/derivatives/fl_glm/smooth_data/sub-01/ses-02/func/';
% % get file list
% flist = dir(gfile_ptn)
% for i = 1:length(flist)
%     gunzip(fullfile(flist(i).folder, flist(i).name), gdir)
% end


% line to execute in spm:
% run_spm12.sh /opt/mcr/v97/ batch /home/jovyan/neurodesktop-storage/imaging_cert_value_7T_pipeline/frstlvlglm/run_smooth.m

subs = {'01','02','04','06','08','17','20','22','24','25','75','76','78','79','80','84','92','124','126','128','129','130','132','133','134','135','137','139','140','152','151'};
sub00 = {'001','002','004','006','008','017','020','022','024','025','075','076','078','079','080','084','092','124','126','128','129','130','132','133','134','135','137','139','140','152','151'};

sesN = 02;

for curr_sub = 1:length(subs)

    %fullfile(sprintf('/data/VALCERT/derivatives/fl_glm/smooth_data/sub-%s/
    % ses-0%d/func/sub-%s_ses-0%d_task-attlearn_run-%d_space-MNI152NLin2009cAsym_desc-preproc_bold.nii', subN, sesN, subN, sesN, runN));

    sub_file = char(subs(curr_sub));
    sub_fold = char(sub00(curr_sub));

    gfile_ptn = fullfile(sprintf('/data/VALCERT/derivatives/fmriprep/sub-%s/ses-0%d/func/sub-%s_ses-0%d_task-attlearn_run-*_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz',sub_file, sesN,sub_file, sesN));
    
%     display("gfile_ptn: ")
%     gfile_ptn
    
    gdir = fullfile(sprintf('/data/VALCERT/derivatives/fl_glm/smooth_data/sub-%s/ses-0%d/func/',sub_fold, sesN));

%     display("gdir: ")
%     gdir

    % get file list
    flist = dir(gfile_ptn)
    for i = 1:length(flist)
        gunzip(fullfile(flist(i).folder, flist(i).name), gdir)
    end

end % end of curr_sub for loop

%-----------------------------------------------------------------------
% Job saved on 19-Oct-2022 15:28:51 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
% dat_path = 'scratch/cvl/uqywards/data/derivatives/preproc_task_fmri';
% subs= [197];
% runs = [1 2 3];
% sess = [3];

runs = [1,2,3];

%%% initialise spm
spm_jobman('initcfg'); % check this for later
spm('defaults', 'FMRI');
%-----------------------------------------------------------------------
for subj = 1:length(subs)

    subN = sprintf('%s',char(subs(subj))); % Assigning current sub number to subN
    subF = sprintf('%s',char(sub00(subj)));

 %   subN
%    subF

%end

    %for sesj = 1:length(sess) % Assigning current session number to sesN
        %sess(sesj);


        for runj = 1:length(runs) % Assigning current run number to runN
            runN = runs(runj);
            % assign functional image to ims variable 
            ims = cellstr(fullfile(sprintf('/data/VALCERT/derivatives/fl_glm/smooth_data/sub-%s/ses-0%d/func/sub-%s_ses-0%d_task-attlearn_run-%d_space-MNI152NLin2009cAsym_desc-preproc_bold.nii', subF, sesN, subN, sesN, runN)));



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
    %end
end

