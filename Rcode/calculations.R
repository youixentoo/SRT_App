library(dplyr)
library(stringr)
library(collections, warn.conflicts = FALSE)


# Main function for TST, SOL, NoSB, SED and WASO calculations
C_get_data_per_file = function(waso_time, night_periods){
  day3 = as.data.frame(night_periods[1])
  day4 = as.data.frame(night_periods[2])

  dataframe_day3 = do_calculations(day3, waso_time)
  dataframe_day4 = do_calculations(day4, waso_time)

  data_entry = list(dataframe_day3, dataframe_day4)
  return(data_entry)
}

# Column wise calculations of a single day
do_calculations = function(day_data, waso_time){
  calc_data = as.data.frame(sapply(day_data, col_calcs, waso_time=waso_time))
  rownames(calc_data) = c("TST", "SOL", "NoSB", "SED", "WASO", "S_Eff")
  return(calc_data)
}

# Function that does the calculations
col_calcs = function(data, waso_time){
  data_string = paste(data, sep="", collapse="")
  indexed_extract_all_SB = as.data.frame(str_locate_all(data_string, "0{10,}"))
  TST_total_lengths = apply(indexed_extract_all_SB, 1, TST_row_length) # Row wise

  # TST - min
  TST = sum(TST_total_lengths)/2
  
  # Sleep efficiency
  # TSt / rows * 100
  Sleep_eff = (TST / (nchar(data_string)/2)) * 100

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

  return(list(TST, SOL, NoSB, SED, WASO, Sleep_eff))
}

# Returns the row length from the regex, used to calculate TST
TST_row_length = function(TST_row){
  return((TST_row[2] - TST_row[1])+1)
}

TST_lengths = function(items){
  return(nchar(items))
}

# Calculate sleep probabilities, also converts column names to genotypes
# Removes columns where NA is present
C_get_sleep_prob = function(data, channel_dict){
  Pdata = as.data.frame(sapply(as.data.frame(data), calc_pwake_doze))
  rownames(Pdata) = c("Pwake", "Pdoze")
  omit_na = Pdata[, colSums(is.na(Pdata)) == 0]
  P_match_genotype(omit_na, channel_dict) %>% return()
}

# Calculates Pwake and Pdoze for a single column
# If the denominator for Pwake or Pdoze is 0, the value gets sets to -1 (undefined)
calc_pwake_doze = function(bins){
  wake = 0
  doze = 0

  last_bin = -1; # Can really be any number, gets replaced by/at first index of for-loop
  for(i in seq_along(bins)){
    current_bin = bins[[i]]
    if(i > 1){
      bin_diff = current_bin - last_bin
      if(bin_diff == -1){
        doze = doze + 1
      }else if(bin_diff == 1){
        wake = wake + 1
      }
      last_bin = current_bin
    }else{
      last_bin = current_bin
    }
  }

  # If last bin is active
  if(last_bin == 1){
    denom_wake = length(which(bins == 0))
    denom_doze = length(which(bins[1:length(bins)-1] == 1))
  }else{
    denom_wake = length(which(bins[1:length(bins)-1] == 0))
    denom_doze = length(which(bins == 1))
  }

  # Calculates the value for Pwake and Pdoze
  # If the denominator is 0, the value gets set to NA (undefined)
  if(denom_wake == 0){
    Pwake = NA
  }else{
    Pwake = wake / denom_wake
  }

  if(denom_doze == 0){
    Pdoze = NA
  }else{
    Pdoze = doze / denom_doze
  }

  return(list(Pwake, Pdoze))
}

