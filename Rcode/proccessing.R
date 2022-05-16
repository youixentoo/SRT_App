library(dplyr)

# Filters out the errors and not needed data from the input file
P_filter_data = function(file_contents){
  error_less = filter(file_contents, V4 == 1)
  file_data = subset(error_less, select = -c(V1,V3,V4,V5,V6,V7,V8,V9))
  return(file_data)
}

# Extracts the day data from the input file
P_extract_days = function(filtered_data, day_3_date){
  date_filtered = filter(filtered_data, as.Date(V2, "%d %b %y") >= day_3_date-2)
  day_data = date_filtered %>% slice(match(1, V10):n()) %>% slice(match(0, V10):n())
  nights = list()

  nights[[1]] = extract_night(day_data) %>% sapply(to_binary)
  for(day_index in 2:4){
    day_data = day_data %>% slice(match(1, V10):n()) %>%
      slice(match(0, V10):n())

    night_period = extract_night(day_data) %>% sapply(to_binary)
    nights[[day_index]] = night_period
  }

  return(nights)
}

# Extracts the night period
extract_night = function(day_data){
  slice(day_data, 0:(match(1, V10)-1)) %>%
    subset(select= -c(V2, V10)) %>%
    rename_with(change_to_index) %>%
    as.data.frame() %>%
    return()
}

# Changes the "V_" column names to the corresponding channel
change_to_index = function(col_name){
  number = as.numeric(gsub("V", "", col_name))
  index = number - 10
  return(index)
}

to_binary = function(coldata){
  coldata[which(coldata > 0)] = 1
  return(coldata)
}

# Combines the day3 and day4 dataframes into a single averaged one
P_average_days = function(data_entry, dead_threshold){
  filtered_entry = filter_dead(data_entry, dead_threshold)
  averaged = P_combine_data(filtered_entry[[1]], filtered_entry[[2]])
  return(list(averaged, filtered_entry[[3]]))
}

# Filters dead flies out of the data
filter_dead = function(data_entry, dead_threshold){
  day3 = data_entry[[1]]
  day3_columns = colnames(day3)
  day3_dead = c()
  for(i in 1:ncol(day3)) {
    if(day3["TST",i] >= dead_threshold){
      day3_dead = append(day3_dead, day3_columns[i])
    }
  }

  day4_temp = data_entry[[2]]
  day4 = day4_temp[ , ! names(day4_temp) %in% day3_dead]
  day4_columns = colnames(day3)
  day4_dead = c()
  for(i in 1:ncol(day4)) {
    if(day4["TST",i] >= dead_threshold){
      day4_dead = append(day4_dead, day4_columns[i])
    }
  }

  dead_cols = c(day3_dead, day4_dead)
  # Removes dead fly columns from data
  day3_filtered = day3[ , ! names(day3) %in% dead_cols]
  day4_filtered = day4[ , ! names(day4) %in% dead_cols]

  return(list(day3_filtered, day4_filtered, dead_cols))
}

# Matches channel number with genotype
P_match_genotype = function(data, channel_dict){
  for(i in colnames(data)) {
    genotype = channel_dict$get(gsub("X","",i))
    colnames(data)[which(names(data) == i)] = genotype
  }
  return(data)
}

# Averages the values of any number of df, any number of arguments
P_combine_data = function(...){
  apply(abind::abind(..., along = 3), 1:2, mean) %>% return()
}

# Function for converting the night_periods data into 1 min data instead of 30 sec
P_transform_data = function(night_period){
  return(sapply(as.data.frame(night_period), col_trans))
}

# Converts the activity data into 1 or 0. 1 = active, 0 - inactive.
# If the data is of an odd length, the last row gets added as is
col_trans = function(col_data){
  results = list()
  for(i in seq_along(col_data)){
    if(i %% 2 == 1){
      if(is.na(col_data[i+1])){
        results = append(results, col_data[i])
      }else{
        sum_firstsecond = col_data[i] + col_data[i+1]
        if(sum_firstsecond > 0){
          results = append(results, 1)
        }else{
          results = append(results, 0)
        }
      }
    }
  }
  return(results)
}


# #TODO: Handle last row
# # Converts the activity data into 1 or 0. 1 = active, 0 - inactive.
# col_trans = function(col_data){
#   results = list()
#   for(i in seq_along(col_data)){
#     if(i %% 2 == 1 & is.na(col_data[i+1]) == FALSE){
#       sum_firstsecond = col_data[i] + col_data[i+1]
#       if(sum_firstsecond > 0){
#         results = append(results, 1)
#       }else{
#         results = append(results, 0)
#       }
#
#     }
#   }
#   return(results)
# }
