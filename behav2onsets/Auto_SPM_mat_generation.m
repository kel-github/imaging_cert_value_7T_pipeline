function Auto_SPM_mat_generation(rootPath, filePattern, saveFolder)
    
    % consider adding parameter for filename output change

    %rootPath = 'C:\Users\cratl\Dropbox\UNSW_Work\Research_Officer_Post\GLM_Scripts\data\VALCERT\fmriprep';

    % ADD SOME SANITY CHECKS AND REPORTS
    
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

                end
                 
             end
            


            % Iterate over each file in the beh folder
            for fileIdx = 1:numel(fileList)
                
                filePath = fullfile(behFolderPath, fileList(fileIdx).name);

                % Load the JSON data from the file
                json_data = jsondecode(fileread(filePath));

                % Store the data in the struct
                mat_data.names = transpose(json_data.names);
                mat_data.onsets = transpose(json_data.onsets);
                mat_data.durations = transpose(json_data.durations);
                
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
end
