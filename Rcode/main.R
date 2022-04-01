# library(tcltk)
library(dplyr)
library(stringr)
library(tools)
library(collections) #, warn.conflicts = FALSE)
library(tidyr)
library(xlsx)
library(config)

source("Rcode/proccessing.R")
source("Rcode/file_processing.R")
source("Rcode/calculations.R")

# V11 - V42 == channels

################################################################
#                                                              #
# To change the input files, change the file paths on line 82. #
#                                                              #
################################################################

# Main function that calls all other functions.
SRT_main = function(file_list){
  config = config::get(file = "Configs/config.yml")
  
  # Assign config settings
  options(OutDec = config$dec_sep)
  out_loc = config$out_loc
  monitor_dict = FP_load_genotypes(config$genotype_monitor)
  day3_dict = FP_load_day3_dates(config$day3_dates)
  data_entries = dict()
  status_list = c()

  for(file_entry in file_list){
    success = tryCatch(
      {
        file_name = file_path_sans_ext(basename(file_entry))
        current_monitor = str_extract(file_name, "[:digit:]+")
        s_string = strsplit(monitor_dict$get(current_monitor)$get("1"), split=" +")[[1]]
        file_type = last_index(s_string)
        if(file_type == "14:10"){
          waso_time = config$WASO$SRT
          dead_threshold = config$dead_threshold$SRT
        }else{
          waso_time = config$WASO$normal
          dead_threshold = config$dead_threshold$normal
        }
        
        file_contents = FP_get_data(file_entry, "\t")
        filtered_data = P_filter_data(file_contents)
        
        # day_3_date = as.Date("29 Nov 20", "%d %b %y") # test.csv
        day_3_date = as.Date(day3_dict$get(current_monitor), "%d %b %y") # monitor13/14.txt
        night_periods = P_extract_day3_4(filtered_data, day_3_date)
        # print(monitor_dict$get(13)$get("1"))
        
        data_entry = C_get_data_per_file(waso_time, night_periods)
        # print(data_entry)
        
        averaged_plus_dead = P_average_days(data_entry, dead_threshold)
        # print(averaged_plus_dead)
        geno_matched = P_match_genotype(as.data.frame(averaged_plus_dead[[1]]), monitor_dict$get(current_monitor))
        # print(geno_matched)
        
        data_entries$set(file_name, geno_matched)
        returnVal = "success"
      },
      error=function(cond){
        print(cond)
        return(toString(cond))
      }
    )
    status_list = append(status_list, success)
    
  }
  # print(status_list)
  # print(file_list)

  if(!dir.exists(out_loc)){
    dir.create(out_loc)
  }
  for(filename in data_entries$keys()){
    FP_separate_data(out_loc, filename, data_entries$get(filename), FALSE)
  }
  
  return(status_list)

}

last_index = function(x){
  return(x[length(x)])
}


# # Best equivalent to 'if __name__ == "__main__":' in Python I could find.
# if (getOption('run.main', default=TRUE)) {
#   # Change filepaths below to coorect input files.
#   file_list = list("C:/Users/User/Desktop/Stage/201127/rawdata1212/eror.txt", "C:/Users/User/Desktop/Stage/201127/rawdata1212/Monitor22.txt")
#   SRT_main(file_list)
# }