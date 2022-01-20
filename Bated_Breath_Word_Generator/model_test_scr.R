# run after make_ngrams_scr.R,
# good_turing_disc_scr.R, 
# and merge_ns_ngrams_counts_for_model_gtd.R

# specify and set working directory
dir_wd <- "C:\\Users\\josep\\data_science\\Data_Science_Capstone\\Bated_Breath_Word_Generator"
setwd(dir_wd)

# source functions called
source("pred_text_ngrams_kbo_gtd.R")

# load libraries
library(tibble)
library(stringr)
library(dplyr)

# load output from make_ngrams_scr.R
# num_seed, num_samp, num_tot
# frac_training, frac_testing, frac_validation
# ngrams_1_tr, ngrams_2_tr, ngrams_3_tr, ngrams_4_tr, ngrams_5_tr
# ngrams_1_ts, ngrams_2_ts, ngrams_3_ts, ngrams_4_ts, ngrams_5_ts
# ngrams_1_vl, ngrams_2_vl, ngrams_3_vl, ngrams_4_vl, ngrams_5_vl
# ngrams_counts_1_tr, ngrams_counts_2_tr, ngrams_counts_3_tr, ngrams_counts_4_tr, ngrams_counts_5_tr
# all that is used from this is ngrams_5_ts
load(file = "C:\\Users\\josep\\data_science\\Data_Science_Capstone\\ngrams_counts.RData")
num_seed_all <- num_seed
num_samp_all <- num_samp
num_tot_all <- num_tot
frac_training_all <- frac_training
frac_testing_all <- frac_testing
frac_validation_all <- frac_validation
rm(num_seed, num_samp, num_tot,
   frac_training, frac_testing, frac_validation,
   ngrams_1_tr, ngrams_2_tr, ngrams_3_tr, ngrams_4_tr, ngrams_5_tr,
   ngrams_1_ts, ngrams_2_ts, ngrams_3_ts, ngrams_4_ts,
   ngrams_1_vl, ngrams_2_vl, ngrams_3_vl, ngrams_4_vl, ngrams_5_vl,
   ngrams_counts_1_tr, ngrams_counts_2_tr, ngrams_counts_3_tr, ngrams_counts_4_tr, ngrams_counts_5_tr)

# set model_ngram_size
model_ngram_size <- 2

fn_ngrams_counts <- paste0(dir_wd, "\\", "ns_ngrams_counts_for_model_gtd_merge_", as.character(model_ngram_size), ".RData")
load(file = fn_ngrams_counts)

# test model on sample of test ngrams
num_seed <- 0
set.seed(num_seed)
num_samp <- 100
# just use 5-gram test set, as that is the largest we will go, 
# and will allow use to use the same test set for all n-gram levels
text_full_vec <- sample(ngrams_5_ts$ngram, size = num_samp)
# remove actual last word, so it can be compared with the predicted word
word_actual_vec <- str_extract(text_full_vec, "[[A-Za-z']]+$")
text_pref_vec <- str_remove(text_full_vec, " [[A-Za-z']]+$")

# initialize output tibble for predicted words and probabilities
words_probs_pred <- tibble(word = vector(mode = "character", length = num_samp), 
                           prob = vector(mode = "double"   , length = num_samp))

# use model to obtain most probable predicted next words and their probabilities 
num_preds <- 1
start_time_model_test <- Sys.time()
for (q in 1:num_samp) {
  words_probs_pred_q <- pred_text_ngrams_kbo_gtd(text_pref_vec[q], model_ngram_size, ns_ngrams_counts, num_preds)
  words_probs_pred$word[q] <- words_probs_pred_q$word
  words_probs_pred$prob[q] <- words_probs_pred_q$prob
}
end_time_model_test <- Sys.time()
end_time_model_test - start_time_model_test 
word_pred_vec <- words_probs_pred$word
text_pred_full_vec <- paste(text_pref_vec, word_pred_vec)

# determine perplexity
pp_vec <- (1/words_probs_pred$prob)^(1/model_ngram_size)

# form tibble to use in comparing actual and predicted words
df_comp_words <- tibble(actual = word_actual_vec, pred = word_pred_vec,
                        prob = words_probs_pred$prob, pp = pp_vec)
# determine percentage where prediction was correct
nrow(filter(df_comp_words, actual == pred)) / nrow(df_comp_words) * 100

# determine mean perplexity
mean(pp_vec)

# ** lesson from quizzes is have to look at selection of most probable words, as on phone 
# ** or could say lesson from testing is that you will probably only ever reach certain prediction level 
# ** so need to show user options
# ** conclusion might be that you need a very large corpora to improve results **

# Results:
# num_seed_all = 0
# num_samp_all = 525,000
# num_tot_all = 500,000
# frac_training_all = 0.7
# frac_testing_all = 0.2
# frac_validation_all = 0.1
# num_seed = 0
# model_ngram_size = 2 
#   num_samp =  10 ->  14.7 secs ( 1.47 secs each)
#   num_samp = 100 ->  2.42 mins
#     percentage of words predicted successfully: 9.000%
#     mean perplexity: 3.634
# model_ngram_size = 3
#   num_samp = 10 ->  38.8 secs ( 3.88 secs each)
#   num_samp = 100 -> 6.72 mins
#     percentage of words predicted successfully: 20.000%
#     mean perplexity: 2.098
# model_ngram_size = 4
#   num_samp = 10 ->  85.8 secs ( 8.58 secs each)
#   num_samp = 100 -> 14.10 mins
#     percentage of words predicted successfully: 18.000%
#     mean perplexity: 1.724
# model_ngram_size = 5
#   num_samp = 10 -> 147.5 secs (14.75 secs each)
#   num_samp = 100 -> 20.89 mins
#     percentage of words predicted successfully: 15.000%
#     mean perplexity: 1.550