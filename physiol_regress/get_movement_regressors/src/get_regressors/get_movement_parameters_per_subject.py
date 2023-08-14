# get motion regressors into a .txt file for use in PhysIO toolbox
# functions for getting motion regressors
### written by K. Garner, 2022  

import json
import pandas as pd

import os
import re
#import glob

# %%
# data_dir = '/clusterdata/uqkgarn1/scratch/data/' (Note: don't use expansion tilde!)
# subject_number = '01' 
# session_number = pd.Series(str(2)) # this assumes data is in BIDS
# runs = pd.Series(str(x) for x in [1, 2, 3])
# task = 'attlearn' (string, name of task for BIDS)

def list_files(data_dir, subject_number, session_number, runs, task):


    """create a list of regressor filenames for given subject
    Dependencies: assumes data is in BIDS format

    Args:
        data_dir (str): full file path to the data (typically ending in derivatives/fmriprep/)
        subject_number (string): subject number - either '0x', 'xx', or 'xxx'
        session_number (string): session number - either '0x' or 'xx' and so on
        runs (panda series/string): runs for that participant, size(1, nruns)
        task (string): name of task as it appears in the filename
    
    Returns:
        regressor_files (list of strings): a cell/list of len(run) containing the regressor filenames for that participant
    """

    # regex code that accounts for string sub- with either n or no leadings zeros
    # and we place the current sub number where the {} are (stripping any leading zeroes from it
    # in order to simplify the code).
    sub_pattern = re.compile(r'\bsub-0*{}(?:\b|$)'.format(re.escape(subject_number[0].lstrip('0'))))
      
    matching_subs = [folder for folder in os.listdir(data_dir) if os.path.isdir(os.path.join(data_dir, folder)) and sub_pattern.search(folder)]

    # print("matching_subs: ")
    # print(matching_subs)

    # regex code that accounts for string ses- with either n or no leadings zeros
    # and we place the current sess number where the {} are (stripping any leading zeroes from it
    # in order to simplify the code).
    sess_pattern = re.compile(r'\bses-0*{}(?:\b|$)'.format(re.escape(session_number[0].lstrip('0'))))
    
    # print("sess_pattern")
    # print(sess_pattern)

    ses_dir = str(data_dir+matching_subs[0])

    # print("ses_dir")
    # print(ses_dir)

    # Search for matching folders using the regex pattern in sess_pattern
    matching_sess = [folder for folder in os.listdir(ses_dir) if os.path.isdir(os.path.join(ses_dir, folder)) and sess_pattern.match(folder)]



    # Create empty list to store filenames
    regressor_files = []

    # iterate through each run added to the run list in the execution script
    for run in runs:

        
        run = str(run)
        # print("CONTENTS of run: ")
        # print(run)

        # regex code the accounts for string run- with either n or no leadings zeros
        # and we place the current run number where the {} are (stripping any leading zeroes from it
        # in order to simplify the code).
        run_pattern = re.compile(r'run-0*{}'.format(re.escape(run.lstrip('0'))))

        # print("run_pattern contents: ")
        # print(run_pattern)

        # Search for the matching run in the current session folder
        matching_run = next((r.group() for r in map(run_pattern.search, os.listdir(os.path.join(data_dir, matching_subs[0], matching_sess[0], 'func'))) if r), None)

        print("matching_run contents: ")
        print(matching_run)

        # If a matching run-n is found, construct the filename and append to list
        if matching_run:
            # join all the elements to build the targeted filename
            filename = os.path.join(data_dir, '{}/{}/func/{}_{}_task-{}_{}_desc-confounds_timeseries.tsv'.format(matching_subs[0], matching_sess[0], matching_subs[0], matching_sess[0], task[0], matching_run))
            regressor_files.append(filename)
        else:

            print("No match for pattern: ")
            print(run_pattern)
            print("For subject: ")
            print(matching_subs[0])

    print("regssor_files contents")
    print(regressor_files)

    # Return the list of filenames
    return regressor_files
  
    # #tmplt = ''.join([data_dir, sub_str_match+'/ses-{1}/func/'+sub_str_match+'_ses-{1}_task-{2}_run-{3}_desc-confounds_timeseries.tsv'])
    
    # #tmplt = ''.join([data_dir, sub_str_match+'/'+ses_str_match+'/func/'+sub_str_match+'_'+ses_str_match+'_task-{2}_'+run_str_match+'_desc-confounds_timeseries.tsv'])
    
    # tmplt = ''.join([data_dir, sub_pattern+'/'+ses_pattern+'/func/'+sub_pattern+'_'+ses_pattern+'_task-{2}_'+run_pattern+'_desc-confounds_timeseries.tsv'])
    

    # #print("GETTING HERE")
    # #print(tmplt)

    # return [tmplt.format(sub, sess, t, run) for sub in subject_number for sess in session_number for t in task for run in runs]



def print_new_json(fname, data): # function to print json file, given fname (str) and data = {}
    """print json file to fname, containing data

    Args:
       fname (str): full_file_path/file_name.json for json file
       data {}: json data in {}
    
    Returns:
        prints json file, does not return a value
    """
    with open(fname, 'w') as outfile:
        json.dump(data, outfile)

def print_motion_regressors_for_spm(confounds_fname): 
    """print movement regressors to a text file and print corresponding json file
    Dependencies: assumes data is in BIDS format

    Args:
        confounds_fname (str): 1 filepath/filename taken from the list output by list_files

    Returns:
        regressor_file_name (string): name of the motion regressor file that was printed by the function
        also prints a json sidecar file for each regressor txt file, not listed in return
    """
    data = pd.read_csv(confounds_fname, sep='\t', usecols=['trans_x', 'trans_x_derivative1',
                                                 'trans_y', 'trans_y_derivative1',
                                                 'trans_z', 'trans_z_derivative1',
                                                 'rot_x', 'rot_x_derivative1',
                                                 'rot_y', 'rot_y_derivative1',
                                                 'rot_z', 'rot_z_derivative1'])
    data = data.fillna(value=0) # for SPM
    
    savefname = confounds_fname.replace('confounds', 'motion')
    savefname = savefname.replace('tsv', 'txt')
    data.to_csv(savefname, sep=' ', index=False, header=False)
    # write json file to accompany
    motionfname_json = savefname.replace('txt', 'json')
    motion_json_data = {"tsvType":"spm motion", 
                        "params":['trans_x', 'trans_x_derivative1',
                                  'trans_y', 'trans_y_derivative1',
                                  'trans_z', 'trans_z_derivative1',
                                  'rot_x', 'rot_x_derivative1',
                                  'rot_y', 'rot_y_derivative1',
                                  'rot_z', 'rot_z_derivative1'],
                        "source":savefname}
    print_new_json(motionfname_json, motion_json_data)
    return savefname




# %%
