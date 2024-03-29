## example script to run the functions from the regressors package
# K. Garner 2022

# %%
# first define settings for list files

import get_movement_parameters_per_subject.py

'''data_dir = '/Users/kels/Insync/tmp-data/phys_regress/' '''
data_dir = '/data/VALCERT/derivatives/fmriprep/sub-01/ses-02/func'
subject_number = ['01']
session_number = ['02'] # this assumes data is in BIDS
runs = pd.Series(str(x) for x in [1, 2, 3])
task = ['attlearn']

fnms = list_files(data_dir, subject_number, session_number, runs, task)

# %%
# now print out the movement regressor columns into a txt file ready for use in spm
out_fnms = [print_motion_regressors_for_spm(x) for x in fnms]
