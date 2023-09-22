%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% count number of participants with empty condition arrays
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% create an empty struct with cell arrays

miss_resp_cond = struct('sub', {}, 'run', {}, 'cond', {});

% iterate total number of participants
for i = 1:length(subs)

    % loop through each run specified
    for irun = 1:nrun
    
        onset_file = fullfile(task_info_mat_file_dir, sprintf('sub-%s/ses-02', subfol00{i}),...
                                                                      'func', sprintf('sub-%s_ses-02_run-%d_desc-SPM-onsets.mat', subs{i}, runs(irun))); % Select the task info (ie. names/onsets/durations) for this run 
    
        % do stuff with file

        temp_data_holder = load (onset_file);
        
        % loop through each condition durations

        for idur = 1:length(temp_data_holder.durations)

        
            if isempty(temp_data_holder.durations{idur})

               sprintf("sub-%s has an empty duration array in run-%d in condition %s", subs{i}, runs(irun), temp_data_holder.names{idur})
               temp_data_holder.durations{idur}
               
               
               % append useful information to cell array...

                nextIndex = numel(miss_resp_cond) + 1;
                miss_resp_cond(nextIndex).sub = {subs{i}};
                miss_resp_cond(nextIndex).run = {runs(irun)};
                miss_resp_cond(nextIndex).cond = {temp_data_holder.names{idur}};

                % replace empty array with zero -> duration and onset
                %onset_file;
                
                temp_data_holder.onsets(idur) = {0};
                temp_data_holder.durations(idur) = {0};
                save(onset_file, )
                

            end

        end

        % code to replace a given onset and durations to zero
%         temp_data = load ('C:/Users/pboyce/OneDrive - UNSW/func/Temp_sub-01_ses-02_run-2_desc-SPM-onsets.mat');
%         temp_data.onsets(1)={0};
%         temp_data.durations(1)={0};
%         save('C:/Users/pboyce/OneDrive - UNSW/func/Temp_data_run2.mat', '-struct', 'temp_data');


    end

end

% view struct as table
struct2table(miss_resp_cond)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
