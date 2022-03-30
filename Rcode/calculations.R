library(dplyr)
library(stringr)

library(collections, warn.conflicts = FALSE)

C_get_data_per_file = function(waso_time, night_periods){
  day3 = as.data.frame(night_periods[1])
  day4 = as.data.frame(night_periods[2])
  
  # print("day3")
  dataframe_day3 = do_calculations(day3, waso_time)
  # print("day4")
  dataframe_day4 = do_calculations(day4, waso_time)

  data_entry = list(dataframe_day3, dataframe_day4)
  return(data_entry)
}

do_calculations = function(day_data, waso_time){
  calc_data = as.data.frame(sapply(day_data, col_calcs, waso_time=waso_time))
  rownames(calc_data) = c("TST", "SOL", "NoSB", "SED", "WASO")
  return(calc_data)
}

col_calcs = function(data, waso_time){
  data_string = as_string(data)
  indexed_extract_all_SB = as.data.frame(str_locate_all(data_string, "0{10,}"))
  TST_total_lengths = apply(indexed_extract_all_SB, 1, TST_row_length) # Row wise
  # print(data)
  
  # TST - min
  TST = sum(TST_total_lengths)/2

  # SOL - min
  # Number of rows until first sleep
  SOL = (indexed_extract_all_SB[1,][[1]]-1)/2

  # Number of sleep bouts (NoSB)
  NoSB = length(TST_total_lengths)

  # Sleep episode duration (SED) - min
  SED = mean(TST_total_lengths)/2
  # SED = TST / NoSB

  # WASO - min
  WASO = waso_time - TST - SOL

  return(list(TST, SOL, NoSB, SED, WASO))
  # return(list(1, 1, 1, 1, 1))
}

as_string = function(data_col){ 
  output_string = ""
  for(x in data_col){
    if(x >= 10){
      x = "+" # Is the amount of activity really needed?
    }
    output_string = paste(output_string, as.character(x), sep="", collapse="") #conc. strings
  }
  # print(length(data_col) == nchar(output_string))
  
  return(output_string)
}


TST_row_length = function(TST_row){
  return((TST_row[2] - TST_row[1])+1)
}

TST_lengths = function(items){
  return(nchar(items))
}