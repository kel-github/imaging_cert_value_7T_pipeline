function final_matrix = contrast_matrix_builder(contrast, cov_table)

    % contrast (matrix): pass in contrast of interest
    % contrast may be an array or may be a matrix

    % table (table): pass table built from contrast_zero_count which
    % has all information required
    
    covariate_table = cov_table;%newTable; %cov_table

    % example matices
    %eg_array = [1 -1];
    contrast_matrix = contrast;%[1 0 1; 1 0 1; 0 -1 -1; 0 -1 -1];% contrast

    % if not a matrix give error instruction
    if ~ismatrix(contrast_matrix)

        error("ERROR: Please enter a matrix of contrasts in parameter 'contrast'/position 1, for example: contrast_matrix_builder([1 -1], contrast_zeros_table)")

    end % of ismatrix if statement

        % if not a matrix give error instruction
    if ~istable(covariate_table)

        error("ERROR: Please enter a table generated by the contrast_zero_count function in parameter 'table'/position 2, for example: contrast_matrix_builder([1 -1], contrast_zeros_table)")

    end % of ismatrix if statement

    % 
    if ismatrix(contrast_matrix) & istable(covariate_table)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % for testing pusposes only
        %
    
%         subject = ["002"];
%         file_path = ["/file/stored/here"];
%         run_num = ["1"];
%         covariate_total = ["10"]
% 
%         newrow = table(subject,file_path,run_num,covariate_total);
%         covariate_table = [covariate_table;newrow];

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % for loop through each row for a given subject - must return 
        % output by subject due to differing number of covariates per 
        % subject and per run
        % NOTE: all runs will be on a given row or array/matrix
        % no inconsistentcies within a subject

        % capture array of unique subjects, 
        sub_array = [(unique(covariate_table.subject))];

        % start a subject loop here...

        for curr_sub = 1:numel(sub_array)

            % capture current participant table information
            current_sub_table = covariate_table(covariate_table.subject == sub_array(curr_sub), :);
    
            % number of runs for current particiapnts and => number of
            % separate matracies...
            num_curr_runs = size(current_sub_table,1);
    
            %str2num(unique(covariate_table.subject))
    
            % add main code here...
    
            % when matrix is a single vector/row/array keep it as such with each of
            % the n runs starting with input contrast
    
            % here we use the original matrix with the n zeros and where the
            % number 2 is determine the number of appended repeats...
            % the 10 needs to be dynamic... can this been done with repat?
            
            % here we can loop through the number of rows in the table and
            % have the zeros 2nd psoition be the value in covariate_total
            % and appeand to one matrix
    
            % final contrast matrix
            % prealocate size of array by filling with zeros
            % good for sanity testing too

            % this works but is inefficient
            final_matrix = [];

            %final_matrix = [zeros(num_of_rows,num_of_cols)];
    
            % loop trough each 
            %covariate_table = contrast_zeros_table; %table

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %
            % for testing pusposes only
            %
        
%             subject = ["002"];
%             file_path = ["/file/stored/here"];
%             run_num = ["1"];
%             covariate_total = ["10"]
%     
%             newrow = table(subject,file_path,run_num,covariate_total);
%             covariate_table = [covariate_table;newrow];
%     
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
            % for loop through each row for a given subject - must return 
            % output by subject due to differing number of covariates per 
            % subject and per run
            % NOTE: all runs will be on a given row or array/matrix
            % no inconsistentcies within a subject
    
            % capture array of unique subjects, 
            sub_array = [(unique(covariate_table.subject))];
    
            % start a subject loop here...
    
            %for curr_sub = 1:numel(sub_array)
    
            % capture current participant table information
            current_sub_table = covariate_table(covariate_table.subject == sub_array(curr_sub), :);
    
            % number of runs for current particiapnts and => number of
            % separate matracies...
            num_curr_runs = size(current_sub_table,1);
    
            %str2num(unique(covariate_table.subject))
    
            % add main code here...
    
            % when matrix is a single vector/row/array keep it as such with each of
            % the n runs starting with input contrast
    
            % here we use the original matrix with the n zeros and where the
            % number 2 is determine the number of appended repeats...
            % the 10 needs to be dynamic... can this been done with repat?
            
            % here we can loop through the number of rows in the table and
            % have the zeros 2nd psoition be the value in covariate_total
            % and appeand to one matrix
    
            % final contrast matrix
            % prealocate size of array by filling with zeros
            % good for sanity testing too
    
            % this works but is inefficient
            %final_matrix = [];
    
            %final_matrix = [zeros(num_of_rows,num_of_cols)];
    
            % loop trough each 
              
            % this works for inefficient version
            for cov_tot = 1:num_curr_runs
    
                %final_matrix = horzcat(final_matrix,repmat([contrast_matrix zeros(size(contrast_matrix,1),str2num(current_sub_table.covariate_total(cov_tot)))],1));
                final_matrix = horzcat(final_matrix,repmat([contrast_matrix zeros(size(contrast_matrix,1),current_sub_table.covariate_total(cov_tot))],1));
    
            end    
            
            %final_matrix
            %return

        end % of subject for loop

       

    end % of ismatrix if statement


end % of function
% return the 2nd dimension (size index value)
% size(SPM.Sess(1).C.C,2)