# cai2bids
- a set of functions to get data from cai 2 bids format, and validated

**How to use these functions**

1. move data from source and convert to .nii

- start an interactive job on awoonga using the command:
     qsub -I -A UQ-QBI -l ncpus=1 -l mem=10GB -l walltime=00:30:00
- from the home directory edit 'convert_data_to_BIDS' to bring over the subject data you want
    run
    
    ```./convert_data_to_BIDS```
    
2. extract phsyiological regressor files (the bids validator will ignore them for now but will use them later)

- in the same interactive job run
    ```
	ml matlab
    matlab
	```
- run 
    ```get_physio_regressor_files(wd, sub)```
    
  -  where wd is the bids directory, and sub is the subject number.
    
  -  Depends on extractCMRRPhysio.m being in the same folder
    
3. rename files so they follow BIDS convention
    
    - run ```rename2BIDS``` (note: this needs testing)

4. add 'taskName' to the bold json files to make them task compliant by running ```addtaskname2bids(wd, sub)``` in a new matlab session (depends on *JSONio* being in the same folder)
5. copy over behavioural data from source, extract and rename event files (function forthcoming)
6. Exit the interactive session
7. Now run the bids validator to get the log for that subject
    
     - run (from the home directiory):
     ```qsub run_bids_validator.sh``` (this file can be found in the folder *cluster_scripts*)
    
    - move the resulting job .OU file to BIDSDIR/derivatives/val-logs/sub-NUM/