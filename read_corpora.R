read_corpora <- function(fn,enc) {
  
  ## This function reads in the corpora data from a specified file,
  ## and outputs its contents as a data frame with column
  ## 'text', which is a character vector.
  
  ## 'fn' is the file path and name of the corpora file.
  ## 'enc' is the known encoding: "latin1" or "UTF-8" 
  
  ## read in the corpora data
  con_fn <- file(fn, "r")
  lines_fn <- readLines(fn, encoding = enc, skipNul=TRUE)
  close(con_fn)
  ## Return a data frame with column 'text', 
  ## which is a character vector with the file contents.
  df_fn <- as.data.frame(lines_fn, stringsAsFactors=FALSE)
  colnames(df_fn)[colnames(df_fn)=="lines_fn"] <- "text"
  return(df_fn)
    
}