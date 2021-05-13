#### function to wrange original events and trial data from STRIWP1, 
#### to create event files for import into matlab as an SPM onsets mat
# K. Garner, 2019
# --------------------------------------------------------------------
rm(list=ls())

# install packages
# --------------------------------------------------------------------
library(dplyr)

# define environment variable etc
# --------------------------------------------------------------------
sub = 3
ses = 2
data_dir = '~/Dropbox/MC-Projects/imaging-value-cert-att/striwp1/'
TR = 700

get_event_times_data <- function(sub, ses, data_dir, TR){
   # use this function to load the behavioural log file, remove extraneous events, amd code the events 
   ####### first load up event file, cut extraneous events and number trials
   pn <- 'sub-0%d_ses-0%d_task-learnAtt_acq-TR%d_events.tsv'
   fPath = sprintf(paste(data_dir, 'sub-0%d/ses-0%d/func/', pn, sep=""), sub, ses, sub, ses, TR)
   event.times = read.table(file = fPath, sep = '\t', header = TRUE)
   # if required, chop off everything prior to the onset of the first dummy scan
   n.pre = which(event.times$event=="dummy scan")[1]-1
   if (any(n.pre)) event.times = event.times[-c(1:n.pre),]
   event.times$rel.onset = event.times$onset - event.times$onset[1]
   # all events are recorded for every trial (see experimental code), so can just number trials according to the 
   # following simple algorithm
   n.dummy = which(event.times$event == "end dummy")
   t.trials = 128
   t.events = 6
   all.trials = rep(1:t.trials, each=t.events)
   if (length(event.times$onset)-n.dummy != (t.trials*t.events)){ # if for some reason you don't have all the trials
        # get the last trial for which you have a complete set of events
      last.trial = max(which(event.times$event == "final fix"))   
      event.times$e = c( rep(0, times=n.dummy), rep( c(1:6), times=(last.trial-n.dummy)/t.events), rep(0, times=length(event.times$onset)-last.trial) )
      event.times$t = c( rep(0, times=n.dummy), all.trials[1:sum(event.times$e>0)], rep(0, times=length(event.times$onset)-last.trial) )
   } else {
     event.times$e = c( rep(0, times=n.dummy), rep( c(1:6), times=t.trials) )
     event.times$t = c( rep(0, times=n.dummy), all.trials[1:sum(event.times$e>0)] )
   }
   # ditch rows that are not part of a trial
   event.times[event.times$t != 0, ]
}


get_conditions <- function(sub, ses, data_dir, TR){
  # use this function to get a dataframe of the trial events and associated responses
  pn <- 'sub-0%d_ses-0%d_task-learnAtt_acq-TR%d_trls.tsv'
  fPath = sprintf(paste(data_dir, 'sub-0%d/ses-0%d/func/', pn, sep=""), sub, ses, sub, ses, TR)
  trls = read.table(file = fPath, sep = '\t', header = TRUE)
  pn <- 'sub-0%d_ses-0%d_task-learnAtt_acq-TR%d_trls.txt'
  fPath = sprintf(paste(data_dir, 'sub-0%d/ses-0%d/func/', pn, sep=""), sub, ses, sub, ses, TR)
  xtra.info = read.table(file = fPath, sep = ',', header = TRUE)
  names(xtra.info)[1] = "t"
  xtra.info = subset(xtra.info, select= -c(probability, position, ccw, hrz, block_num, reward_trial))
  trls = inner_join(trls, xtra.info, by="t")
  
  # conditions to assign
  # only correct responses:
  # h/h 80 L, h/h 80 R, h/h 50 L, h/h 50 R, h/h 20 L, h/h 20 R, 
  # l/l 80 L, l/l 80 R, l/l 50 L, l/l 50 R, l/l 20 L, l/l 20 R,
  # l/h 80 L, l/h 80 R, l/h 50 L, l/h 50 R, l/h 20 L, l/h 20 R,
  # h/l 80 L, h/l 80 R, h/l 50 L, h/l 50 R, h/l 20 L, h/l 20 R,
  # cw, ccw
  # exp high, exp low, unexp high, unexp low
  trls$reward_type = as.factor(trls$reward_type)
  levels(trls$reward_type) = c("hh", "hl", "ll", "lh")
  trls$cue = as.factor(trls$cue)
  levels(trls$cue) <- c(".8", ".2", ".5")
  trls$loc = as.factor(trls$loc)
  levels(trls$loc) = c("left", "right")
  trls$valid = NA
  trls$valid[ trls$cue == ".8" & trls$loc == "left" ] = "valid"
  trls$valid[ trls$cue == ".8" & trls$loc == "right" ] = "invalid"
  trls$valid[ trls$cue == ".2" & trls$loc == "left" ] = "invalid"
  trls$valid[ trls$cue == ".2" & trls$loc == "right" ] = "valid"  
  trls$valid[ trls$cue == ".5" ] = "valid"
  
  # trials are already marked as correct or incorrect 
  # (see resp variable, and do_response_score.m from the associated matlab code)
  trls  
}

match_conditions_to_events <- function(event.times, trls){
  # this function will take dataframes event.times & trls, and match them together to get one dataframe
  
  
}
  
