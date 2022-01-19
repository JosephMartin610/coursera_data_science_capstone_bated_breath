tokenize <- function(text_vec) {
  
  # This function reads in a vector of text strings of varying length,
  # and separates (tokenizes) each string into individual tokens: words, numbers, and punctuation.
  # The output is a data frame with columns containing individual tokens 
  # and the type: "word", "numb", or "punc"
   
  # packages
  require(tibble)
  require(stringr)
  
  # initialize data frame
  tknzd <- tibble(token = character(length = 0), type = factor(character(length = 0), levels = c("word", "numb", "punc")))
  
  # loop over all strings
  for(i in 1:length(text_vec)) {
    
    # break up characters in string separated by any length whitespace
    text_vec_no_ws_i <- unlist(str_split(text_vec[i],"\\s+"))
    
    # separate strings into alphabetical and everything else
    # see https://www.r-bloggers.com/strsplit-but-keeping-the-delimiter/ for the logic here
    # do not separate strings at apostrophes so that contractions stay together
    # note this separates all numbers into individual characters but we will not use them anyway
    text_vec_no_ws_sep_i <- unlist(str_split(text_vec_no_ws_i, "(?<=.)(?=[^[A-Za-z']])"))
 
    # for some reason the above does not split off a subsequent non letter
    # so handle it as a special case here
    for (j in 1:length(text_vec_no_ws_sep_i)) {
      if (nchar(text_vec_no_ws_sep_i[j]) != 1) {
        sub_str_i_j_1    <- str_sub(text_vec_no_ws_sep_i[j], start = 1, end = 1)
        sub_str_i_j_rest <- str_sub(text_vec_no_ws_sep_i[j], start = 2, end = -1)
        if (length(str_extract_all(sub_str_i_j_1,"[A-Za-z]")[[1]]) == 0) {
          if (j == 1) {
            text_vec_no_ws_sep_i <-
            c(sub_str_i_j_1, sub_str_i_j_rest,
              text_vec_no_ws_sep_i[(j+1):length(text_vec_no_ws_sep_i)])
          } else if (j == length(text_vec_no_ws_sep_i)) {
            text_vec_no_ws_sep_i <-
            c(text_vec_no_ws_sep_i[1:(j-1)],
              sub_str_i_j_1, sub_str_i_j_rest)
          } else {
            text_vec_no_ws_sep_i <-
            c(text_vec_no_ws_sep_i[1:j-1],
              sub_str_i_j_1, sub_str_i_j_rest,
              text_vec_no_ws_sep_i[(j+1):length(text_vec_no_ws_sep_i)])
          }
        }
      }
    }
    
    # label type as word, number, or punctuation
    types_i <- text_vec_no_ws_sep_i
    types_i[str_starts(types_i,"[A-Za-z]")]   <- "word"
    types_i[str_starts(types_i,"[[:digit:]]")] <- "numb"
    types_i[!str_starts(types_i,"word|numb")]  <- "punc"
    
    # add in current tokenized strings
    # if last string is not punctuation, add in period to avoid pairing words
    # across individual entries (rows)
    if (types_i[length(types_i)] == "punc"){
      tknzd_i <- tibble(token = as.character(text_vec_no_ws_sep_i), type = as.factor(types_i))
    } else {
      tknzd_i <- tibble(token = as.character(c(text_vec_no_ws_sep_i, ".")), type = as.factor(c(types_i, "punc")))
    }

    # join to existing data frame
    tknzd <- add_row(tknzd, token = tknzd_i$token, type = tknzd_i$type)
     
  }
  
  # return the data frame
  return(tknzd)
    
}