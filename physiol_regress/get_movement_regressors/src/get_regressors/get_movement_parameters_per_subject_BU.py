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
    #tmplt = ''.join([data_dir, 'sub-{0}/ses-{1}/func/sub-{0}_ses-{1}_task-{2}_run-{3}_desc-confounds_timeseries.tsv'])
    #return [tmplt.format(sub, sess, t, run) for sub in subject_number for sess in session_number for t in task for run in runs]

    # write code here to check for matching directory and account for leading zeros and update sub value accordingly
    # probably best to didtch the {0} etc usage below for this reason

    #print("SHOULD PRINT THIS")

    #sub_str = str(subject_number[0])
    #sess_str = str(session_number[0])
    #run_str = str(runs)

    #print("sub_str %s" % sub_str)
    # Modify the regex pattern to match the exact subject number with potential leading zeros
    #sub_pattern = re.compile(r'\bsub-0*{}\b'.format(subject_number))
    #sub_pattern = re.compile(r'\bsub-0*{}(?:\b|$)'.format(re.escape(subject_number[0])))
    #sub_pattern = re.compile(r'\bsub-0+{}(?:\b|$)'.format(re.escape('017')))
    sub_pattern = re.compile(r'\bsub-0*{}(?:\b|$)'.format(re.escape(subject_number[0].lstrip('0'))))

    #sub_pattern = re.compile(r'^sub-0*{}$'.format(subject_number))
    
    # print("sbuject_number")
    # print(subject_number)
    # print("sub_pattern")
    # print(sub_pattern)

    #matching_subs = [folder for folder in os.listdir(data_dir) if os.path.isdir(os.path.join(data_dir, folder)) and sub_pattern.fullmatch(folder)]

    

    
    matching_subs = [folder for folder in os.listdir(data_dir) if os.path.isdir(os.path.join(data_dir, folder)) and sub_pattern.search(folder)]



    #matching_subs = [folder for folder in os.listdir(data_dir) if os.path.isdir(os.path.join(data_dir, folder)) and sub_pattern.match(folder)]


    # Find folders that match the pattern
    #matching_subs = [folder for folder in os.listdir(data_dir) if os.path.isdir(os.path.join(data_dir, folder)) and sub_pattern.search(folder)]
    # Find folders that match the pattern
    #matching_subs = [folder for folder in os.listdir(data_dir) if sub_pattern.match(folder)]

    # print("matching_subs: ")
    # print(matching_subs)

    # just for debug
    #session_number = [2]

    # Define regular expression patterns for subject and session
    # r'^0*' + str(number_to_match) + r'$'
    #sub_pattern = re.compile(r'^sub-\d+{}$'.format(subject_number))
    #sess_pattern = re.compile(r'^ses-0*{}$'.format(session_number))
    #sub_pattern = re.compile(r'\bsub-0*{}(?:\b|$)'.format(re.escape(subject_number[0].lstrip('0'))))
    sess_pattern = re.compile(r'\bses-0*{}(?:\b|$)'.format(re.escape(session_number[0].lstrip('0'))))
    
    # print("sess_pattern")
    # print(sess_pattern)

    ses_dir = str(data_dir+matching_subs[0])

    # print("ses_dir")
    # print(ses_dir)

    # Search for matching folders using the regular expression patterns
    #matching_subs = [folder for folder in os.listdir(data_dir) if sub_pattern.match(folder)]
    #matching_sess = [folder for folder in os.listdir(ses_dir) if sess_pattern.match(folder)]
    
    #matching_subs = [folder for folder in os.listdir(data_dir) if os.path.isdir(os.path.join(data_dir, folder)) and sub_pattern.search(folder)]
    matching_sess = [folder for folder in os.listdir(ses_dir) if os.path.isdir(os.path.join(ses_dir, folder)) and sess_pattern.match(folder)]

    # Check if there are matching sessions; if not, return an empty list
    #if not matching_sess:
     #   return []


    # print("matching_sess: ")
    # print(matching_sess)

    # print("gets here in again")
    # print("Look fucko")

    # Initialize an empty list to store the filenames
    regressor_files = []

    # Iterate through each subject and session to construct filenames for each run - technically doesn't need to be 2 for loops here
    #for sub in matching_subs:

     #   for sess in matching_sess:

    for run in runs:
        # Define regular expression pattern for the current run
        #sub_pattern = re.compile(r'\bsub-0*{}(?:\b|$)'.format(re.escape(subject_number[0].lstrip('0'))))
        #run_pattern = re.compile(r'run-\d+{}'.format(run))
        
        run = str(run)
        print("CONTENTS of run: ")
        print(run)

        run = run.lstrip('0')
        

        #run_pattern = re.compile(r'run-0*(\d+)')

        # re.compile('run-2')#

        run_pattern = re.compile(r'run-0*{}'.format(re.escape(run.lstrip('0'))))

       # matching_run = next((r.group(1) for r in map(run_pattern.search, os.listdir(os.path.join(data_dir, matching_subs[0], matching_sess[0], 'func'))) if r), None)
            

        # final_path = os.path.join(data_dir, '{}/{}/func/{}_{}_task-{}_{}_desc-confounds_timeseries.tsv'.format(
        #     matching_subs[0], matching_sess[0], matching_subs[0], matching_sess[0], task[0], matching_run or run
        # ))

        #print("Final Path top:", final_path)

        

        #run_pattern = re.compile(r'\brun-0*{}(?:\b|$)'.format(re.escape(run.lstrip('0'))))
        
        # run_pattern = re.compile(r'\brun-0*{}(?:\b|$)'.format(re.escape(run.lstrip('0'))))
        
        # final_path = os.path.join(data_dir, '{}/{}/func/{}_{}_task-{}_{}_desc-confounds_timeseries.tsv'.format(
        # matching_subs[0], matching_sess[0], matching_subs[0], matching_sess[0], task[0], '{}'
        # )).format(next((r.group() for r in map(run_pattern.search, os.listdir(os.path.join(data_dir, matching_subs[0], matching_sess[0], 'func'))) if r), None))

        #print("Content of final_path: ")
        #print(final_path)


        print("run_pattern contents: ")
        print(run_pattern)

        #file_directory = os.path.join(data_dir, matching_subs[0], matching_sess[0], 'func')
        #print("Directory:", file_directory)

        # Search for the matching run in the current session folder
        matching_run = next((r.group() for r in map(run_pattern.search, os.listdir(os.path.join(data_dir, matching_subs[0], matching_sess[0], 'func'))) if r), None)

        print("matching_run contents: ")
        print(matching_run)

        # If a matching run is found, construct the filename and add it to the list
        if matching_run:
            # /data/VALCERT/derivatives/fmriprep/sub-01/ses-02/func
            # sub-01_ses-02_task-attlearn_run-1_desc-motion-physregress_timeseries
            #filename = os.path.join(data_dir, '{}/ses-{}/func/{}_{}_task-{}_{}_desc-confounds_timeseries.tsv'.format(sub, sess, sub, sess, task, matching_run))
            filename = os.path.join(data_dir, '{}/{}/func/{}_{}_task-{}_{}_desc-confounds_timeseries.tsv'.format(matching_subs[0], matching_sess[0], matching_subs[0], matching_sess[0], task[0], matching_run))
            regressor_files.append(filename)

    print("regssor_files contents")
    print(regressor_files)

    # Return the list of filenames
    return regressor_files
  
    # make numbers dynamic for sub, sess, and run...
    # sub_pattern = r'^sub-0*' + sub_str + r'$'
    # print("sub")
    # print(sub_pattern)
    # ses_pattern = r'^ses-0*' + ses_str + r'$'
    # print("ses")
    # print(ses_pattern)
    # run_pattern = r'run-0*' + run_str + r'$'
    # print("runs")
    # print(runs)
    # print("run")
    # print(run_pattern)
    # # problem with run is that it's a list of values

    # print("sub_pattern %s" % sub_pattern)
        
    # # Search for a matching folder using the regular expression pattern
    # for sub_fold in os.listdir(data_dir):
    #     if re.match(sub_pattern, sub_fold):
    #         sub_str_match = sub_fold
    #         print(sub_str_match)
    #         for ses_fold in os.listdir(data_dir+sub_str_match):
    #             if re.match(ses_pattern, ses_fold):
    #                 ses_str_match = ses_fold
    #                 print(ses_str_match)
    #                 for run_fold in range(len(glob.glob(data_dir+sub_str_match+"/"+ses_str_match+"/func/*"))):
    #                     fileList = glob.glob(data_dir+sub_str_match+"/"+ses_str_match+"/func/*")
    #                     print("With func")
    #                     print(fileList[run_fold])
    #                     if re.match(run_pattern, fileList[run_fold]):
    #                         run_str_match = run_fold
    #                         print(run_str_match)

    #         #for run_fold in os.listdir(data_dir+sub_str_match):
    #         #print(sub_str_match)

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
