make_ngrams_from_tokens <- function(df_token_type,num_ngram) {
  
  # This function reads in a data frame (df_token_type) with the following columns:
  # - token (character): contains tokens, which are either individual words, numbers, or punctuation characters 
  # - type  (factor)   : contains types for tokens: "word", "numb", or "punc"
  # and returns a character vector ngram with n-grams of length num_ngram.
  # num_ngram should be >= 1.
  # In ngram, the words are separated by one space " ".
  # Note that the n-grams are only for consecutive sequences of words of length num_ngram.
  # That is, there are no n-grams across numbers or punctuation.

  # packages
  require(tibble)
  require(dplyr)
  require(stringr)
  
  num_tokens <- length(df_token_type$token)
  if (num_ngram == 1) {
    ngram       <- df_token_type$token
    ngram_types <- df_token_type$type
  }
  else {
    for(i in 1:(num_ngram-1)) {
      if (i == 1) {
        ngram       <- df_token_type$token[i:(num_tokens-(num_ngram-i))]
        ngram_types <- df_token_type$type[i:(num_tokens-(num_ngram-i))]
        
      }
      ngram       <- paste(ngram,       df_token_type$token[(i+1):(num_tokens-(num_ngram-(i+1)))], sep = " ")
      ngram_types <- paste(ngram_types, df_token_type$type[(i+1):(num_tokens-(num_ngram-(i+1)))] , sep = " ")
    }
  }
  
  df_ngram_type <- tibble(ngram = ngram, ngram_type = ngram_types)
  
  # filter out any rows containing punctuation or a number
  df_ngram_type <- filter(df_ngram_type, !str_detect(ngram_type,"numb|punc"))
  
  # return n-grams
  return(df_ngram_type$ngram)
    
}