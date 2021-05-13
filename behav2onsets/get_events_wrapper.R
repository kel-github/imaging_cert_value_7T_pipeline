#### wrapper code to use the functions defined in event_analysis_functions.R
#### to get trial data in relevant format to define glms using spm12 functionality
# K. Garner, 2020
# --------------------------------------------------------------------
rm(list=ls())

# load packages and define session variables
library(tidyverse)
library(jsonlite)
source('events_analysis_functions.R')


sub_num = 1
nsess = 2
nTRs = 1
nRuns = 3


sessions = rep(c(2:(nsess+1)), each = nTRs)
# sub 1 sessions
data_dir = '~/Documents/image-quality-check-data/'
TRs = rep(c(1510), times=nsess)

# --------------------------------------------------------------------
write.subs.json.glm.files <- function(sub, ses, data_dir, TR, run){
  
  # first get the correct subject string
  if (sub < 10) {
    sub_str = paste('00', sub, sep="")
  } else if (sub > 9 & sub < 100) {
    sub_str = paste('0', sub, sep="")
  }  else {
    sub_str = paste(sub)
  }
  
  sess_data = get_data_for_sub_and_sess(sub, ses, data_dir, TR) #gives 'all.events'
  cw = get_subs_hands(sub, ses, data_dir, TR)
  make_spm_event_files(sess_data[[1]], cw, sub, ses, TR, data_dir)
}

mapply(write.subs.json.glm.files, ses=sessions, TR=TRs, MoreArgs=list(sub=sub.num,
                                                                      data_dir=data_dir))
