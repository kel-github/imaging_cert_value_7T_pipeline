## example script to run the functions from the regressors package
# K. Garner 2022

# %%
# first define settings for list files

import get_movement_parameters_per_subject as getmov

import csv

participant_list = '/data/VALCERT/derivatives/complete-participants.csv'


file = open(participant_list, "r")
sublist = list(csv.reader(file, delimiter=","))
file.close()


#print(sublist)
# resulting files from code below - one for each run:

# sub-01_ses-02_task-attlearn_run-1_desc-motion_timeseries.txt
# sub-01_ses-02_task-attlearn_run-1_desc-motion_timeseries.json

# adapt code so that we can call the function script from the command line?
# either way, adapt so that we can call in a list of participant numbers and execute code on all associated files

'''data_dir = '/Users/kels/Insync/tmp-data/phys_regress/' '''

# path should exlude BIDS format assumption as it is added in functions code 
data_dir = '/data/VALCERT/derivatives/fmriprep/'
#subject_number = ['01']
session_number = ['02'] # this assumes data is in BIDS
runs = getmov.pd.Series(str(x) for x in [1, 2, 3])
task = ['attlearn']

for i in range(len(sublist)):

    #print("contents: ")
    #print(sublist[i])
    subject_number=sublist[i]

    fnms = getmov.list_files(data_dir, subject_number, session_number, runs, task)
    out_fnms = [getmov.print_motion_regressors_for_spm(x) for x in fnms]
# %%

# /data/VALCERT/derivatives/fmriprep/sub-01/ses-02/func
# sub-01/ses-02/func/
# sub-01_ses-02_task-attlearn_run-1_desc-confounds_timeseries.tsv

# sub-01_ses-02_task-attlearn_run-1_desc-confounds_timeseries.tsv

# now print out the movement regressor columns into a txt file ready for use in spm
# out_fnms = [getmov.print_motion_regressors_for_spm(x) for x in fnms]
