rmv_pf <- function(text_vec) {
  
  # This function reads in a vector of text strings of varying length,
  # and returns it with any strings containing profanity or racial or sexist slurs removed.
  # If the string has profanity or racial or sexists slurs the whole string is removed, 
  # as the meaning will be lost if we try to exclude a single word,
  # and we do not have a way to replace that word.
  
  # packages
  require(stringr)
  
  # read in list of words considered profanity
  dir_pf <- "C:\\Users\\josep\\data_science\\Data_Science_Capstone"
  dir_fn_comp_pf <- paste(dir_pf, "list_profanity_words.txt", sep="\\")
  dir_fn_comp_pf_con <- file(dir_fn_comp_pf, "r")
  lines_pf <- readLines(dir_fn_comp_pf_con, warn = FALSE)
  close(dir_fn_comp_pf_con)
  df_pf <- as.data.frame(lines_pf, stringsAsFactors=FALSE)
  colnames(df_pf)[colnames(df_pf)=="lines_pf"] <- "text"
  rm(dir_fn_comp_pf_con, lines_pf)
   
  # the corpora text is checked against a list of words in a file from Gooogle profanity words
  # some entries that did not seem like signifiant profanity or that have a typically non profane meaning,
  # were removed from the list of words
  text_vec_no_pf <- character(length = 0)
  inds_no_pf <- integer(length = 0)
  count_no_pf = 0
  for(i in 1:length(text_vec)) {
    # make vector for occurences of profanity in ith string 
    occ_pf_i <- vector(mode = "integer", length = length(text_vec))
    for (j in 1:dim(df_pf)[1]) {
      # \b matches word boundaries, the transition between word and non-word characters
      # otherwise it will find profanity word pattern inside another word
      out_loc_i_j <- str_locate_all(text_vec[i], paste0("\\b", df_pf$text[j], "\\b"))
      if(dim(out_loc_i_j[[1]])[1] >= 1) {
        #df_pf$text[j]
        occ_pf_i[j] <- 1 
      } else {
        occ_pf_i[j] <- 0
      }
    }  
  
    if(all(occ_pf_i == 0)){
      count_no_pf <- count_no_pf + 1
      text_vec_no_pf[count_no_pf] <- text_vec[i]
      inds_no_pf[count_no_pf] <- i
    }
  }
  rm(count_no_pf, i, occ_pf_i, j, out_loc_i_j)
  # to check, can find indices of strings in text_vec with profanity by using
  #text_vec[setdiff(1:length(text_vec)),inds_no_pf)]
  
  # return vector of text strings with profanity removed
  # and indices of strings in original vector that were retained
  list_return <- list("text_vec_no_pf" = text_vec_no_pf, "inds_no_pf" = inds_no_pf)
  return(list_return)
    
}