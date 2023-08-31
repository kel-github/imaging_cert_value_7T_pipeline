# pass csv file containing particiapnt numbers - no header as first entry is in column is a participant number
sub_nums<-read.csv('/data/VALCERT/derivatives/complete-participants.csv', header = FALSE)

colnames(sub_nums)<-("part_nums")

# add a leading zero to subject numbers below sub-10
sub_nums$part_nums<-ifelse(as.numeric(sub_nums$part_nums)<10,paste0("0",sub_nums$part_nums),sub_nums$part_nums)

# define file name pattern including path, allowing for changing number values
# set ses to ses-02 here as it never changes in the current dataset
filepattern <- "/data/VALCERT/derivatives/fmriprep/sub-%s/ses-02/func/sub-%s_ses-02_task-attlearn_run-%s_desc-confounds_timeseries.tsv"

# define all potential run numbers as characters
runs <- c("1","2","3")

# create empty dataframe to hold participant number, run number, and calculated percentage values
FD_results <- data.frame(part_num = character(0), run = character(0), perc = numeric(0))

# set how many times to check for missing file:
# in this version, the first iteration is the default pattern, the subsequent
# 2 interations add one leading zero, and two leadings zeros respectively to 
# the run- parameter in the file name
max_iterations = 3 # original + one and two leading zeros

# set the FD censoring threshold in mm
censor_threshold = 0.2
# return runs that are >= n% FD threshold breaking
perc_threshold = 60

# for loop to cycle through all participants in the sub_nums dataframe
for(curr_sub in 1:length(sub_nums$part_nums)){
  
  # for loop to cycle through specified runs
  for (curr_run in 1:length(runs)){
    
    # set reiterate to 0; used for searching for missing files again with added leading zero/s
    reiterate = 0
    
    # initial file name pattern prior to no match being found
    # plug-in current sub number into foldefr path and into file name, and plug-in run number into file name
    findFile = sprintf(filepattern, sub_nums$part_nums[curr_sub], sub_nums$part_nums[curr_sub], runs[curr_run])

    # while loop where it retries
    while (reiterate < max_iterations){

      # try to execute the code below but catch if it fails:
      # if no file match is found the specified error code is printed to terminal
      # and upon retry the reiterate value will force a change to the file name pattern
      # where n leading zeros are added to the run- parameter
      tryCatch({
        
        
        # can automate this code to do n leading zeros checks for run... however, gets into mental loop territory
        if (reiterate == 1){
          
          # add one leading zero to run-n
          findFile = sprintf(filepattern, sub_nums$part_nums[curr_sub], sub_nums$part_nums[curr_sub], sprintf("%02d",as.integer(runs[curr_run])))
          
          # tell user that we are retrying to find the file using the printed pattern and explain what is different
          print(paste("Will try file pattern", findFile, "with 1 leading zeros in run-n parameter"))
          
        }
        
        if (reiterate == 2){
          
          findFile =sprintf(filepattern, sub_nums$part_nums[curr_sub], sub_nums$part_nums[curr_sub], sprintf("%03d",as.integer(runs[curr_run])))
          
          print(paste("Will try file pattern", findFile, "with 2 leadings zeros in run-n parameter"))
          
        }
        
        # increment reiterate value here in case the file is not found and thus force file pattern change as above
        reiterate = reiterate +1
        
        # uncomment below for sanity checks:
        
        # print(paste("Value of reiterate = ", reiterate))
        # print(paste("contents findFile: ", findFile))
        
        # pass file name matching pattern in findFile (pattern dependent upon above code as explained)
        mot_phys_reg <- read.table(findFile, header = TRUE, sep = "\t")
        
        # pass all values in the framewise_displacement in FD
        FD<-mot_phys_reg$framewise_displacement
        
        # turn any "n/a" into "0"
        FD_na_rid<-ifelse(FD=="n/a","0",FD)
        
        # count how many items in FD_na_rid are greater than or equal to the specified censor threshold
        FD_exceeded<-sum(as.numeric(FD_na_rid)>=censor_threshold)
        
        # calculate percentage of total number of rows:
        # divide number of FD exceeding the censor threshold by 1% of the total number of items
        # which will return the % of FDs exceeding the specified threshold
        percentage_FD_exceeded <- FD_exceeded/(length(FD_na_rid)*.01)
        
        #percentage_FD_exceeded
        
        # pass current subject, run, and the calculated % of FD exceeding specified censor threshold into a single row dataframe
        curr_details = data.frame(part_num = sub_nums$part_nums[curr_sub], run = runs[curr_run], perc = percentage_FD_exceeded)
      
        # append/bind the above single row dataframe to FD_results dataframe  
        FD_results <- rbind(FD_results,curr_details)
        
        # if all of the above ran without issue, break the while loop
        break
        
        # if there was an issue above (no matching file found)
        # run code below explaining error
      }, error = function(err){
        
        # print information about file not found
        print(paste("File", findFile, "not found..."))
        
        # after this the while loop wil try again by adding a leading zero.
        # It will only do this twice for 0n, and 00n, before moving onto the 
        # next run/participant
        
        
        } # end of error
      
      ) # end of tryCatch
    
    
    } # end of while loop used to reattempt file search with added leading zero/s
    
    
    
    
  } # end of sub_runs for loop
  
  
  
} # end of sub_nums$part_nums for loop

# all results
FD_results

# choose where to write output for each participant's run
write.csv(FD_results,"/home/jovyan/neurodesktop-storage/imaging_cert_value_7T_pipeline/physiol_regress/FD_results_point2_thresh.csv", row.names=FALSE)

# pass all participant rows that meet or exceed percentage FD threshold specified into dataframe
perc60 <-FD_results[FD_results$perc>=perc_threshold,]
perc60

# choose where to write dataframe containing each run meeting or exceeding percentage
write.csv(perc60,"/home/jovyan/neurodesktop-storage/imaging_cert_value_7T_pipeline/physiol_regress/FD_results_point2_60_perc.csv", row.names=FALSE)

# return max percentage and associated row information
FD_results[which.max(FD_results$perc),]

# return number of runs to be excluded
sum(FD_results$perc>=perc_threshold)

################################################################################

# plot histograms of percetenage exceeded for each run

hist_run_1 <- FD_results[FD_results$run=='1',c("part_num","perc")]
hist_run_2 <- FD_results[FD_results$run=='2',c("part_num","perc")]
hist_run_3 <- FD_results[FD_results$run=='3',c("part_num","perc")]

hist(as.numeric(hist_run_1$perc))
hist(as.numeric(hist_run_2$perc))
hist(as.numeric(hist_run_3$perc))


################################################################################
################################################################################
################################################################################
################################################################################

# sanity check individual participants below:
# double-check calculation used above

# pass individual file
mot_phys_reg_sub_n <- read.table("/data/VALCERT/derivatives/fmriprep/sub-01/ses-02/func/sub-01_ses-02_task-attlearn_run-1_desc-confounds_timeseries.tsv", header = TRUE, sep = "\t")

# capture FD column
FDn<-mot_phys_reg_sub_n$framewise_displacement

# change "n/a" to "0"
FD_na_rid_n<-ifelse(FDn=="n/a","0",FDn)

# count number of entries that are equal to or exceed censor_threshold
FD_exceeded_n<-sum(as.numeric(FD_na_rid_n)>=censor_threshold)

# calculate percentage of total number of rows that exceed threshold
percentage_FD_exceeded_n <- FD_exceeded_n/(length(FD_na_rid_n)*.01)
percentage_FD_exceeded_n