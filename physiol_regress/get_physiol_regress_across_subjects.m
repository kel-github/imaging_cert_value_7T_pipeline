%%%% base script to get physiological regressor structure file, which will
%%%% then be called by run_TAPAS.m

% this script will loop across subjects to make the info files

% use try catch to flag failed subs
% loop pulling from participant list

% creates info files used in run_TAPAS

clear all

sub_file = '/data/VALCERT/derivatives/complete-participants.csv';
sub_list = readmatrix(sub_file);

% for reference
% cardiac = 'sub-%s_ses-0%d_cmrr_att_learn_run-0*_PULS.log';
% respiration = 'sub-%s_ses-0%d_cmrr_att_learn_run-0*_RESP.log';
% scan_info = 'sub-%s_ses-0%d_cmrr_att_learn_run-0*_Info.log';

%% define arguments
for current_sub = 1:numel(sub_list)
    
    subject_number = int2str(sub_list(current_sub)); % some subjects won't have all the files, find which subjects don't, and we'll form an action plan about those
    disp("Current sub_number: ")
    subject_number
    % in the meantime find a way to flag and skip, make txt file detailing
    % missing files and relevant subject number
    session_number = 2;
    data_dir = '/data/VALCERT/';
    fprep_folder = 'derivatives/fmriprep/';

    try
    
        % step 1 = get the sub info for tapas
        f = generate_sub_physio_info_file(subject_number, session_number, data_dir, fprep_folder);

    catch

        disp(sprintf("Current subject Sub-%s missing relevant file or files:", subject_number));
        disp("Skipping subject and continuing...")
        continue;

    end % end of try / catch

end % end of for loop

% now we have saved the info we need 
% 'PhysIO info structure saved to: /data/VALCERT/derivatives/fmriprep/sub-01/ses-02/func/sub-01_ses-02_task-attlearn_desc-physioinfo'
