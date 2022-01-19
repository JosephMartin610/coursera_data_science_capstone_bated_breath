pred_text_ngrams_kbo_gtd <- function(text_str, model_ngram_size, ns_ngrams_counts, num_preds) {
  
  # text_str: text string (a sequence of words)
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
  # num_preds: an integer that specifies the number of predictions to return (ordered by probability)
  #
  # For the string in text_str, this function uses an n-gram model 
  # with Katz back-off to predict what the next word beyond the end of the string would be.
  # The word predictions and their probabilities are returned by this function (in a tibble)
  # for the num_preds most probable predictions.
  # The n-grams and their counts (with a set discounted by Good-Turing) used to make the prediction model 
  # were obtained with make_ngrams_scr.R and good_turing_disc_scr.R.
  #
  # The string text_str should contain only fully lowercase words and single interior spaces.
  # There should be no leading or trailing spaces, no punctuation 
  # (except apostrophe for possessives and contractions), and no numbers.
   
  # packages
  require(tibble)
  require(stringr)
  require(dplyr)
  
  # source functions called
  source("model_ngrams_kbo_gtd.R")
  
  # determine n-gram probabilities for:
  # - n-grams starting with text_str
  # - n-grams with n = model_ngram_size
  # - and using probabilities discounted by Good-Turing
  ngrams_probs <- model_ngrams_kbo_gtd(text_str, model_ngram_size, ns_ngrams_counts)
  
  # order by probability (most to least)
  ngrams_probs <- ngrams_probs[order(ngrams_probs$prob, decreasing = TRUE),]
  
  # confirm that the probabilities add up to 1
  #sum_prob <- sum(ngrams_probs$prob)
  #print(sum_prob)
      
  # limit to num_preds most probable
  ngrams_probs_lim <- ngrams_probs[1:num_preds,]
  
  # output tibble for predicted words and probabilities
  pred_words_probs <- tibble( word = str_extract(ngrams_probs_lim$ngram, "[[A-Za-z']]+$"), 
                              prob = ngrams_probs_lim$prob)

  return(pred_words_probs)
  
}