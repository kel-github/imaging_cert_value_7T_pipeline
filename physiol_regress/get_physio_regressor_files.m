function get_physio_regressor_files(wd, sub)
%% written by K. Garner, 2021
% this function will apply extractCMRRPhysio.m to the fname
% fname is a dcm file
% then reads in the tables of pulse and respiratory datas
% and concatenates to make a single regressors txt file
% info is then read from info.log for the sidecar json file
% both are saved with savename and .txt or .json extensions respectively
% both are saved to the same location as fname

% kwargs
% -- wd: top level for where the data is. e.g. '/scratch/user/uqkgarn1/VALCERT
% -- sub: subject number

%% directory info
if sub < 10
    sub_str = sprintf('0%s', num2str(sub));
else
    sub_str = num2str(sub);
end

data_loc = fullfile(wd, sprintf('sub-%s', sub_str), 'ses-02', 'func', '*physiolog');

%% get physio filenames and extract
fols = dir(data_loc);

for i = 1:length(fols)
    dfile_info = dir(fullfile(fols(i).folder, fols(i).name)); % get the filenames in folder
    for id = 1:length(dfile_info) % get the wanted file
        if length(dfile_info(id).name) > 11
            this_dfile = dfile_info(id);
        end
    end
    DICOM_filename = fullfile(this_dfile.folder, this_dfile.name);
    dcm_outpath = fullfile(wd, sprintf('sub-%s', sub_str), 'ses-02', 'func');
    extractCMRRPhysio(DICOM_filename, dcm_outpath);
    % get the run number for the session, and rename the physiological
    % regressor files
    exp = 'run';
    strtIdx = regexp(fols(i).name, exp);
    endIdx = regexp(fols(i).name, '_phys');
    run_str = fols(i).name((strtIdx+3):(endIdx-1));
    
    %% rename physiol files 
    % this section written for expedience over pretty 
    EXTinfo = dir(fullfile(wd, sprintf('sub-%s', sub_str), 'ses-02', 'func', 'Physio*EXT.log'));
    movefile(fullfile(EXTinfo.folder, EXTinfo.name), fullfile(EXTinfo.folder, ...
                                                     sprintf('sub-%s_ses-02_task-attlearn_run-%s_EXT.log', sub_str, run_str)));
    
    Infoinfo = dir(fullfile(wd, sprintf('sub-%s', sub_str), 'ses-02', 'func', 'Physio*Info.log'));
    movefile(fullfile(Infoinfo.folder, Infoinfo.name), fullfile(Infoinfo.folder, ...
                                                     sprintf('sub-%s_ses-02_task-attlearn_run-%s_Info.log', sub_str, run_str)));
                                                 
    PULSinfo = dir(fullfile(wd, sprintf('sub-%s', sub_str), 'ses-02', 'func', 'Physio*PULS.log'));
    movefile(fullfile(PULSinfo.folder, PULSinfo.name), fullfile(PULSinfo.folder, ...
                                                       sprintf('sub-%s_ses-02_task-attlearn_run-%s_PULS.log', sub_str, run_str)));

    RESPinfo = dir(fullfile(wd, sprintf('sub-%s', sub_str), 'ses-02', 'func', 'Physio*RESP.log'));
    movefile(fullfile(RESPinfo.folder, RESPinfo.name), fullfile(RESPinfo.folder, ...
                                                       sprintf('sub-%s_ses-02_task-attlearn_run-%s_RESP.log', sub_str, run_str)));
    
%% rename run file while at it
    %runinfo = dir(fullfile(wd, sprintf('sub-%s', sub_str), 'ses-02', 'func', sprintf('*run%s.json', run_str)));
    %movefile(fullfile(runinfo.folder, runinfo.name), fullfile(runinfo.folder, sprintf([runinfo.name(1:end-7) '-%s.json'], run_str)));

    %runinfo = dir(fullfile(wd, sprintf('sub-%s', sub_str), 'ses-02', 'func', sprintf('*run%s.nii', run_str)));
    %movefile(fullfile(runinfo.folder, runinfo.name), fullfile(runinfo.folder, sprintf([runinfo.name(1:end-6) '-%s.nii'], run_str)));
    
end

% remove folders
for iFol = 1:length(fols)
    rmdir(fullfile(fols(iFol).folder, fols(iFol).name), 's');
end
end