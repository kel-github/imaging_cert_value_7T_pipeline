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
sub_nums <- t(read.csv('~/Insync/tmp-data/clusters/derivatives/complete-participants.csv', header = FALSE))
# tmp single sub for pilot data
sub_nums = sub_nums[1]
session = 2
nruns = 3
TR = 1510

data_dir = '~/Insync/tmp-data/full-exp-pilot-raw'


# for a single subject, get mri behaviour details and save the outputs to
# a json glm file for use with spm (one json file per run)
fn = "_ses-02_task-learnAtt_acq-TR%d_run-0%d_events.tsv"
e_nms = get_mri_fnames(sub_nums[1], fn, TR, runs, "beh", data_dir) 
rownames(e_nms) <- sub_nums[1]
colnames(e_nms) <- 1:nruns
# now get event details per run returned as a list
event_timings <- lapply(e_nms, get_event_times_data)
fn = "_ses-02_task-learnAtt_acq-TR%d_run-0%d_trls.tsv"
behav_dat <- get_mri_dat(sub_nums[1], session, data_dir, "beh", fn, TR, nruns)
fn = "_ses-02_task-learnAtt_acq-TR%d_run-0%d_trls_tbl.txt"
task_dat <- get_mri_dat(sub_nums[1], session, data_dir, "beh", fn, TR, nruns, sep=",")
for (i in 1:length(task_dat)) names(task_dat[[i]])[names(task_dat[[i]]) == "trial_num"] = "t"
all_behav_info <- mapply(function(x,y) inner_join(x, y, by = c("sub", "sess", "t", "run")), behav_dat, task_dat, SIMPLIFY = FALSE)
# now I have all the behavioural info for each run, I can first
# allocate the conditions to each run's data, then combine with the event timing
# data and write the spm glm json files
# I will also be ready to rbind the data from across the runs for
# behavioural analysis



# --------------------------------------------------------------------
write.subs.json.glm.files <- function(sub, ses, data_dir, TR, run){
  
  sess_data = get_data_for_sub_and_sess(sub, ses, data_dir, TR) #gives 'all.events'
  cw = get_subs_hands(sub, ses, data_dir, TR)
  make_spm_event_files(sess_data[[1]], cw, sub, ses, TR, data_dir)
}

mapply(write.subs.json.glm.files, ses=sessions, TR=TRs, MoreArgs=list(sub=sub.num,
                                                                      data_dir=data_dir))
