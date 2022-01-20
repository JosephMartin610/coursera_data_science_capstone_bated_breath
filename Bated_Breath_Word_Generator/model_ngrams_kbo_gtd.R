model_ngrams_kbo_gtd <- function(text_str, model_ngram_size, ns_ngrams_counts) {
  
  # text_str: text string
  # model_ngram_size: specify n-gram size to use in model (>= 2)
  #                   2 =  bigram (predicts using previous 1 word)
  #                   3 = trigram (predicts using previous 2 words)
  #                   4 =  4-gram (predicts using previous 3 words)
  #                   5 =  5-gram (predicts using previous 4 words)
  #                   and so forth
  # ns_ngrams_counts: tibbles containing corpora n-grams used to build model probabilities 
  #                   with columns:
  #                                  n: n-gram level and equal to number of words in ngram column
  #                              ngram: corpora n-gram
  #                        ngram_count: corpora n-gram count
  #                   ngram_count_disc: corpora n-gram count with Good-Turing discounting applied
  #
  # For the string in text_str, this function uses an n-gram model with Katz back-off
  # to determine probabilities for what the next word beyond the end of the string would be.
  # The n-grams and their probabilities are returned by this function (in a tibble).
  # The prediction is the row with maximum probability.
  # The n-grams and their counts (with a set discounted by Good-Turing) used to make the prediction model
  # (ns_ngrams_counts) were obtained with make_ngrams_scr.R and and good_turing_disc_scr.R.
  #
  # The string text_str should contain only fully lowercase words and single interior spaces.
  # There should be no leading or trailing spaces, no punctuation 
  # (except apostrophe for possessives and contractions), and no numbers.
   
  # packages
  require(tibble)
  require(stringr)
  require(dplyr)
  
  # confirm text_str has at least the right number of words 
  # to run model at this model_ngram_size
  # if not, decrease model_ngram_size accordingly
  # determine number of words
  num_words <- dim(str_locate_all(text_str,"[[A-Za-z']]+\\s")[[1]])[1] + 1
  # correct for case of empty string
  if (nchar(text_str) == 0){
    num_words <- 0
  }
  # if not enough words for model_ngram_size
  # change model_ngram_size to 1 more than number of words
  if (num_words < (model_ngram_size - 1) ){
    model_ngram_size <- num_words + 1
  }
  
  # extract variables for this model_ngram_size level and that 
  # simplify expressions below and improve recursive use
  # n-grams and counts at the main (mn) n-gram level
  eval(parse(text = paste0("ns_ngrams_counts_mn <- filter(ns_ngrams_counts, n == ", as.character(model_ngram_size)  , ")")))
  ngrams_counts_mn <- select(ns_ngrams_counts_mn, ngram, ngram_count, ngram_count_gtd)
  rm(ns_ngrams_counts_mn)
  # n-grams and counts at the back-off level
  eval(parse(text = paste0("ns_ngrams_counts_bo <- filter(ns_ngrams_counts, n == ", as.character(model_ngram_size-1), ")")))
  ngrams_counts_bo <- select(ns_ngrams_counts_bo, ngram, ngram_count, ngram_count_gtd)
  rm(ns_ngrams_counts_bo)
  # unigrams and counts
  ns_ngrams_counts_1 <- filter(ns_ngrams_counts, n == 1)
  ngrams_counts_1 <- select(ns_ngrams_counts_1, ngram, ngram_count, ngram_count_gtd)
  rm(ns_ngrams_counts_1)
  # retain ns_ngrams_counts that will be used in recursive function call
  eval(parse(text = paste0("ns_ngrams_counts <- filter(ns_ngrams_counts, n != ", as.character(model_ngram_size)  , ")")))

  # determine regular expressions used to extract words
  # in text_str that will be used to determine prediction at this n-gram level
  # for the  bigram model we use:
  # - the last one   word  (also known as the unigram prefix)
  # for the trigram model we use:
  # - the last two   words (also known as the  bigram prefix), but back off to
  # - the last one   word  (also known as the unigram prefix)
  # for the  4-gram model we use:
  # - the last three words (also known as the trigram prefix), but back off to
  # - the last two   words (also known as the  bigram prefix)
  # and so forth
  for (q in 1:(model_ngram_size-1)) {
    if (q == 1) {
      # each "[[A-Za-z']]+" matches at least one letter or apostrophe, that is, a word
      re_pf_mn <- "[[A-Za-z']]+" # main     prefix
      re_pf_bo <- ""             # back-off prefix has one fewer leading words
    } else {
      # "\\s" for space and then another word
      re_pf_mn <- paste0(re_pf_mn, "\\s[[A-Za-z']]+") # main     prefix
      re_pf_bo <- paste0(re_pf_bo, "\\s[[A-Za-z']]+") # back-off prefix
    }
  }
  # "$" to anchor to end of string
  re_pf_mn <- paste0(re_pf_mn, "$") # main     prefix
  re_pf_bo <- paste0(re_pf_bo, "$") # back-off prefix
  rm(q)

  # extract words in text_str
  # that will be used to determine prediction
  pf_mn <- str_extract(text_str,re_pf_mn)
  pf_bo <- str_extract(text_str,re_pf_bo)
  
  # determine which rows in ngrams_counts_mn$ngram start with pf_mn, if any
  # for the given prefix, these are the observed n-grams
  # ngrams_counts_mn$ngram will always have one more word than pf_mn
  # "^" to anchor to start of string
  # "\\s" to find space (The way the n-grams have been constructed, there will always be a space there.)
  # using "\\s" prevents detecting last word at the start of a different longer word
  inds_pf_mn_o <- which(str_detect(ngrams_counts_mn$ngram, paste0("^", pf_mn, "\\s")))
  ngrams_counts_mn_pf_mn_o <- ngrams_counts_mn[inds_pf_mn_o,]
  
  # determine which row in ngrams_counts_bo$ngram matches pf_mn, if any
  # for the given prefix, this is the occurence of the prefix and its count in the list of back-off (n-1)-grams
  # ngrams_counts_bo$ngram and pf_mn both have n words separated by a space,
  # or are both single words (unigrams)
  ngrams_counts_bo_pf_mn_o <- filter(ngrams_counts_bo, ngram == pf_mn)
  # obtain the count in this row
  count_bo_pf_mn_o <- ngrams_counts_bo_pf_mn_o$ngram_count
  
  # calculate probabilities of observed n-grams, if any
  # discounted counts
  counts_mn_pf_mn_o_star <- ngrams_counts_mn_pf_mn_o$ngram_count_gtd
  # probabilities
  probs_mn_pf_mn_o <- counts_mn_pf_mn_o_star / count_bo_pf_mn_o
     
  # form tibble with observed n-grams and probabilities
  ngrams_probs_mn_pf_mn_o <- tibble(ngram = ngrams_counts_mn_pf_mn_o$ngram, prob = probs_mn_pf_mn_o)
  
  # for observed n-grams, determine alpha, the discounted probability mass taken from observed n-grams
  # if there are no observed n-grams, there is no set to sum over, and the maximum (1) is taken
  if (length(counts_mn_pf_mn_o_star) > 0) { # only check length of numerator because if > 0, then length of denominator is too
    alpha_pf_mn <- 1 - sum(counts_mn_pf_mn_o_star) / count_bo_pf_mn_o
  } else {
    alpha_pf_mn <- 1
  }
     
  # find set of words that complete unobserved n-grams
  # extract last word in each observed n-gram (unigram suffix)
  ngrams_mn_ug_sf_pf_mn_o <- str_extract(ngrams_counts_mn_pf_mn_o$ngram, "[[A-Za-z']]+$")
  # find all unigrams that do not end any observed n-gram and their counts
  ngrams_1_ug_sf_pf_mn_uo <- setdiff(ngrams_counts_1$ngram, ngrams_mn_ug_sf_pf_mn_o)
  ngrams_counts_1_ug_sf_pf_mn_uo <- filter(ngrams_counts_1, ngram %in% ngrams_1_ug_sf_pf_mn_uo)
    
  # determine all unobserved n-grams
  ngrams_mn_pf_mn_uo <- paste(rep(pf_mn,dim(ngrams_counts_1_ug_sf_pf_mn_uo)[1]), ngrams_counts_1_ug_sf_pf_mn_uo$ngram)    
  
  # calculate probabilities of unobserved n-grams
  if (model_ngram_size == 2) {

    # the n-gram level of bigrams is a special case that ends the recursion

    # counts
    counts_1_ug_sf_pf_mn_uo <- ngrams_counts_1_ug_sf_pf_mn_uo$ngram_count

    # probabilities of unobserved n-grams (bigrams)
    if (length(counts_1_ug_sf_pf_mn_uo) > 0) { # only check length of numerator because if > 0, then length of denominator is too
      probs_mn_pf_mn_uo <- alpha_pf_mn * counts_1_ug_sf_pf_mn_uo / sum(counts_1_ug_sf_pf_mn_uo)
    } else {
      probs_mn_pf_mn_uo <- vector(mode = "double", length = 0)
    }

  } else {
    
    # calculate probability of backoff (n-1)-grams by using this function recursively
    ngrams_probs_bo <- model_ngrams_kbo_gtd(pf_bo, model_ngram_size-1, ns_ngrams_counts)

    # limit (n-1)-grams to those whose last word is in the set of unigrams ending the unobserved n-grams
    ngrams_probs_bo_pf_mn_uo <- filter(ngrams_probs_bo, 
                                       str_extract(ngram, "[[A-Za-z']]+$") %in% ngrams_1_ug_sf_pf_mn_uo)
    
    # probabilities of unobserved n-grams
    # by doing the limit (filter) just above, the probabilities are normalized correctly
    if (length(ngrams_probs_bo_pf_mn_uo$prob) > 0) {
      probs_mn_pf_mn_uo <- alpha_pf_mn * ngrams_probs_bo_pf_mn_uo$prob / sum(ngrams_probs_bo_pf_mn_uo$prob)
    } else {
      probs_mn_pf_mn_uo <- vector(mode = "double", length = 0)
    }
    
  }

  # form tibble with unobserved n-grams and their probabilities
  ngrams_probs_mn_pf_mn_uo <- tibble(ngram = ngrams_mn_pf_mn_uo, prob = probs_mn_pf_mn_uo)

  # probabilities of all n-grams
  ngrams_probs_mn <- rbind(ngrams_probs_mn_pf_mn_o, ngrams_probs_mn_pf_mn_uo)
  ngrams_probs_mn <- ngrams_probs_mn[order(ngrams_probs_mn$ngram),]

  return(ngrams_probs_mn)

}