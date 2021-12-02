%% Run the get_physio_regressor_files function with subject info
% written by K. Garner, 2021
clear all

% first define subject info inputs for function
sub_list = {'01'};
info.sess = 2;
info.nrun = 3;
info.nscans = 520; % for now

info.cardiac_files = {};
info.respiration_files = {};
info.scan_timing = {};
nrun = info.nrun;

for irun = 1:nrun
    
    info.cardiac_files{1, irun} = fullfile('tmp', sprintf('sub-%s', sub_list{1}), ...
                                           sprintf('ses-0%d', info.sess), ...
                                           'func', ...
                                           sprintf('sub-%s_ses-0%d_task-attlearn_run-0%d_PULS.log', ...
                                                    sub_list{1}, info.sess, irun));
    info.respiration_files{1, irun} = fullfile('tmp', sprintf('sub-%s', sub_list{1}), ...
                                           sprintf('ses-0%d', info.sess), ...
                                           'func', ...
                                           sprintf('sub-%s_ses-0%d_task-attlearn_run-0%d_RESP.log', ...
                                                    sub_list{1}, info.sess, irun));  
    info.scan_timing{1, irun} = fullfile('tmp', sprintf('sub-%s', sub_list{1}), ...
                                          sprintf('ses-0%d', info.sess), ...
                                          'func', ...
                                           sprintf('sub-%s_ses-0%d_task-attlearn_run-0%d_Info.log', ...
                                                    sub_list{1}, info.sess, irun)); 
end

%% now run the tapas toolbox
run_tapas_toolbox(sub_list, info);