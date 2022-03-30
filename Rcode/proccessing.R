library(dplyr)

# Filters out the errors and not needed data from the input file
P_filter_data = function(file_contents){
  error_less = filter(file_contents, V4 == 1)
  file_data = subset(error_less, select = -c(V1,V3,V4,V5,V6,V7,V8,V9))
  return(file_data)
}

# Extracts the day3 and day4 data from the input file
P_extract_day3_4 = function(filtered_data, day_3_date){
  date_filtered = filter(filtered_data, as.Date(V2, "%d %b %y") >= day_3_date)
  day_3_4_start = date_filtered %>% slice(match(1, V10):n()) %>% slice(match(0, V10):n())
  day_3 = slice(day_3_4_start, 0:(match(1, V10)-1)) %>%
          subset(select= -c(V2, V10)) %>%
          rename_with(change_to_index)
  
  day_4 = day_3_4_start %>% 
          slice(match(1, V10):n()) %>% 
          slice(match(0, V10):n()) %>% 
          slice(0:(match(1, V10)-1)) %>%
          subset(select= -c(V2, V10)) %>%
          rename_with(change_to_index)
  
  # write.csv(day_3,"day3_test.csv")
  # write.csv(day_4,"day4_test.csv")
  
  return(list(day_3, day_4))
}

# Changes the "V_" column names to the corresponding channel
change_to_index = function(col_name){
  number = as.numeric(gsub("V", "", col_name))
  index = number - 10
  return(index)
}

# Combines the day3 and day4 dataframes into a single averaged one
P_average_days = function(data_entry, dead_threshold){
  filtered_entry = filter_dead(data_entry, dead_threshold)
  day3 = filtered_entry[[1]]
  day4 = filtered_entry[[2]]
  
  # https://stackoverflow.com/a/41653222
  averaged = apply(abind::abind(day3, day4, along = 3), 1:2, mean)
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
  # print(day3_dead)
  
  day4_temp = data_entry[[2]]
  day4 = day4_temp[ , ! names(day4_temp) %in% day3_dead]
  day4_columns = colnames(day3)
  day4_dead = c()
  for(i in 1:ncol(day4)) {
    if(day4["TST",i] >= dead_threshold){
      day4_dead = append(day4_dead, day4_columns[i])
    }
  }
  # print(day4_dead)
  
  dead_cols = c(day3_dead, day4_dead)
  # Removes dead fly columns from data
  day3_filtered = day3[ , ! names(day3) %in% dead_cols]
  day4_filtered = day4[ , ! names(day4) %in% dead_cols]
  
  return(list(day3_filtered, day4_filtered, dead_cols))
}

# Matches channel number with genotype
P_match_genotype = function(averaged_data, channel_dict){
  for(i in colnames(averaged_data)) {
    genotype = channel_dict$get(gsub("X","",i))
    colnames(averaged_data)[which(names(averaged_data) == i)] = genotype
  }
  return(averaged_data)
}

