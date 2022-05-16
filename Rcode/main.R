library(dplyr)
library(stringr)
library(tools)
library(collections) #, warn.conflicts = FALSE)
library(tidyr)
library(xlsx)
library(config)
library(tidyverse)

source("Rcode/proccessing.R")
source("Rcode/file_processing.R")
source("Rcode/calculations.R")

# V11 - V42 == channels

# Main function that calls all other functions.
SRT_main = function(file_list){
  config = config::get(file = "Configs/config.yml")

  # Assign config settings and "global" (out of for-loop) variables
  options(OutDec = config$dec_sep)
  out_loc = config$out_loc
  monitor_dict = FP_load_genotypes(config$genotype_monitor)
  day3_dict = FP_load_day3_dates(config$day3_dates)
  data_entries = dict()
  status_list = c()

  for(file_entry in file_list){
    success = tryCatch(
      {
        ### File related logic ###
        file_name = file_path_sans_ext(basename(file_entry))
        current_monitor = str_extract(file_name, "[:digit:]+")
        s_string = strsplit(monitor_dict$get(current_monitor)$get("1"), split=" +")[[1]]
        file_type = last_index(s_string)

        # Load file type specific configs
        if(file_type == "14:10"){
          waso_time = config$WASO$SRT
          dead_threshold = config$dead_threshold$SRT
        }else{
          waso_time = config$WASO$normal
          dead_threshold = config$dead_threshold$normal
        }


        ### Processing file data ###
        # Load file contents and filter
        file_contents = FP_get_data(file_entry, "\t")
        filtered_data = P_filter_data(file_contents)

        # Get date of day 3 for current monitor and extract the night periods for that monitor
        day_3_date = as.Date(day3_dict$get(current_monitor), "%d %b %y")
        night_periods = P_extract_days(filtered_data, day_3_date)

        ### Calculations ###
        # Pwake + Pdoze calcs
        min_activity_data = lapply(night_periods, P_transform_data)
        Pday1 = C_get_sleep_prob(min_activity_data[1], monitor_dict$get(current_monitor))
        Pday2 = C_get_sleep_prob(min_activity_data[2], monitor_dict$get(current_monitor))
        Pday3 = C_get_sleep_prob(min_activity_data[3], monitor_dict$get(current_monitor))
        Pday4 = C_get_sleep_prob(min_activity_data[4], monitor_dict$get(current_monitor))

        Pavg12 = P_combine_data(Pday1, Pday2)
        Pavg34 = P_combine_data(Pday3, Pday4)
        PavgAll = P_combine_data(Pday1, Pday2, Pday3, Pday4)

        # TST, SOL, NoSB, SED and WASO calcs
        data_entry = C_get_data_per_file(waso_time, night_periods[3:4])
        averaged_plus_dead = P_average_days(data_entry, dead_threshold)
        geno_matched = P_match_genotype(as.data.frame(averaged_plus_dead[[1]]), monitor_dict$get(current_monitor))


        ### Set data entries ###
        data_entries$set(file_name, list(FALSE, geno_matched))

        data_entries$set(sprintf("%s_Pday1", file_name), list(TRUE, Pday1))
        data_entries$set(sprintf("%s_Pday2", file_name), list(TRUE, Pday2))
        data_entries$set(sprintf("%s_Pday3", file_name), list(TRUE, Pday3))
        data_entries$set(sprintf("%s_Pday4", file_name), list(TRUE, Pday4))
        data_entries$set(sprintf("%s_Pavg12", file_name), list(TRUE, Pavg12))
        data_entries$set(sprintf("%s_Pavg34", file_name), list(TRUE, Pavg34))
        data_entries$set(sprintf("%s_PavgAll", file_name), list(TRUE, PavgAll))


        returnVal = "success"
      },
      error=function(cond){
        print(cond)
        return(toString(cond))
      }
    )
    # Used for displaying errors in Java GUI
    status_list = append(status_list, success)

  }
  ### Output code ###
  # Check if output folder exists, if not, create it
  if(!dir.exists(out_loc)){
    dir.create(out_loc)
  }
  # Loop over the data entries and write then away as output
  for(filename in data_entries$keys()){
    genomatched = data_entries$get(filename)
    if(genomatched[[1]]){
      FP_separate_data(out_loc, filename, genomatched[[2]], TRUE, current_monitor)
    }else{
      FP_separate_data(out_loc, filename, genomatched[[2]])
    }

  }

  return(status_list)

}

# Returns last index
last_index = function(x){
  return(x[length(x)])
}
