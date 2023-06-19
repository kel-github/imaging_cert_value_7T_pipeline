#### wrapper code to use the functions defined in event_analysis_functions.R
#### to get trial data in relevant format to define glms using spm12 functionality
# K. Garner, 2020
# --------------------------------------------------------------------
rm(list=ls())

# load packages and define session variables
library(tidyverse)
library(jsonlite)
source('events_analysis_functions.R')

# get list of subject numbers who did fmri task
sub_nums <- t(read.csv('/data/VALCERT/derivatives/complete-participants.csv', header = FALSE))
runs <- rep(3, length(sub_nums)) # this needs to be a vector of length sub_nums, with the corresponding number of runs we
runs[which(sub_nums == 137)] <- 2
# have for that participant
session = 2
TR = 1510
save_alldat_loc <- "" # NOTE - THIS NEEDS TO BE DEFINED - WHERE SHALL WE SAVE THE BEHAV DF?

data_dir = '/data/VALCERT/derivatives/fmriprep/'

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
  
  fn = "_ses-02_task-learnAtt_acq-TR%d_run-0%d_events.tsv"
  e_nms = get_mri_fnames(sub, fn, TR, nruns, "beh", data_dir) 
  rownames(e_nms) <- sub
  colnames(e_nms) <- 1:nruns
  # now get event details per run returned as a list
  event_timings <- lapply(e_nms, get_event_times_data)
  fn = "_ses-02_task-learnAtt_acq-TR%d_run-0%d_trls.tsv"
  behav_dat <- get_mri_dat(sub, session, data_dir, "beh", fn, TR, nruns)
  fn = "_ses-02_task-learnAtt_acq-TR%d_run-0%d_trls_tbl.txt"
  task_dat <- get_mri_dat(sub, session, data_dir, "beh", fn, TR, nruns, sep=",")
  for (i in 1:length(task_dat)) names(task_dat[[i]])[names(task_dat[[i]]) == "trial_num"] = "t"
  all_behav_info <- mapply(function(x,y) inner_join(x, y, by = c("sub", "sess", "t", "run")), behav_dat, task_dat, SIMPLIFY = FALSE)
  # now I have all the behavioural info for each run, I can first
  # allocate the conditions to each run's data, then combine with the event timing
  # data and write the spm glm json files
  # I will also be ready to rbind the data from across the runs for
  # behavioural analysis
  all_behav_info <- lapply(all_behav_info, allocate_conditions_on_d)
  # now combine with event timing data
  events_4_spm <- mapply(match_behaviour_to_event_timings, all_behav_info, event_timings, SIMPLIFY = FALSE)
  # now write to json files
  lapply(1:length(events_4_spm), function(x) write_json_4_spm(events_4_spm[[x]], fpath=data_dir, sub, x))

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
dat <- mapply(get_spm_onsets_and_data_4_analysis, sub = sub_nums, runN = runs, MoreArgs = list(data_dir = data_dir, 
                                                                                                verbose = TRUE))
all_dat <- do.call(rbind, dat) # this concatenates all the participant behavioural data into a dataframe
save(all_dat, save_alldat_loc)

# function to go through and save each plot for each participant



