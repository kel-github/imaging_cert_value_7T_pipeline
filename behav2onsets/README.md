# Behavioural data analysis

These R functions: <p>

a) print the event timing info to json files in order to model the data 
in SPM - i.e. the json file contains names, onsets, durations <p>
b) conducts the analysis of the behavioural data. <p>

## Instructions

1. Make sure each subject's 'beh' folder is joined with the 'source' and
'derivatives/fmriprep' folders

2. Use 'prnt_spm_json_nd_perform_behav_analysis.R' to attain the json files
and to conduct the behavioural analysis.
 - ensure sub_nums on line 13 is pointing to the correct csv file
 - check that data_dir [line 20] is also correctly defined. This should point
 to the derivatives/fmriprep folder.


