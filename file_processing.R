library(xlsx)
library(collections)


FP_get_data = function(filename, file_sep){
  file_contents = read.csv(filename, sep=file_sep, header= FALSE)
  return(file_contents)
  
  # For fileopening gui
  #test = tk_choose.files()
}


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

FP_load_day3_dates = function(day3_dates){
  file_contents = read.xlsx(day3_dates, 1)
  day3_dict = dict()
  day3_data = split(file_contents, f=file_contents$Monitor)
  for(entry in day3_data){
    day3_dict$set(as.character(entry$Monitor), entry$Date)
  }
  return(day3_dict)
}


FP_separate_data = function(out_loc, filename, geno_matched, with_rownames){
  for(row_index in seq_len(nrow(geno_matched))){
    calc_cat_folder = paste(out_loc, row.names(geno_matched)[[row_index]],sep="/")
    if(!dir.exists(calc_cat_folder)){
      dir.create(calc_cat_folder)
    }
    data = geno_matched[row_index,]
    inter1 = lapply(split(lapply(data, as.character), names(data)), unlist)
    inter2 = sapply(inter1, "length<-", max(lengths(inter1)))
    cols_combined = as.data.frame(inter2)
    cols_combined[is.na(cols_combined)] = ""

    file_out = paste(calc_cat_folder, "/", filename, ".tsv", sep="")
    write.table(cols_combined, file_out, row.names = with_rownames, sep="\t")
  }
}


# Old monitor separated version
FP_sep_data = function(out_loc, filename, geno_matched, with_rownames){
  # filename == Monitor
  monitor_out = paste(out_loc,filename,sep="/")
  if(!dir.exists(monitor_out)){
    dir.create(monitor_out)
  }
  
  for(row_index in seq_len(nrow(geno_matched))){
    file_out = paste(monitor_out, "/", row.names(geno_matched)[[row_index]], ".csv", sep="")
    write.csv(geno_matched[row_index,], file_out, row.names = with_rownames, sep=",")
  }
}