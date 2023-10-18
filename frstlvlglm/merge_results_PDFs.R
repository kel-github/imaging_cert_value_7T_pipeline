#install.packages("qpdf")
library("qpdf")
#install.packages("gtools")
library(gtools)

# this script takes all results PDFs for each participant and merges them
# into a single PDF in participant numerical order

#########################################################################
#
#
#                           MOTOR
#
#
#########################################################################

# assign which hand: assumption being the folder name pattern is the same as the
# string used in file location

#hand = "left"
hand = "right"

file_location_motor = paste0("/data/VALCERT/derivatives/fl_glm/hand/all_", hand, "_hand")

PDFs_path_motor <- list.files(path=file_location_motor, pattern=NULL, all.files=FALSE, 
                        full.names=FALSE)

# sort into alphabetical/numerical order
sorted_file_names_motor = paste0(file_location_motor, '/' ,mixedsort(PDFs_path_motor))

# eyeball for accuracy
sorted_file_names_motor

# build merged PDF in this order
qpdf::pdf_combine(input = sorted_file_names_motor,
                  output = paste0(hand,"_hand_results.pdf"))


#########################################################################
#
#
#                           TASK
#
#
#########################################################################

# assign which contrast

#task = "one"
task = "three"

file_location_task = paste0("/data/VALCERT/derivatives/fl_glm/task/all_", task, "_contrast")

PDFs_path_task <- list.files(path=file_location_task, pattern=NULL, all.files=FALSE, 
                        full.names=FALSE)

# sort into alphabetical/numerical order
sorted_file_names_task = paste0(file_location_task, '/' ,mixedsort(PDFs_path_task))

# eyeball for accuracy
sorted_file_names_task

# build merged PDF in this order
qpdf::pdf_combine(input = sorted_file_names_task,
                  output = paste0(task,"_task_results.pdf"))