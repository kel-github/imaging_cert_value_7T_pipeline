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
  files <- do.call(rbind, lapply(subjects, get_mri_fnames, fn=fn, TR=TR, nruns=runs, ses_type=ses_type, data_path = data_path))
  rownames(files) <- subjects
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


get_participant_data_from_mri_session <- function(subjects, sessions, data_path, TR=1510, runs, ses_type = "beh") {
  
  
  fn = "_ses-02_task-learnAtt_acq-TR%d_run-0%d_trls.tsv"
  d = do.call(rbind, lapply(subjects, get_mri_dat, sessions=sessions, data_path=data_path, ses_type=ses_type, fn=fn, TR=TR, runs=runs))
  
  fn = "_ses-02_task-learnAtt_acq-TR%d_run-0%d_trls_tbl.txt"
  t = do.call(rbind, lapply(subjects, get_mri_dat, sessions=sessions, data_path=data_path, ses_type=ses_type, fn=fn, TR=TR, runs=runs, sep=","))
  names(t)[names(t)=="trial_num"] = "t"
  
  d <- inner_join(d, t, by=c("sub", "run", "t", "sess"))
  d <- allocate_conditions_on_d(d)
  d
} 




























get_conditions <- function(sub_str, ses, data_dir, TR, run){
  # use this function to get a dataframe of the trial events and associated responses
  # also adds the deviation of each trial from the expected value of the stimulus
  # --sub_str = string denoting subject number - e.g. '001' 
  # --ses = number, denoting the session, e.g. 2
  # --data_dir: path to top level of data, assuming BIDS format
  # --TR: a number, e.g. 1510
  # --run: a number denoting the run number, e.g. 1
  ####### first load up event file, cut extraneous events and number trials
  
  pn <- 'sub-0%s_ses-0%d_task-learnAtt_acq-TR%d_run-0%d_trls.tsv'
  fPath = sprintf(paste(data_dir, 'sub-0%s/ses-0%d/beh/', pn, sep=""), sub_str, ses, sub_str, ses, TR, run)
  trls = read.table(file = fPath, sep = '\t', header = TRUE)
  pn <- 'sub-0%d_ses-0%d_task-learnAtt_acq-TR%d_trls_tbl.txt'
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
  levels(trls$reward_type) = c("ll", "lh", "hh", "hl")
  trls$cue = as.factor(trls$cue)
  levels(trls$cue) <- c(".8", ".2", ".5")
  trls$loc = as.factor(trls$loc)
  levels(trls$loc) = c("left", "right")
  trls$valid = NA
  trls$valid[ trls$cue == ".8" & trls$loc == "left" ] = "valid" # correctly coded .8 (for current purposes but not for running the task, this applies to the below also)
  trls$valid[ trls$cue == ".8" & trls$loc == "right" ] = "invalid" # incorrectly coded .8
  trls$valid[ trls$cue == ".2" & trls$loc == "left" ] = "invalid" # correctly coded .2
  trls$valid[ trls$cue == ".2" & trls$loc == "right" ] = "valid"  # incorrectly coded .2
  trls$valid[ trls$cue == ".5" ] = "valid"
  
  # now add regressors that define left_p.8, left_p.5, right_p.8, right_p.5
  trls$cue_cond = NA
  trls$cue_cond[ trls$cue == ".8" & trls$loc == "left" ] = "att_left_8"
  trls$cue_cond[ trls$cue == ".5" & trls$loc == "left" ] = "att_left_5"
  trls$cue_cond[ trls$cue == ".2" & trls$loc == "right" ] = "att_right_8"
  trls$cue_cond[ trls$cue == ".5" & trls$loc == "right" ] = "att_right_5" 
  trls$cue_cond <- as.factor(trls$cue_cond)
  # # recode so all .8's refer to valid trials, and .2's refer to invalid
  # trls$cue[ trls$valid == "valid" &  trls$loc == "right" & trls$cue == ".2"] = ".8"
  # trls$cue[ trls$valid == "invalid" & trls$loc == "right" & trls$cue == ".8"] = ".2"
  # 
  # trials are already marked as correct or incorrect 
  # (see resp variable, and do_response_score.m from the associated matlab code)
  trls$exp[trls$reward_type == "hh" & trls$rew_tot > 11] = "exp_high"
  trls$exp[trls$reward_type == "hl" & trls$rew_tot > 11] = "exp_high"
  trls$exp[trls$reward_type == "lh" & trls$rew_tot > 11] = "unexp_high"
  trls$exp[trls$reward_type == "ll" & trls$rew_tot > 11] = "unexp_high"
  trls$exp[trls$reward_type == "hh" & trls$rew_tot < 11] = "unexp_low"
  trls$exp[trls$reward_type == "hl" & trls$rew_tot < 11] = "unexp_low"
  trls$exp[trls$reward_type == "lh" & trls$rew_tot < 11] = "exp_low"
  trls$exp[trls$reward_type == "ll" & trls$rew_tot < 11] = "exp_low"
  trls$exp = as.factor(trls$exp)
  trls$sub <- as.factor(trls$sub)
  trls$TR = TR
  trls
}

match_conditions_to_events <- function(event.times, trls, ses){
  # this function will take dataframes event.times & trls, and match them together to get one dataframe
  # will also ditch the columns of no interest
  
  
  trls = subset(trls, select= -c(co1, co2, loc, cue))
  all.events = inner_join(trls, event.times, by="t")
  all.events$sess = ses
  all.events
}


get_data_for_sub_and_sess <- function(sub, ses, data_dir, TR){
  # use this function to apply get_event_times_data, get_conditions and 
  # match_conditions_to_events to one sub, ses & TR
  event.times = get_event_times_data(sub_str, ses, data_dir, TR, run)
  trls = get_conditions(sub, ses, data_dir, TR)
  sub.dat = match_conditions_to_events(event.times, trls, ses)
  list(sub.dat %>% arrange(rel.onset))
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

get_event_info <- function(cond, fact, ev, data){
  # use this function to extract the relevant onsets and durations for the specified condition
  # output = a list called event_data containing condition name, onsets and durations
  # inputs = cond = a string, specifying condition of interest - e.g. left (for left sided target)
  #          fact = a string, denoting the factor to which the condition belongs
  #          ev = a string, specifying the relevant trial event for that condition
  #          data = a dataframe, produced by using the function 'match_conditions_to_events"
  #          correct = a logical vector, denoting true for correct responses, false for not
  #          i = idx for the cond, fact, and ev vectors - this solution is applied as mapply was being 
  #          glitchy with passing in a dataframe to the MoreArgs function

  names=cond
  onsets=data[ (data[,match(parse(text=fact), colnames(data))] == cond) & data$event == ev, ]$rel.onset
  onsets=onsets[!is.na(onsets)]
  if (fact == "hand") {
    durations=abs(data[ (data[,match(parse(text=fact), colnames(data))] == cond) & data$event == ev, ]$duration)
  } else{
    durations=0
  }
  event_data=list(names=names, onsets=onsets, durations=durations)
  event_data
}

do.print.of.events <- function(stem, data, sub, ses, TR, data_dir){
  # use this function to print a specific list to a text file, each row is one list entry
  # output is actually space separated, will require conversion to tab separated
  pn <- paste('sub-0%d/ses-0%d/func/', 'sub-0%d_ses-0%d_task-learnAtt_acq-TR%d_', stem, '.tsv', sep="")
  fPath = sprintf(paste(data_dir, pn, sep=""), sub, ses, sub, ses, TR)
  lapply(data, write, fPath, sep="\t", append=TRUE, ncolumns=1000)
}

make_spm_event_files <- function(all.events, cw, sub, ses, TR, data_dir){
  # use this function to make an spm mat file - this can be taken to not only run analysis but also
  # to check for linear independence etc
  # output is a json file
  # cw =output from get_subs_hands
  all.events$or = as.factor(all.events$or)
  levels(all.events$or) <- c("cw", "ccw")
  all.events = rbind( all.events %>% filter(or == "cw") %>% mutate(hand = paste(cw[1], "hand", sep="_")), all.events %>% filter(or == "ccw") %>% mutate(hand = paste(cw[2], "hand", sep="_"))) 
  all.events = all.events %>% arrange( rel.onset ) 
  all.events$hand = with(all.events, as_factor(hand))
  
  #fact.names = c("loc", "cue", "reward_type", "exp", "hand")
  fact.names = c("cue_cond", "reward_type", "exp", "hand")
  # make the names vector
  conditions = unlist(sapply(fact.names, function(x) with(all.events, levels(eval(parse(text = x))))))
  # conditions = conditions[conditions != ".2"] # removing invalid trials
  # now make an onsets list, where each entry is the vector of onsets given that event
  # first defining vector that matches names in terms of the particular event that needs to be referenced to get onsets
  # factor.idx = c(rep("loc", times=2),
  #                rep("cue", times=2),
  #                rep("reward_type", times=4),
  #                rep("exp", times=4),
  #                rep("hand", times=2))
  
  factor.idx = c(rep("cue_cond", times=4),
                 rep("reward_type", times=4),
                 rep("exp", times=4),
                 rep("hand", times=2))
  
  # event_idx =  c( rep("target", times = 2 ), # for left and right tgts
  #                 rep("spatial cue", times = 2), # for the 3 probability conditions
  #                 rep("value cues", times=4), # for ll, lh, hh, hl
  #                 rep("feedback", times=4),
  #                 rep("target", times=2)) # for exp_hi, exp_lo, unexp_hi, unexp_lo
  event_idx =  c( rep("spatial cue", times = 4), # for the 3 probability conditions
                  rep("value cues", times=4), # for ll, lh, hh, hl
                  rep("feedback", times=4),
                  rep("target", times=2)) # for exp_hi, exp_lo, unexp_hi, unexp_lo
  
  correct = all.events$resp > 0
  tmp = all.events[correct, ]
  
  # idea is to combine mapply for the different vectors and apply a transmute/ddplyesque wrangle of the data
  # to get a list, for the onsets for each of the items in 'conditions'
 
  events_for_spm = mapply(get_event_info, cond=conditions, fact=factor.idx, ev=event_idx, MoreArgs=list(data=tmp), SIMPLIFY=FALSE)

  # modelling the onset of the target with a duration lasting the RT for that trial - given the information in this article comparing models
  # https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2654219/
  

  # add single regressor for invalid trials
  events_for_spm = c(events_for_spm, list(list(names="invalid", onsets=tmp[tmp$valid == "invalid" & tmp$event == "target",]$rel.onset, durations=tmp[tmp$valid == "invalid" & tmp$event == "target",]$duration)))
  # add single regressor for incorrect responses, following this advice from jiscmail: https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=spm;dc7d82cf.1103
  events_for_spm = c(events_for_spm, list(list(names="error", onsets=all.events[all.events$resp < 1 & all.events$event=="target", ]$rel.onset, durations=0)))
  
  ### now append the desired elements together
  idx = c(1:15) 
  all.names=c()
  all.onsets=c()
  all.durations=c()
  names = unlist( lapply(idx, function(x, lista, listb) append(lista, listb[[x]]$names), lista=all.names, listb=events_for_spm) )
  onsets =  sapply( idx, function(x, lista, listb) append( lista, list(listb[[x]]$onsets)), lista=all.onsets, listb=events_for_spm    )
  durations = sapply( idx, function(x, lista, listb) append( lista, list(listb[[x]]$durations)), lista=all.durations, listb=events_for_spm    )
  
  # now print the lists to text files
  stems = c('names', 'onsets', 'durations')
  print.data = list(names, onsets, durations)
 
  #mapply(do.print.of.events, stem=stems, data=print.data, MoreArgs=list(sub=sub, ses=ses, TR=TR, data_dir=data_dir))
  # write json file here
  jsondata = list(names=names,
                  onsets=onsets,
                  durations=durations)
  write_json(jsondata, sprintf(paste(data_dir, 'sub-0%d/', 'ses-0%d/', 'func/', 'sub-0%d_ses-0%d_task-learnAtt_acq-TR%d_glm_onsets.json', sep=''), sub, ses, sub, ses, TR))
}


  



