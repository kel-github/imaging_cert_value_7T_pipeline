# Behavioural data analysis

These R functions: <p>

a) print the event timing info to json files in order to model the data 
in SPM - i.e. the json file contains names, onsets, durations <p>
b) conducts the analysis of the behavioural data. <p>

## Instructions

1. Make sure each subject's 'beh' folder is copied from the 'source' to the relevant
'derivatives/fmriprep' folders

2. Use 'prnt_spm_json_nd_perform_behav_analysis.R' to attain the json files, print summary figures and get the dataframe for the overall behavioural analysis.
 - ensure sub_nums on line 13 is pointing to the correct csv file. This csv file contains only a column of subject numbers
 - ensure the runs variable on line 15 is complete. Each element should be the number of runs for the subject in the corresponding sub_nums vector
 - the save-alldat-loc variable on line 19 needs also to be defined. Where do you want to save the dataframe that contains all the behavioural data for all participant (on which we will do the analysis)
 - check that data_dir [line 21] is also correctly defined. This should point
 to the derivatives/fmriprep folder.
 
 ## Next steps:
 - There is now a summary figure in each participant's fmriprep/sub-x/ses-02/beh folder, for viewing
 - run data analysis on behavioural data set saved


