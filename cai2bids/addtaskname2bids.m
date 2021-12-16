function [flg] = addtaskname2bids(data_path, sub_num)
%% written by K. Garner, 2021
% this code reads in .json files and adds a TaskName field
% as per BIDS specifications
% must have JSONio folder in the same folder as the function directory

%% get json tools
addpath(fullfile(pwd, 'JSONio-main'));
%% get fnames
% first, id sub string
if sub_num < 10
    sub_str = sprintf('0%d', sub_num);
else
    sub_str = sprintf('%d', sub_num);
end

fs = dir(fullfile(data_path, sprintf('sub-%s', sub_str), 'ses-02', 'func', '*.json'));

%% add task name field
for ifs = 1:length(fs)
    
    jdat = jsonread(fullfile(fs(ifs).folder, fs(ifs).name));
    jdat.TaskName = "attlearn";
    jsonwrite(fullfile(fs(ifs).folder, fs(ifs).name), jdat);
end

flg = 1;

    
    
    