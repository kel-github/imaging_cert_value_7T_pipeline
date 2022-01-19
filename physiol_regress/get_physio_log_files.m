function [file_list] = get_physio_log_files(template, data_dir, subject_number, session_number)
%% written by K. Garner, 2022
% get the relevant physio regressor files for a given subject and session
% -- inputs:
%    -- template: string, a template of the files you want to list
%    -- data_dir: string; folder in which the subject's data can be found - assumes
%    BIDS format
%   -- subject_number: a string with the subject number, e.g. '01'
%   -- session_number: an integer for the session number, e.g. 2
% -- outputs:
%    -- file_list: a {1, number of runs} cell, containing the relevant
%    filenames 

fs = dir(fullfile(data_dir, ...
                  sprintf('sub-%s', subject_number), ...
                  sprintf('ses-0%d', session_number), ...
                  'func', ...
                  sprintf(template, subject_number, session_number)));
              
% get number of runs and assign output cell
n_runs = length(fs);
file_list = cell(1, n_runs);

for ilist = 1:n_runs
    file_list{1, ilist} = fullfile(fs(ilist).folder, fs(ilist).name);
end