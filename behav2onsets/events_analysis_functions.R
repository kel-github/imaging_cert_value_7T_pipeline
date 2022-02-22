#### function to wrange original events and trial data from STRIWP1, 
#### to create event files for import into matlab as an SPM onsets mat
# K. Garner, 2019
# --------------------------------------------------------------------

get_mri_fnames <- function(i, fn, TR, nruns, ses_type, data_path){
  # get the filenames for given subject i, and sessions in j (can be plural)
  # key args
  # -- i = subject number
  # -- fn = file name pattern (string)
  # -- TR = TR used for acquisition
  # -- nruns = total number of runs
  # -- ses_type = name of folder containing data (e.g. "beh")
  # -- data_path = where is the top level of the data (Assumes BIDS)
  if (i < 10){
    sub_str = "sub-00%d"
  } else if (i > 9 & i < 100) {
    sub_str = "sub-0%d"
  } else {
    sub_str = "sub-%d"
  }
  fn <- paste(sub_str, fn, sep="")
  get_session_strings <- function(x) dir(sprintf(paste(data_path, sub_str, "ses-02", ses_type, sep = "/"), i), pattern=sprintf(fn, i, TR, x), full.names = TRUE)
  do.call(cbind, lapply(1:nruns, get_session_strings))
}

get_event_times_data <- function(fn){
   # use this function to load the behavioural log file, remove extraneous events, amd code the events 
  # --fn: the full file path to the event file, attained using get_mri_fnames
  ####### first load up event file, cut extraneous events and number trials
  
   event.times = read.table(file = fn, sep = '\t', header = TRUE)
   # if required, chop off everything prior to the onset of the first dummy scan
   # see https://github.com/kel-github/imaging-cert-reward-att-task-code/blob/master/sess-mri-exp/run_mri_session.m
   # for code that shows that trimming the first pulse value is necessary, as it is a dummy
   # value used to get the event file writing started
   n.pre = which(event.times$event=="dummy scan")[1]-1 
   # what is the impact for timing?
   if (any(as.logical(n.pre))) event.times = event.times[-c(1:n.pre),]
   event.times$rel.onset = event.times$onset - event.times$onset[1]
   # all events are recorded for every trial (see experimental code), so can just number trials according to the 
   # following simple algorithm
   n.dummy = which(event.times$event == "end dummy")
   t.trials = 128
   t.events = 5
   all.trials = rep(1:t.trials, each=t.events)
  
   # code events of interest with a specific value
   event.times$e = 0
   events = c("value cues", "spatial cue", "target", "response", "feedback")
   vals = c(1:length(events))
   for (i in 1:length(events)) event.times$e[event.times$event == events[i]] = vals[i]
   
   
   if (length(event.times$onset)-n.dummy != (t.trials*t.events)){ # if for some reason you don't have all the trials
        # get the last trial for which you have a complete set of events
      last.trial = max(which(event.times$event == "pulse - end trial")) 
      if (last.trial < nrow(event.times)) event.times$e[(last.trial+1):nrow(event.times)]=0  # if we ended at the end of a trial, don't do anything, otherwise....
   } 

   # ditch rows that are not part of a trial
   event.times = event.times[event.times$e != 0, ]
   # correctly assign trial numbers
   t.start = which(event.times$e==1)
   t.end = which(event.times$e==5)
   ts = 1:length(t.start)
   event.times$t = 0
   for (i in ts) event.times$t[c(t.start[i]:t.end[i])] = i
   event.times
}

get_mri_dat <- function(subject, session, data_path, ses_type, fn, TR, runs, sep = "\t"){
  # this function takes the filenames produced by get_mri_fnames, and 
  # reads in the data from each, outputting a longform dataframe
  # key args
  # -- subject: subject number from which you wish to get data
  # -- sessions: session numbers, should be one list, same across all subjects
  # -- ses_type = "behav" or "func"
  # -- fn = filename pattern, to be linked to subject str
  # -- TR = TR used for acquisition
  # -- runs = n runs from session
  # -- sep = separator pattern in the data file
  files <- do.call(rbind, lapply(subject, get_mri_fnames, fn=fn, TR=TR, nruns=runs, ses_type=ses_type, data_path = data_path))
  rownames(files) <- subject
  colnames(files) <- 1:runs
  resplog <- function(i, j) {
    tmp = read.table(files[as.character(i),as.character(j)], sep = sep, header = TRUE)
    tmp$sub = i
    tmp$sess = session
    tmp$run = j
    tmp
  }
  
  d <- lapply(1:nruns, function (j) resplog(subject, j))
  d
}

allocate_conditions_on_d <- function(d){
  # allocate factors to the dataset d (output by either get_dat or get_fmri_dat)
  # ALLOCATE CUE CONDITIONS
  
  d$cert <- NA
  d$cert[ d$probability == 1 & d$position == 0 ] = ".8"
  d$cert[ d$probability == 1 & d$position == 1 ] = ".2"
  d$cert[ d$probability == 2 & d$position == 1 ] = ".8"
  d$cert[ d$probability == 2 & d$position == 0 ] = ".2"
  d$cert[ d$probability == 3 ] = ".5"
  d$cert <- as.factor(d$cert)
  
  d$reward_type <- as.factor(d$reward_type)
  levels(d$reward_type) <- c("htgt/hdst", "htgt/ldst", "ltgt/ldst", "ltgt/hdst")
  
  d
}

match_behaviour_to_event_timings <- function(dat, evs){
  # using the behaviour info that has been through 'allocate_conditions_on_d'
  # and the event timings info in evs, find the times and onsets for
  # each condition of interest.
  # conditions of interest are:
  # Left| Right tgt x Spatial Cue (.2, .5, .8) x Value Cues
  # Assuming modelling via delta stick from onset of value cues
  # Args:
  # -- dat [dataframe] produced using a combination of get_mri_dat (on task and behav data)
  #                    and 'allocate_conditions_on_d'
  # -- evs [dataframe] event timings from the run matching dat, acquired using 'get_event_times_data'
  # Returns:
  # list of names, onsets and durations of each condition, for use with make_spm_event_files
  sess_data <- inner_join(dat, evs[evs$event == "value cues",], by = "t")
  
  tgt_locs <- c("left", "right")
  spatial_cue_types <- unique(sess_data$cert)
  value_cue_types <- unique(sess_data$reward_type)
  
  names = sort(as.vector(outer(tgt_locs, spatial_cue_types, paste, sep="_")))
  names = sort(as.vector(outer(names, value_cue_types, paste, sep = "_")))
  
  nleft <- length(names)/2
  nspat <- nleft/3
  nval <- length(value_cue_types)
  
  sess_data$loc <- as.factor(sess_data$loc)
  levels(sess_data$loc) <- c("left", "right")
  
  onsets <- mapply(function(x, y, z) sess_data$rel.onset[sess_data$loc == x & sess_data$cert == y & sess_data$reward_type == z],
                                      x = sapply(1:length(names), function(x) str_split(names[[x]], "_")[[1]])[1,],
                                      y = sapply(1:length(names), function(x) str_split(names[[x]], "_")[[1]])[2,],
                                      z = sapply(1:length(names), function(x) str_split(names[[x]], "_")[[1]])[3,],
                   SIMPLIFY = FALSE)
  durations <- lapply(onsets, function(x) rep(0, length(x)))
  out <- list(names, onsets, durations)
  names(out) <- c("names", "onsets", "durations")
  out
}

write_json_4_spm <- function(events_4_spm, fpath, sub_num, run_num){
  # given the events list for spm, produced using 'events_4_spm'
  # write a json file for each run in the BIDS directory defined by fpath
  # Args:
  # -- events_4_spm [list]: list of events for each run, produced
  #                          using mapply(match_behaviour_to_event_timings)
  # -- fpath [str]: the location of the BIDS directory of choice
  # -- sub_num [int]: subject number
  # Outputs: 
  # -- a json file of names, onsets and durations for each run, printed to the 
  #                          BIDS directory of choice
  jsondata = list(names=unlist(events_4_spm$names),
                  onsets=unname(events_4_spm$onsets),
                  durations=unname(events_4_spm$durations))
  
  if (sub_num < 10){
    sub_str = "sub-00%d"
  } else if (sub_num > 9 & sub_num < 100) {
    sub_str = "sub-0%d"
  } else {
    sub_str = "sub-%d"
  }
  
  write_json(jsondata, sprintf(paste(fpath, "/",
                                     sub_str, 
                                     "/",  
                                     'ses-02/', 
                                     'beh/', 
                                     sub_str,
                                     '_ses-02_task-attlearn_run-%d_desc-glm-onsets.json', sep=''), 
                                      sub_num, sub_num, run_num)) 
  
  
}



get_subs_hands <- function(sub, ses, data_dir, TR){
  # use this function to find which orientation -> response mapping each participant had
  # need to check participant/key assignment
  pn <- 'sub-0%d_ses-0%d_task-learnAtt_acq-TR%d_bold.json'
  fPath = sprintf(paste(data_dir, 'sub-0%d/ses-0%d/func/', pn, sep=""), sub, ses, sub, ses, TR)
  j <- read_json(fPath)
  if (j$resp_order == 1) {
    cw = c("left", "right")
  } else {
    cw = c("right", "left")
  }
  cw
}


