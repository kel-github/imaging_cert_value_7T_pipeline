function Auto_SPM_mat_generation(rootPath, filePattern, saveFolder)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % for debugging
    %
               
%     rootPath = '/data/VALCERT/derivatives/fmriprep';
%     
%     % This can be changed to accomodate the control motor files:
%     % the format of the sub/ses/run should be the same for both types of
%     % json file and simply include an asterisk instead of a number
%     %filePattern = 'sub-*_ses-*_task-attlearn_run-*_desc-glm-onsets.json';
%     filePattern = 'sub-*_ses-*_task-MOTOR_run-*_desc-glm-onsets.json';
%     
%     % Declare folder to save files
%     %saveFolder = '/data/VALCERT/derivatives/fl_glm/task';
%     saveFolder = '/data/VALCERT/derivatives/fl_glm/hand';
% 
%     % inspect json data for run 1 vs run 2
%     % NOT cells for duration and onsets
%     run1 = jsondecode(fileread('/data/VALCERT/derivatives/fmriprep/sub-01/ses-02/beh/sub-01_ses-02_task-MOTOR_run-1_desc-glm-onsets.json'));
%     
%     class(run1.names)
%     class(run1.durations)
%     class(run1.onsets)
% 
%     isa(run1.names, 'cell')
%     isa(run1.durations, 'cell')
%     isa(run1.onsets, 'cell')
% 
%     testtrans = transpose(run1.durations);
%     testcell = {testtrans(:,1),testtrans(:,2)};
% 
%     % cells for durations and onsets
%     run2 = jsondecode(fileread('/data/VALCERT/derivatives/fmriprep/sub-01/ses-02/beh/sub-01_ses-02_task-MOTOR_run-2_desc-glm-onsets.json'));
%     class(run2.names)
%     class(run2.durations)
%     class(run2.onsets)


    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % define sub folder names: this are fairly hard coded due to the
    % standardised structures in the workflow 
    subFolderPattern = 'sub-*';
    % not hard coded a session number in case multiple sessions etc.
    sesFolderPattern = 'ses-*';
    behFolderPattern = 'beh';
   
    % Get the list of subfolders matching the subFolderPattern in the rootPath
    subFolders = dir(fullfile(rootPath, subFolderPattern));
    
    % filter folders only as dir grabs files also
    subFolders = subFolders([subFolders.isdir]);

    %for i = 1:numel(subFolders)
     %   fprintf('Struct %d:\n', i);
     %   disp(subFolders(i));
    %end
    
    % Iterate over each subfolder
    for FolderIdx = 1:numel(subFolders)
        
        % append the sub number to build sub-n folder path
        subFolderPath = fullfile(rootPath, subFolders(FolderIdx).name);
        
%         if subFolders(FolderIdx).name == 'sub-92'
%             disp("it prints") 
%         end 

        % Check if the sesFolderPattern exists in the subfolder
        sesFolders = dir(fullfile(subFolderPath, sesFolderPattern));

        sesFolders

        % Report if session folder is missing and continue to the 
        % next session - only check for directory
         if isempty(sesFolders) %|| ~all([sesFolders.isdir])
             
             disp("#####################################################")
             disp(" ")
             disp("WARNING: session folder missing for sub folder path ->")
             
             subFolderPath
             
             disp("NOTE: ending iteration and skipping ahead to next sub")
             disp(" ")
             disp("#####################################################")
             
             continue;
         end

        % Iterate over each ses folder
        for SessionIdx = 1:numel(sesFolders)
            
            sesFolderPath = fullfile(subFolderPath, sesFolders(SessionIdx).name);

            behFolderPath = fullfile(sesFolderPath, behFolderPattern);
            
            
            %behFolderPath
            
            % Report if beh folder is missing and continue to the 
            % next session
             if ~exist(behFolderPath, 'dir')
                 
                disp("#####################################################")
                disp(" ")
                disp("WARNING: beh folder missing for sub folder path -> ")

                subFolderPath
                
                disp("NOTE: ending iteration and skipping ahead to next sub")
                disp(" ")
                disp("#####################################################")
                
                continue
                
             else % if beh folder is present
                 
                
                % pass the file pattern of interest
                pattern = filePattern;

                % Get the list of files matching the pattern in the beh folder
                fileList = dir(fullfile(behFolderPath, pattern));
                 
                % check if there are files in the beh folder via fileList
                % if no files, return warning and move onto next iteration
                if isempty(fileList)
                    
                    disp("#####################################################")
                    disp(" ")
                    disp("WARNING: no files present in beh folder for sub folder path ->")

                    subFolderPath
                    
                    disp("NOTE: ending iteration and skipping ahead to next sub")
                    disp(" ")
                    disp("#####################################################")
                                        
                    continue;

                end % ismpty if statement
                 
             end % else
            


            % Iterate over each file in the beh folder
            for fileIdx = 1:numel(fileList)
                
                filePath = fullfile(behFolderPath, fileList(fileIdx).name);

                % Load the JSON data from the file
                json_data = jsondecode(fileread(filePath));
               

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %
                % Store the data in the struct
                % check that all are cells and if not turn into cells

                % check names is a cell
                if isa(json_data.names, 'cell')

                    
                    mat_data.names = transpose(json_data.names);

                else % if it isn't, turn it into a cell array
                    
                    %test = transpose(run1.durations);
                    mat_data.names = transpose(json_data.names);
                    
                    % n = number of columns
                    %n = size(test,2);
                    n = size(mat_data.names,2);
                    
                    % convert to cell array
                    mat_data.names = mat2cell(mat_data.names, size(mat_data.names, 1), ones(1, n));
                
                end % of names check

                % check if durations is a cell
                if isa(json_data.durations, 'cell')

                    
                    mat_data.durations = transpose(json_data.durations);

                else % if it isn't, turn it into a cell array
                    
                    %test = transpose(run1.durations);
                    mat_data.durations = transpose(json_data.durations);
                    
                    % n = number of columns
                    %n = size(test,2);
                    n = size(mat_data.durations,2);
                    
                    % convert to cell array
                    mat_data.durations = mat2cell(mat_data.durations, size(mat_data.durations, 1), ones(1, n));
                
                end % of durations check

                % check if onsets is a cell
                if isa(json_data.onsets, 'cell')

                    
                    mat_data.onsets = transpose(json_data.onsets);

                else % if it isn't, turn it into a cell array
                    
                    %test = transpose(run1.durations);
                    mat_data.onsets = transpose(json_data.onsets);
                    
                    % n = number of columns
                    %n = size(test,2);
                    n = size(mat_data.onsets,2);
                    
                    % convert to cell array
                    mat_data.onsets = mat2cell(mat_data.onsets, size(mat_data.onsets, 1), ones(1, n));
                
                end % of onsets  check

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Make file patterns compatible for code below:
                % Delete characters after the last *
                comp_pattern = regexprep(pattern, '^(.*\*)[^*]*$', '$1');

                % Replace all * with (\d+)
                comp_pattern = regexprep(comp_pattern, '\*', '(\\d+)');
                
                %sprintf("Contents of comp_pattern: ")
                %comp_pattern
                
                % Use regular expressions to extract sub, ses, and run information
                sub_ses_run = regexp(fileList(fileIdx).name, comp_pattern, 'tokens');
                
                %sprintf("Here is sub_ses_run contents: ")
                %sub_ses_run
                
                % filePattern
                
                %regexp(fileList(fileIdx).name, , 'tokens');

                % Extract sub, ses, and run numbers
                subNumber = sub_ses_run{1}{1};
                fprintf("contents subNumber")
                subNumber
                sesNumber = sub_ses_run{1}{2};
                fprintf("Contents sesNumber: ")
                sesNumber
                runNumber = sub_ses_run{1}{3};


%                 if ischar(subNumber)
%                     fprintf("subNumber is a string:\" )
%                 end
%                 

                % strip leading zeros to have uniform baseline
                subFold = str2double(subNumber);
                
                fprintf("Contents subFold: ")
                subFold

                % 
%                 if isnumeric(subFold)
%                     disp("subFold is numeric:\" )
%                 end

                sesFold = str2double(sesNumber);

                sesFold = sprintf('ses-%02d', sesFold);

                % Add leading zeros to the 'subNumber' based on its length
                if subFold < 10
                    subFormatted = sprintf('sub-%03d', subFold); % 3 digits (2 leading zeros)
                    fprintf("inside <10 if. subFormatted:")
                    subFormatted               
                    
                elseif (subFold > 10) && (subFold < 99)
                    subFormatted = sprintf('sub-%03d', subFold); % 3 digits (1 leading zero from 10 to 99)
                    fprintf("inside >10 if. subFormatted:")
                    subFormatted
                elseif subFold > 99
                    subFormatted = sprintf('sub-%d', subFold); % no leading zeros over 99
                    fprintf("inside else. subFormatted:")
                    subFormatted
                end

%                 fprintf("Contents subFormatted:")
%                 subFormatted

                % Combine 'sub', 'ses', and 'func'
                subsesfunc = [subFormatted '/' sesFold '/func'];
                
%                 fprintf("folders path: ")
%                 subsesfunc

                % Build a new file name using the extracted information
                dynamicFilename = sprintf('sub-%s_ses-%s_run-%s_desc-SPM-onsets.mat', subNumber, sesNumber, runNumber);
                disp("File created: ")
                disp(dynamicFilename)
                % Save struct as a .mat file
                % change save folders to: 
                % derivatives/FL_GLM/Task
                % derivatives/FL_GLM/Hand
                % Combine the 'saveFolder' with the 'subsesfunc' string to create the full folder path
                fullFolderPath = fullfile(saveFolder, subsesfunc);
                
%                 fprintf("Full path")
%                 fullFolderPath

                % Check if the folder  exists, and create it if it doesn't
                if ~exist(fullFolderPath, 'dir')
                    fprintf("creating folders for sub-: ")
                    subNumber

                    mkdir(fullFolderPath);
                end
                
                % save files in relevant folder
                save(fullfile(fullFolderPath, dynamicFilename), '-struct', 'mat_data');

                %save(fullfile(saveFolder, dynamicFilename), '-struct', 'mat_data');
            end
        end
    end

end % of function
