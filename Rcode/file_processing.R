library(xlsx)
library(collections)

# Gets the  data from the monitor files
FP_get_data = function(filename, file_sep){
  file_contents = read.csv(filename, sep=file_sep, header= FALSE)
  return(file_contents)
}

# Loads the genotypes for each column for each monitor into a dict()
FP_load_genotypes = function(filename){
  file_contents = read.xlsx(filename, 1)
  monitor_dict = dict()
  monitor_data = split(file_contents, f=file_contents$Monitor)
  for(monitor in monitor_data){
    cha_gen_tmp = monitor$Genotype
    names(cha_gen_tmp) = monitor$Channel
    channel_dict = dict(cha_gen_tmp)
    monitor_dict$set(as.character(monitor$Monitor[1]), channel_dict)
  }
  return(monitor_dict)
}

# Loads the day 3 dates for each monitor into a dict()
FP_load_day3_dates = function(day3_dates){
  file_contents = read.xlsx(day3_dates, 1)
  day3_dict = dict()
  day3_data = split(file_contents, f=file_contents$Monitor)
  for(entry in day3_data){
    day3_dict$set(as.character(entry$Monitor), entry$Date)
  }
  return(day3_dict)
}

# Separates the data in the df to be saved in separate folders in the output dir.
# Every row gets saved separately, identical column names get combined into a single column.
FP_separate_data = function(out_loc, filename, geno_matched, bool_nested_folder=FALSE, name_of_said_folder=""){
  # Loop over rows
  for(row_index in seq_len(nrow(geno_matched))){
    int_out_folder = paste(out_loc, row.names(geno_matched)[[row_index]],sep="/")
    if(!dir.exists(int_out_folder)){
      dir.create(int_out_folder)
    }
    
    # Extra folder for sleep probabilities
    if(bool_nested_folder){
      nested_loc = sprintf("%s/Monitor_%s", int_out_folder, name_of_said_folder)
      int_out_folder = nested_loc
      if(!dir.exists(nested_loc)){
        dir.create(nested_loc)
      }
    }
    
    # Transforming data
    data = geno_matched[row_index,]
    inter1 = lapply(split(lapply(data, as.character), names(data)), unlist)
    inter2 = sapply(inter1, "length<-", max(lengths(inter1)))
    cols_combined = as.data.frame(inter2)
    cols_combined[is.na(cols_combined)] = ""

    # File writing
    file_out = paste(int_out_folder, "/", filename, ".tsv", sep="")
    write.table(cols_combined, file_out, row.names = FALSE, sep="\t")
  }
}

from_list_to_double = function(value) {
  return(value[[1]])
}