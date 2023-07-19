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
    fol_str = "sub-0%d" # because the data from CAI didn't have the extra zero preprended
  } else if (i > 9 & i < 100) {
    sub_str = "sub-0%d"
    fol_str = "sub-%d"
  } else {
    sub_str = "sub-%d"
    fol_str = sub_str
  }
  fn <- paste(sub_str, fn, sep="")
  get_session_strings <- function(x) dir(sprintf(paste(data_path, fol_str, "ses-02", ses_type, sep = "/"), i), pattern=sprintf(fn, i, TR, x), full.names = TRUE)
  do.call(cbind, lapply(1:nruns, get_session_strings))
}

get_event_times_data <- function(fn){
   # use this function to load the behavioural log file, remove extraneous events, and code the events 
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
  
  d <- lapply(1:runs, function (j) resplog(subject, j))
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

#sub_track_list = list()

# not lopping -> just running from scratch each time
# adapt json code to just capture one file...

match_behaviour_to_event_timings <- function(dat, evs, motor_sanity = FALSE, sub=NA, sess=NA, run=NA, sub_folders=NA, namePatt=NA){
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
  
  #print(paste0("CONTENTS run: ", run))
  
  # remove error trials
  #sess_data <- sess_data %>% filter(resp == 1)
  
  tgt_locs <- c("left", "right")
  spatial_cue_types <- levels(sess_data$cert)
  value_cue_types <- unique(sess_data$reward_type)
  correct <- unique(sess_data$resp)
  
  # need to add a column here if motor argument == TRUE
  # thing is, names would be just replaced with the response hand

  #if (motor_sanity == FALSE){
  
  if (motor_sanity == FALSE){
  
    names = sort(as.vector(outer(tgt_locs, spatial_cue_types, paste, sep="_")))
    names = sort(as.vector(outer(names, value_cue_types, paste, sep = "_")))
    names = sort(as.vector(outer(names, correct, paste, sep =  "_")))
  
  }
  
  if (motor_sanity == TRUE){

    # call resp_map_counter to capture resp mapping
    # call function to return hand response information
    output_resp_map<-resp_map_LvsR(sub, sess, run, sub_folders, namePatt)
      
   
    ccw <- unique(sess_data$ccw)
    acc <- unique(sess_data$resp)
    
    names = sort(as.vector(outer(ccw, acc, paste, sep="_")))
    
    ###########################################################################
    # NOTE: 
    # output_resp_map[1] == clockwise response (returns hand used)
    # output_resp_map[2] == counter clockwise response (returns hand used)
    # output_resp_map[3] == json_files$resp_order (response_order key number)
    ###########################################################################
    
    # if ccw_acc pattern x is in names then take that pattern and paste hand used and resp_order into its position in names
    # format: ccw, accuracy, response hand, resp_order code
      names[names == '0_0'] <- paste0('0_0_', output_resp_map[2] , "_", output_resp_map[3])
      names[names == '0_1'] <- paste0('0_1_', output_resp_map[1] , "_", output_resp_map[3])
      names[names == '1_0'] <- paste0('1_0_', output_resp_map[1] , "_", output_resp_map[3])
      names[names == '1_1'] <- paste0('1_1_', output_resp_map[2] , "_", output_resp_map[3])
    # format: ccw, accuracy, response hand, resp_order code

    
  } # end of motor_sanity == TRUE if statement
  
  #print(paste0("THIS IS WHAT names length LOOKS LIKE: ", length(names)))
  
  sess_data$loc <- as.factor(sess_data$loc)
  levels(sess_data$loc) <- c("left", "right")

  
  # values assigned to SPM json files if extracting motor response info
  if (motor_sanity == TRUE){
    
    #print(paste0("CONTENTS NAMES: ", names, "LENGTH NAMES: ", length(names)))
    
    # format: ccw condition, accuracy, hand used, response_order number e.g. -> 1_0_rightH_1
    onsets <- mapply(function(x, i) sess_data$rel.onset[sess_data$ccw == x & sess_data$resp == i],
                     x = sapply(1:length(names), function(x) str_split(names[[x]], "_")[[1]])[1,],
                     i = as.numeric(sapply(1:length(names), function(x) str_split(names[[x]], "_")[[1]])[2,]),
                     SIMPLIFY = FALSE)
    durations <- lapply(onsets, function(x) rep(0, length(x)))
    
  } # end of if statement
  
  # values assigned to SPM json files if extracting experimental data
  if (motor_sanity == FALSE){
    
    onsets <- mapply(function(x, y, z, i) sess_data$rel.onset[sess_data$loc == x & sess_data$cert == y & sess_data$reward_type == z & sess_data$resp == i],
                                        x = sapply(1:length(names), function(x) str_split(names[[x]], "_")[[1]])[1,],
                                        y = sapply(1:length(names), function(x) str_split(names[[x]], "_")[[1]])[2,],
                                        z = sapply(1:length(names), function(x) str_split(names[[x]], "_")[[1]])[3,],
                                        i = as.numeric(sapply(1:length(names), function(x) str_split(names[[x]], "_")[[1]])[4,]),
                     SIMPLIFY = FALSE)
    durations <- lapply(onsets, function(x) rep(0, length(x)))
  
  } # end of if statement
  
    out <- list(names, onsets, durations)
    names(out) <- c("names", "onsets", "durations")
    out
  
}

# the function below pulls ONE json file that matches
# arguments and the defined pattern
json_file_list <- function(sub, sess, run, subs_data_path, namePatt){ 
  
  # This function reads the bold run file specifically specified
  # and returns the data - we can do this because the response mapping
  # didn't change once assigned to a given participant
  
  # subs_data_path now only have the path to where the sub folder are
  # search folders for subject match; return path up to subject number
  
  # Regular expression pattern for sub/sess/run -> accounts for possible leading zeros
  sub_pattern <- sprintf("sub-0*%d", sub)
  #print(paste0("sub_pattern = ", sub_pattern))
  
  sess_pattern <- sprintf("ses-0*%d", sess)
  #print(paste0("sess_pattern = ", sess_pattern))
  
  run_pattern <- sprintf("run-0*%d", run)
  #print(paste0("run_pattern = ", run_pattern))
  
  beh_pattern <- "/ses-02/beh"
  
  # return all folders based on general pattern
  filtered_subs_data_path <- beh_data_path_patt(data_dir, sub_pattern)
  
  # add the beh folder level to general pattern for each entry
  filtered_subs_data_path <- paste0(filtered_subs_data_path, beh_pattern)
  
  # print(paste0("Contents filtered_subs_data_path second: ", filtered_subs_data_path))
  
  # define the file name based on current subject number, session number, and run number namePatt
  file_name_pattern <- paste0(sub_pattern, "_", sess_pattern, namePatt, run_pattern, ".json")
  
  # grab file matching path and file name defined above
  json_files <- list.files(filtered_subs_data_path, pattern = file_name_pattern, full.names = TRUE)

  json_data <- map2(
    json_files,
    map(json_files, read_json),
    # modifyList takes current file name x and merges with relevant json data
    ~ modifyList(.y, list(filenamepath = .x))
  ) %>% unlist(recursive = FALSE) # unlists the list of lists into a one-dimensional list of dataframes
    
  # print(paste0("json_data$sub = ", json_data$sub))
  # print(paste0("json_data = ", json_data))
  json_data
  
}

# This function calls in the file (BOLD) that contains the counter-balanced
# response mapping and extracts response keys mapped to cw and ccw.
# pass sub, session, run (manual), data_dir, namePatt that are all defined in
# prnt_json_nd_perform_behav_analysis.
resp_map_LvsR <- function(sub, sess, run, data_dir, namePatt){
  
  # call the function json_file_list which finds the file matching
  # sub, sess, run and data_dir via the file name pattern defined inside
  # json_file_list - it reads and returns the json contents
  json_files<-json_file_list(sub, sess, run, data_dir, namePatt)
  
   
  # following code checks the resp_order key and assigns the key mapping accordingly to descriptive variables
  if (json_files$resp_order == 1) {
    clockwise = "f"
    anticlockwise =  "j"
  }
  
  if (json_files$resp_order == 2){
    clockwise = "j"
    anticlockwise = "f"
  }
  
  # crate string with format that will match json_files$resp_key[1]
  compare_strings=paste0("clockwise: ", clockwise, ", anticlockwise: ", anticlockwise)
  
  # Check that assigned keys match intended mapping with resp_order code (1 vs 2)
  # if they do not match return report
  if (compare_strings != json_files$resp_key[1]){
    cat(" ")
    print(paste0("Checked assigned keys and code are consistent: result = ", (print(compare_strings != json_files[[iter]]$resp_key[1])) ))
    print(paste0("Subject number: ", json_files$sub[1], " ",
                 " Session Number: ", json_files$session[1], " ",
                 "File path: ", json_files$filenamepath[1]))
    cat(" ")
  }
    
    
  # the following code assigns descriptive labels to identify which hand was used
  # to make a given response
  if (clockwise == "f"){
    
    clockwise_SPM = "leftH"
    anticlockwise_SPM = "rightH"
    
    # print(paste0("GETS INSIDE cw == f ASSIGNMENT, clockwise= :, ", clockwise))
    
  }
  
  if (clockwise == "j"){
    
    clockwise_SPM = "rightH"
    anticlockwise_SPM = "leftH"
    
    # print(paste0("GETS INSIDE cw == j ASSIGNMENT, clockwise= :, ", clockwise))
    
  }

  # add the response map code 1 vs 2 to the list so we can check in real time  
      
  #given the resp code should be the same across all runs only need to return one
  resp_list = list(clockwise_SPM, anticlockwise_SPM, json_files$resp_order)

  # return list of response mapping: [1]=clockwise, [2]=anticlockwise
  resp_list
  
  #print(paste0("HERE IS CONTENTS OF resp_list: ", resp_list))
  
}


















































write_json_4_spm <- function(events_4_spm, fpath, sub_num, run_num, motor_sanity = FALSE){
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
    sub_str = "sub-0%d"
  } else {
    sub_str = "sub-%d"
  } 
  
  if (motor_sanity==FALSE){
  
    filenameMain <- '_ses-02_task-attlearn_run-%d_desc-glm-onsets.json'
  
  }
  
  if (motor_sanity==TRUE){
    
    filenameMain <- '_ses-02_MOTOR_run-%d_desc-SPM-onsets.json'
    
  }
  
  write_json(jsondata, sprintf(paste(fpath, "/",
                                     sub_str, 
                                     "/",  
                                     'ses-02/', 
                                     'beh/', 
                                     sub_str,
                                     filenameMain, sep=''), 
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



# Define function that uses list.files() to get a list of all subfolders matching the pattern
beh_data_path_patt<-function(folder_path,beh_patt){
  
  list_of_dir <- list.dirs(folder_path, full.names = TRUE, recursive = FALSE)
  
  grep(beh_patt,list_of_dir, value=TRUE)
 
}

# pattern = beh_patt




