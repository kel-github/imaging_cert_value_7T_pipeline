# cai2bids
- a set of functions to get data from cai 2 bids format, and validated

**How to use these functions**

1. move data from source and convert to .nii

- ensure data is copied to the appropriate source/ folder as defined in 'convert_data_to_BIDS'
- you'll need to make sure any extraneous files such as prematurely stopped runs/extra mp2rage (in the case of the distortion correction subs) have been removed
- in 'convert_data_to_BIDS' ensure that each subs and run variable is set correctly (for the subs you want to run)
- in terminal, navigate to the directory ~/Desktop/neurodesktop-storage/scripts/name-of-repo/cai2bids/ and run the command
    
    ```./convert_data_to_BIDS```

    NOTE: this data does not yet delete the original unformatted data from source, so delete it when you are sure you no longer need it, as having it around will clog things up
    NOTE: after running this, manually move the newly organised files to the level above (data/)
    
2. extract phsyiological regressor files (the bids validator will ignore them for now but will use them later)

    ```
	ml matlab
    matlab
	```
- run 
    ```get_physio_regressor_files(wd, sub)```
    
  -  where wd is the full path to the bids directory, and sub is the subject number. 
  -  Depends on extractCMRRPhysio.m being in the same folder
    
3. rename files so they follow BIDS convention
    
    - run ```./rename2BIDS``` after making sure the filepath is set correctly at the top of the script


4. add 'taskName' to the bold json files to make them task compliant by running ```addtaskname2bids(wd, sub)``` in a new matlab session (depends on *JSONio* being in the same folder)
5. copy over behavioural data from source, extract and rename event files (function forthcoming)

6. Now run the bids validator to get the log for that subject
    
     - run:
     ```./run_bids_validator``` (this file can be found in the folder *cluster_scripts*)
    
    - move the resulting job .OU file to BIDSDIR/derivatives/val-logs/sub-NUM/

7. manually copy the new BIDS-ified data back to where the source data came from (but one level up, to mirror the BIDS structure)
