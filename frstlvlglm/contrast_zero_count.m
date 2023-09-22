function contrast_zeros_table = contrast_zero_count(rootPath, SPMfn, sub_fol, test_fol)

    % rootPath (string): is the path to the folder containing all subject folders
    % with their respective SPM files
    % SPMfn (string): name of the SPM file - currently set to SPM.mat for
    % each subject
    % sub_fol (string): subject number that match the format
    % of their respective folders, e.g. n leading zeros
    % test_fol (string): either 'hand' (motor sanity check) or 'task' (experimental task)

    %subs = {'01'}%{'01','02','04','06','08','17','20','22','24','25','75','76','78','79','80','84','92','124','126','128','129','130','132','133','134','135','139','140','152','151'}
    %sub00 = {'001'}%{'001','002','004','006','008','017','020','022','024','025','075','076','078','079','080','084','092','124','126','128','129','130','132','133','134','135','139','140','152','151'}
    
    %subs = {'01','02','04','06','08','17','20','22','24','25','75','76','78','79','80','84','92','124','126','128','129','130','132','133','134','135','139','140','152','151'};
    %subfol00 = {'001','002','004','006','008','017','020','022','024','025','075','076','078','079','080','084','092','124','126','128','129','130','132','133','134','135','139','140','152','151'}; 
    
    test = test_fol;%'hand';
    %test = 'task';
    
    
    SPMdir = rootPath;%'/data/VALCERT/derivatives/fl_glm/'; % rootPath
    SPMfilename = SPMfn; %'SPM.mat'; % SPMfn
    
    
    %subs = {'01'};
    subfol00 = {sub_fol};%{'001'}; % sub
    sub_fol = 'sub-%s'; % sub folder
    
    runs = [1, 2, 3];
    nrun = length(runs);
    sess = 2; % 2, or 3
    %nscans = 518;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % example table code:
    
    % patients = table([],[],[],[],[],[], 'VariableNames', {'LastName', 'Age', 'Smoker', 'Height', 'Weight', 'BloodPressure'});
    % 
    % LastName = ["Sanchez";"Johnson";"Zhang";"Diaz";"Brown"];
    % Age = [38;43;38;40;49];
    % Smoker = [true;false;true;false;true];
    % Height = [71;69;64;67;64];
    % Weight = [176;163;131;133;119];
    % BloodPressure = [124 93; 109 77; 125 83; 117 75; 122 80];
    % 
    % %patients = table(LastName,Age,Smoker,Height,Weight,BloodPressure)
    % 
    % newrow = table(LastName,Age,Smoker,Height,Weight,BloodPressure);
    % patients = [patients; newrow];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % create empty table
    contrast_zeros_table = table([],[],[],[], 'VariableNames', {'subject', 'file_path', 'run_num', 'covariate_total'});
    
    % for loop to load each SPM for a given participant    
    for spmFile = 1:length(subfol00)
    
        % build path to file
        SPM_mat_file = fullfile(SPMdir, '/', sprintf(test), sprintf(sub_fol,subfol00{spmFile}), '/SPM', SPMfilename);
        file_path = string(SPM_mat_file);
    
        sub_num = subfol00{spmFile};
        subject = string(sub_num);
    
        % load current subject's file
        try 
            load(SPM_mat_file)

        catch

            fprintf("\n")
            warning('SPM.mat file not at location %s', SPM_mat_file);
            fprintf("\n")
            warning("Skipping participant %s", subfol00{spmFile})
            continue


        end % of try catch
    
        % detremine number of runs
        numRuns = size(SPM.Sess,2);
            
        % for loop to cycle through each run (Sess as it's called in SPM)
        for run = 1:numRuns
    
            run_num = [run];
    
            % capture this value (nuisance regressors / covariates)
            % this will be the number of zeros in a given contrast
            covariate_total = [size(SPM.Sess(run).C.C,2)];
         
            newrow = table(subject,file_path,run_num,covariate_total);
       
            contrast_zeros_table = [contrast_zeros_table;newrow];
    
        end % of runs loop
    
    end % of SPM load loopwritetable(contrast_zeros_table,fullfile(SPMdir,'contrast_zeros_table.csv'),'Delimiter',',','QuoteStrings','all')

    % save table as csv
    %writetable(contrast_zeros_table,fullfile(SPMdir,'contrast_zeros_table.csv'),'Delimiter',',','QuoteStrings','all')
    %type 'myData.csv'
    
    % return table
    disp("Table contents:");
    disp(contrast_zeros_table);
    fprintf("\n");

    disp("To select variables, use contrast_zeros_table(:,i) or for one variable contrast_zeros_table.(i). To select rows, use contrast_zeros_table(i,:)")
    fprintf("\n");

    % print example usage to terminal
    % return as strings to avoid any conflicts if code above changed
    disp("Example usage of column names when accessing a specific row index in the table:");
    fprintf("contrast_zeros_table.subject(1) returns: %s", string(contrast_zeros_table.subject(1)));
    fprintf("\n");
    fprintf("contrast_zeros_table.file_path(1) returns: %s", string(contrast_zeros_table.file_path(1)));
    fprintf("\n");
    fprintf("contrast_zeros_table.run_num(1) returns: %s", string(contrast_zeros_table.run_num(1)));
    fprintf("\n");
    fprintf("contrast_zeros_table.covariate_total(1) returns: %s", string(contrast_zeros_table.covariate_total(1)));
    fprintf("\n");
    
        

end % of function
% return the 2nd dimension (size index value)
% size(SPM.Sess(1).C.C,2)