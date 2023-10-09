#### wrapper code to use the functions defined in event_analysis_functions.R
#### to get trial data in relevant format to define glms using spm12 functionality
# K. Garner, 2020
# --------------------------------------------------------------------
rm(list=ls())

# load packages and define session variables
library(tidyverse)
library(jsonlite)
source('events_analysis_functions.R')

################################################################################

# SPM control panel -> uncomment which version to create

# create motor sanity check SPM files
#motor_sanity_on = TRUE

# create experiment SPM files
motor_sanity_on = FALSE

################################################################################

# get list of subject numbers who did fmri task
sub_nums <- t(read.csv('/data/VALCERT/derivatives/complete-participants.csv', header = FALSE))
runs <- rep(3, length(sub_nums)) # this needs to be a vector of length sub_nums, with the corresponding number of runs we
runs[which(sub_nums == 137)] <- 2
# have for that participant
session = 2
TR = 1510
save_alldat_loc <- "/data/VALCERT/derivatives/beh_shaped_data_analysis" # NOTE - THIS NEEDS TO BE DEFINED - WHERE SHALL WE SAVE THE BEHAV DF?

data_dir = '/data/VALCERT/derivatives/fmriprep/'

# beh data path pattern
#beh_patt = "sub-[0-9]*"

# sub_folders <- beh_data_path_patt(data_dir, beh_patt)
# sub_folders
# 
# looky<-json_file_list(1,sub_folders)
# looky[[1]]$resp_order

# file_names <- beh_data_file_patt(sub_folders[1],beh_patt)
# file_names
# example: "resp_key": "clockwise: j, anticlockwise: f",
#resp_map_counter(1,2,data_dir)

count = 0

# Define function to print onsets
# --------------------------------------------------------------------
get_spm_onsets_and_data_4_analysis <- function(sub, runN, data_dir, verbose){
  # for a single subject, get mri behaviour details and save the outputs to
  # a json glm file for use with spm (one json file per run)
  # return a dataframe containing the behavioural data concatenated across
  # the runs for that participant, ready for further analysis
  # Args:
  # -- sub [int]: the subject number to be analysed
  # -- runN [int]: how many runs do we have for that subject?
  # -- data_dir [str]: where do you want outputs to be saved? e.g. '~/Insync/tmp-data/full-exp-pilot-raw'
  #                      functions assume that this is the top level for where sub-x/ses-x/beh lives
  # -- verbose [TRUE or FALSE]: return plot of subject data?
  # Returns:
  # -- json file for each run containing names, onsets and durations for defining glm in spm
  # -- dat_4_behav_analysis [dataframe]: dataframe containing the behavioural data
  #                                      for that participant for further analysis
  # -- densities for reward cond x cueing effect, if verbose is TRUE
  
  nruns <- runN
  
  # need to write version of below for motor files
  
  fn = "_ses-02_task-learnAtt_acq-TR%d_run-0%d_events.tsv"
  e_nms = get_mri_fnames(sub, fn, TR, nruns, "beh", data_dir) 
  
  #print(paste0("e_nms STRAIGHT after get_mri_fnames = ", e_nms))
  
  # e_nms only ever has one sub at a time but all over their relevant files
  rownames(e_nms) <- sub # building row names based using sub numbers
  colnames(e_nms) <- 1:nruns # building column names using run numbers
  
  #print(paste("CHECK values 1:nruns  = ", 1:nruns))
  
  #print(paste0("CONTENTS e_nms = ", e_nms))
 
  #print("stop here")
  
  # now get event details per run returned as a list
  event_timings <- lapply(e_nms, get_event_times_data)
  fn = "_ses-02_task-learnAtt_acq-TR%d_run-0%d_trls.tsv"
  behav_dat <- get_mri_dat(sub, session, data_dir, "beh", fn, TR, nruns)
  
  #print(paste0("contents behav_dat: ", behav_dat))

  fn = "_ses-02_task-learnAtt_acq-TR%d_run-0%d_trls_tbl.txt"
  task_dat <- get_mri_dat(sub, session, data_dir, "beh", fn, TR, nruns, sep=",")
  
  
  #print(paste0("contents task_dat: ", task_dat)) 
  # does contain ccw column
  
  for (i in 1:length(task_dat)) names(task_dat[[i]])[names(task_dat[[i]]) == "trial_num"] = "t"
  all_behav_info <- mapply(function(x,y) inner_join(x, y, by = c("sub", "sess", "t", "run")), behav_dat, task_dat, SIMPLIFY = FALSE)
  
  # contains all columns from both beh data files - so retain the ccw column for motor
  # print(paste0("CONTENT all_behav_info: ", all_behav_info))
  
  # now I have all the behavioural info for each run, I can first
  # allocate the conditions to each run's data, then combine with the event timing
  # data and write the spm glm json files
  # I will also be ready to rbind the data from across the runs for
  # behavioural analysis
  all_behav_info <- lapply(all_behav_info, allocate_conditions_on_d)
  
  # adds cert/probaiblity column
  #print(paste0("CONTENT all_behav_info: ", all_behav_info))
  
  # now combine with event timing data
  # dat, evs, sub, sess, run, sub_folders, motor_sanity
  # function(dat, evs, sub, sess, run, sub_folders, motor_sanity = FALSE)
  # run line below to generate experimental onset SPM files
  # events_4_spm <- mapply(match_behaviour_to_event_timings, all_behav_info, event_timings, SIMPLIFY = FALSE)
  #print(paste0("The 1 below represents Run 1 of the file of interest; this is only applicable to the motor file generation"))
  # run line below to generate motor sanity check SPM files
  namePatt<-"_task-learnAtt_acq-TR1510_bold_"
  events_4_spm <- mapply(match_behaviour_to_event_timings, all_behav_info, event_timings, motor_sanity=motor_sanity_on, sub, session, 1, data_dir, namePatt, SIMPLIFY = FALSE)
  
  #print(paste0("CONTENT events_4_spm: ", events_4_spm))
  
  # now write to json files
  lapply(1:length(events_4_spm), function(x) write_json_4_spm(events_4_spm[[x]], fpath=data_dir, sub, x, motor_sanity = motor_sanity_on))
  
  # now rbind behavioural data and plot
  dat_4_behav_analysis <- do.call(rbind, all_behav_info)
  if(verbose) {p = dat_4_behav_analysis %>% filter(resp == 1) %>% ggplot(aes(x=cert, y=rt, col=reward_type)) + 
                                                            geom_violin(alpha = 0.5) + 
                                                            geom_boxplot(width = 0.1) +
                                                            facet_wrap(~reward_type) + 
                                                            ggtitle(paste("sub", dat_4_behav_analysis$sub[1]))
    if (sub < 10){
      sub_str <- sprintf("sub-0%d", sub)
    } else {
      sub_str <- sprintf("sub-%d", sub)
    }
    ggsave(filename = paste(data_dir, sub_str, "/", "ses-02/", "beh/", sub_str, "_behavsum.pdf", sep=""), 
                            plot = p, units = "cm", width = 20, height = 20)
  }
  list(dat_4_behav_analysis)
}

# Run function
# --------------------------------------------------------------------
dat <- mapply(get_spm_onsets_and_data_4_analysis, sub = sub_nums, runN = runs, MoreArgs = list(data_dir = data_dir, verbose = FALSE))

# there should 3 trials missing in one file??
# subject number
dat[[17]]$sub[1]

inspect_92 <- as.data.frame(dat[17])

all_dat <- do.call(rbind, dat) # this concatenates all the participant behavioural data into a dataframe

# only keep participants that have >=60% collapsed accuracy
filtered_60p_df <- all_dat %>%
  group_by(sub) %>%
  summarize(total_obs_count = n(), # total num observations
            count_correct = sum(resp == 1)) %>% # number of 1 values)
  mutate(acc = count_correct / total_obs_count) %>%  # calculate accuracy
  filter(acc >= 0.6) %>%  # filter for accuracy >= 60%
  left_join(all_dat, by = "sub")

################################################################################
# # sanity check 60% filter numbers - uncomment to use
# 
# sanity_check_df <- filtered_60p_df
# 
# for (part_num in unique(sanity_check_df$sub)){
# 
#   #print(num)
#   sixtyP <- all_dat[all_dat$sub==part_num,]
#   #unique(sixtyP$sub) # check unique values of participant
#   # calculate percentage correct for this participant
#   Percentage_Correct = sum(sixtyP$resp)/length(sixtyP$t)
# 
#   # Grab the first acc value for participant of interest
#   first_value <- sanity_check_df %>% filter(sub == part_num) %>% slice(1) %>% pull(acc)
#   cat("Sanity Percentage, ", Percentage_Correct, "Filter Percentage", first_value, "        ")
#   # sanity check for the sanity check!
#   #print(round(0.9212598, digits=7) == round(first_value, digits=7)) # return TRUE if the same value
#   print(Percentage_Correct == first_value) # return TRUE if the same value
# 
# }
################################################################################

# filter using piping - correct only trials, RT restictions
beh_data_corr_resp_df <- filtered_60p_df %>% filter(resp == 1) %>% filter(rt>=0.250)

# filter for correct and incorrect accuracy
beh_data_acc_resp_df <- filtered_60p_df %>% filter(rt>=0.250)

#unique(beh_data_corr_resp_df$accuracy) # should return 1
range(beh_data_corr_resp_df$rt) # should return a range of no lower than 0.250

# eyeball the median of response time by participant and desired conditions
median_rt_by_part_prob_rew <- beh_data_corr_resp_df %>% group_by(sub, cert, reward_type) %>% summarise(median_rt = median(rt))
median_rt_by_part_prob_rew

# filter based on rts outliers > 2.5 sd from median
beh_data_rt_filt <- beh_data_corr_resp_df %>%
  group_by(sub, cert, reward_type) %>% 
  summarise(median_rt = median(rt)) %>%
  ungroup() %>% # remove grouping info
  left_join(beh_data_corr_resp_df, median_rt, by = c("sub", "cert", "reward_type")) %>% # merge the median values into df by specified cols
  filter(rt <= median_rt + 2.5 * sd(rt))

# same as above for accuracy
# filter based on rts outliers > 2.5 sd from median
beh_data_acc_filt <- beh_data_acc_resp_df %>%
  group_by(sub, cert, reward_type) %>% 
  summarise(median_rt = median(rt)) %>%
  ungroup() %>% # remove grouping info
  left_join(beh_data_acc_resp_df, median_rt, by = c("sub", "cert", "reward_type")) %>% # merge the median values into df by specified cols
  filter(rt <= median_rt + 2.5 * sd(rt))




# give value coding meaningful labels for plots and stats

# reward_type: 1=h/h, 2=h/l, 3=l/l, 4=l/h"
# "rew": "reward available: 1 = high (50), 0 = low (5)",

rt_analysis_data <- beh_data_rt_filt %>%
  mutate(Target_Location = ifelse(position == 0, "left_side",
                                  ifelse(position == 1, "right_side",
                                         position))) %>%
  mutate(Incentive_Value = ifelse(reward_type == "htgt/hdst", "h/h",
                                  ifelse(reward_type == "htgt/ldst", "h/l",
                                         ifelse(reward_type == "ltgt/ldst", "l/l",
                                                ifelse(reward_type == "ltgt/hdst", "l/h",
                                                       reward_type)))))

# same as above for accuracy data
acc_analysis_data <- beh_data_acc_filt %>%
  mutate(Target_Location = ifelse(position == 0, "left_side",
                                  ifelse(position == 1, "right_side",
                                         position))) %>%
  mutate(Incentive_Value = ifelse(reward_type == "htgt/hdst", "h/h",
                                  ifelse(reward_type == "htgt/ldst", "h/l",
                                         ifelse(reward_type == "ltgt/ldst", "l/l",
                                                ifelse(reward_type == "ltgt/hdst", "l/h",
                                                       reward_type)))))

# aggregate rt dataframes
stats_rt_analysis_data<-aggregate(rt_analysis_data[c("rt")], 
                                  by = rt_analysis_data[c("cert", "Incentive_Value", "sub")], FUN=mean)

stats_rt_plot_data<-aggregate(rt_analysis_data[c("rt")], 
                              by = rt_analysis_data[c("cert", "Incentive_Value")], FUN=mean)

# calculate probability of correct response
prob_acc_df <- acc_analysis_data %>%
  group_by(sub, cert, Incentive_Value) %>% # perform operation by these columns
  summarize(total_obs_count = n(), # total num observations
            count_correct = sum(resp == 1)) %>% # number of 1 values
  mutate(acc_probability = count_correct/total_obs_count)

# aggregate for plot
stats_acc_plot_data<-aggregate(prob_acc_df[c("acc_probability")], 
                               by = prob_acc_df[c("cert", "Incentive_Value")], FUN=mean)


# save various dataframes to import into RMarkdown
# save as RDS files

saveRDS(stats_rt_analysis_data, paste0(save_alldat_loc,"/stats_rt_analysis_data.rds"))
saveRDS(stats_rt_plot_data, paste0(save_alldat_loc,"/stats_rt_plot_data.rds"))
saveRDS(acc_analysis_data, paste0(save_alldat_loc,"/acc_analysis_data.rds"))
saveRDS(stats_acc_plot_data, paste0(save_alldat_loc,"/stats_acc_plot_data.rds"))
