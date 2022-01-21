# run after tnkz_scr.R

# specify and set working directory
dir_wd <- "C:\\Users\\josep\\data_science\\Data_Science_Capstone"
setwd(dir_wd)

# source functions called
source("make_ngrams_from_tokens.R")

# load libraries
library(tibble)
library(stringr)
library(dplyr)

# load output from tknz_scr.R
# frac_training, frac_testing, frac_validation,
# num_tot, num_seed, num_samp,
# text_tr, text_ts, text_vl,
# tknzd_tr, tknzd_ts, tknzd_vl
load(file = "tknzd.RData")

# I wanted to use the function unnest_ngrams.R in package tidytext to determine the n-grams,
# but it would not work given the way I had already tokenized the corpora text.
# If I was starting over from scratch, I would try to use tidytext from the start on the corpora files.
# Instead, I will use my own function called make_ngrams_from_tokens.R.

# Use examples to check how well make_ngrams_from_tokens function works.
#inds_chk <- 1:110 # tokens for the complete first entry in text_tr
#inds_chk <- 325:400 # this example has numbers
#tknzd_tr_chk <- tknzd_tr[inds_chk,] 
#tknzd_tr$token[inds_chk]
# unigram (this just returns tokens with number and punctuation removed)
#ngram_chk_1 <- make_ngrams_from_tokens(tknzd_tr_chk,1)
#ngram_chk_1
# bigram
#ngram_chk_2 <- make_ngrams_from_tokens(tknzd_tr_chk,2)
#ngram_chk_2
# trigram
#ngram_chk_3 <- make_ngrams_from_tokens(tknzd_tr_chk,3)
#ngram_chk_3
# four-gram
#ngram_chk_4 <- make_ngrams_from_tokens(tknzd_tr_chk,4)
#ngram_chk_4
# five-gram
#ngram_chk_5 <- make_ngrams_from_tokens(tknzd_tr_chk,5)
#ngram_chk_5

# determine n-grams

# training
start_time_ngrams_tr <- Sys.time()
ngrams_1_tr <- tibble(ngram = make_ngrams_from_tokens(tknzd_tr,1))
ngrams_2_tr <- tibble(ngram = make_ngrams_from_tokens(tknzd_tr,2))
ngrams_3_tr <- tibble(ngram = make_ngrams_from_tokens(tknzd_tr,3))
ngrams_4_tr <- tibble(ngram = make_ngrams_from_tokens(tknzd_tr,4))
ngrams_5_tr <- tibble(ngram = make_ngrams_from_tokens(tknzd_tr,5))
end_time_ngrams_tr <- Sys.time()
end_time_ngrams_tr - start_time_ngrams_tr
# time difference of  3.686774 secs for  14,000 strings on 2021/03/05 at 21:56
# time difference of 19.53488  secs for  70,000 strings on 2021/03/21 at 12:18
# time difference of  2.221787 mins for 350,000 strings on 2021/03/22 at 17:12

# testing
start_time_ngrams_ts <- Sys.time()
ngrams_1_ts <- tibble(ngram = make_ngrams_from_tokens(tknzd_ts,1))
ngrams_2_ts <- tibble(ngram = make_ngrams_from_tokens(tknzd_ts,2))
ngrams_3_ts <- tibble(ngram = make_ngrams_from_tokens(tknzd_ts,3))
ngrams_4_ts <- tibble(ngram = make_ngrams_from_tokens(tknzd_ts,4))
ngrams_5_ts <- tibble(ngram = make_ngrams_from_tokens(tknzd_ts,5))
end_time_ngrams_ts <- Sys.time()
end_time_ngrams_ts - start_time_ngrams_ts
# time difference of  1.297995 secs for   4,000 strings on 2021/03/05 at 21:56
# time difference of  5.567172 secs for  20,000 strings on 2021/03/21 at 12:18
# time difference of 53.7912   secs for 100,000 strings on 2021/03/22 at 17:13

# validation
start_time_ngrams_vl <- Sys.time()
ngrams_1_vl <- tibble(ngram = make_ngrams_from_tokens(tknzd_vl,1))
ngrams_2_vl <- tibble(ngram = make_ngrams_from_tokens(tknzd_vl,2))
ngrams_3_vl <- tibble(ngram = make_ngrams_from_tokens(tknzd_vl,3))
ngrams_4_vl <- tibble(ngram = make_ngrams_from_tokens(tknzd_vl,4))
ngrams_5_vl <- tibble(ngram = make_ngrams_from_tokens(tknzd_vl,5))
end_time_ngrams_vl <- Sys.time()
end_time_ngrams_vl - start_time_ngrams_vl
# time difference of  1.104387 secs for  2,000 strings on 2021/03/05 at 21:56
# time difference of  3.080702 secs for 10,000 strings on 2021/03/21 at 12:18
# time difference of 13.71333  secs for 50,000 strings on 2021/03/22 at 17:13

# obtain counts of training n-grams
# see test_group_by_n_summarize_scr.R in week 2 for an example showing why group_by(), n(), and summarize() works
# group by n-grams
ngrams_grp_1_tr <- group_by(ngrams_1_tr, ngram)
ngrams_grp_2_tr <- group_by(ngrams_2_tr, ngram)
ngrams_grp_3_tr <- group_by(ngrams_3_tr, ngram)
ngrams_grp_4_tr <- group_by(ngrams_4_tr, ngram)
ngrams_grp_5_tr <- group_by(ngrams_5_tr, ngram)
# count occurences of each individual n-gram
# note: the n-grams are in alphabetical order (with lowercase preceding uppercase of same letter)
ngrams_counts_1_tr <- summarize(ngrams_grp_1_tr, n())
ngrams_counts_2_tr <- summarize(ngrams_grp_2_tr, n())
ngrams_counts_3_tr <- summarize(ngrams_grp_3_tr, n())
ngrams_counts_4_tr <- summarize(ngrams_grp_4_tr, n())
ngrams_counts_5_tr <- summarize(ngrams_grp_5_tr, n())
# default name for the counts is just n(), so improve this name.
ngrams_counts_1_tr <- rename(ngrams_counts_1_tr, ngram_count = `n()`)
ngrams_counts_2_tr <- rename(ngrams_counts_2_tr, ngram_count = `n()`)
ngrams_counts_3_tr <- rename(ngrams_counts_3_tr, ngram_count = `n()`)
ngrams_counts_4_tr <- rename(ngrams_counts_4_tr, ngram_count = `n()`)
ngrams_counts_5_tr <- rename(ngrams_counts_5_tr, ngram_count = `n()`)

# do a cross check using filter to check several examples
# unigram
#test_str <- "elephant"
#test_str <- "house"
#test_str <- "obama"
#test_str <- "piano"
#test_str <- "the"
#dim(filter(ngrams_1_tr, ngram == test_str))
#filter(ngrams_counts_1_tr, ngram == test_str)
# bigram
#test_str <- "the dog"
#test_str <- "at work"
#test_str <- "barack obama"
#test_str <- "of the"
#test_str <- "around the"
#dim(filter(ngrams_2_tr, ngram == test_str))
#filter(ngrams_counts_2_tr, ngram == test_str)
# trigram
#test_str <- "on the road"
#test_str <- "in the house"
#test_str <- "from the start"
#test_str <- "behind the wheel"
#test_str <- "i said to"
#dim(filter(ngrams_3_tr, ngram == test_str))
#filter(ngrams_counts_3_tr, ngram == test_str)
# No test was done for four-grams and five-grams, 
# because it would be more difficult to predict common ones

# order by pair count (not used for model, but of interest)
#ngrams_counts_desc_1_tr <- arrange(ngrams_counts_1_tr, desc(ngram_count))
#ngrams_counts_desc_2_tr <- arrange(ngrams_counts_2_tr, desc(ngram_count))
#ngrams_counts_desc_3_tr <- arrange(ngrams_counts_3_tr, desc(ngram_count))
#ngrams_counts_desc_4_tr <- arrange(ngrams_counts_4_tr, desc(ngram_count))
#ngrams_counts_desc_5_tr <- arrange(ngrams_counts_5_tr, desc(ngram_count))
# With the higher n-grams we start to get frequently occuring ones 
# that we know are not actually that common in all text:
# 4-gram: 
#   "thanks for the follow", 94, (coming in from Twitter)
#   "thanks for the rt"    , 59, (coming in from Twitter)
# 5-gram:
#   "the north dakota township map", 23, (all from one string: text_tr[str_detect(text_tr,"the north dakota township map")])
#   "thank you for the follow"     , 16, (coming in from Twitter)

# determine number of unique ngrams
# For 14,000 strings used for training set (capital letters allowed):
#dim(ngrams_counts_1_tr)[1] # unigram  :  34,969
#dim(ngrams_counts_2_tr)[1] # bigram   : 155,350
#dim(ngrams_counts_3_tr)[1] # trigram  : 206,055
#dim(ngrams_counts_4_tr)[1] # four-gram: 188,470
#dim(ngrams_counts_5_tr)[1] # five-gram: 158,085
# For 70,000 strings used for training set (no capital letters allowed):
#dim(ngrams_counts_1_tr)[1] # unigram  :   67,426
#dim(ngrams_counts_2_tr)[1] # bigram   :  526,352
#dim(ngrams_counts_3_tr)[1] # trigram  :  890,299
#dim(ngrams_counts_4_tr)[1] # four-gram:  905,551
#dim(ngrams_counts_5_tr)[1] # five-gram:  782,509
# Interestingly, the number of unique ngrams peaks 
# at the trigrams for 14,000 strings and four-grams for 70,000 strings,
# but in both cases the difference between the two numbers is relatively small.
# Ratios of increase:
#    strings:  70000/ 14000 = 5
#   unigrams:  67426/ 34969 = 1.93
#    bigrams: 526352/155350 = 3.39
#   trigrams: 890299/206055 = 4.32
# four-grams: 905551/188470 = 4.80
# five-grams: 782509/158085 = 4.95
# The ratio increases with n-gram and gets close to 5 for the five-grams.
# These numbers are actually depressed somewhat because not allowing
# capital letters in the 70,000 strings case would itself decrease 
# the number of unique n-grams.

# determine total n-gram counts (total number of occurrences)
#ngrams_counts_tot_1_tr <- sum(ngrams_counts_1_tr$ngram_count)
#ngrams_counts_tot_2_tr <- sum(ngrams_counts_2_tr$ngram_count)
#ngrams_counts_tot_3_tr <- sum(ngrams_counts_3_tr$ngram_count)
#ngrams_counts_tot_4_tr <- sum(ngrams_counts_4_tr$ngram_count)
#ngrams_counts_tot_5_tr <- sum(ngrams_counts_5_tr$ngram_count)

# determine probability of each n-gram
# put these in their own data frame
#ngrams_probs_1_tr <- tibble(ngram = ngrams_counts_1_tr$ngram, prob = ngrams_counts_1_tr$ngram_count/ngrams_counts_tot_1_tr)
#ngrams_probs_2_tr <- tibble(ngram = ngrams_counts_2_tr$ngram, prob = ngrams_counts_2_tr$ngram_count/ngrams_counts_tot_2_tr)
#ngrams_probs_3_tr <- tibble(ngram = ngrams_counts_3_tr$ngram, prob = ngrams_counts_3_tr$ngram_count/ngrams_counts_tot_3_tr)
#ngrams_probs_4_tr <- tibble(ngram = ngrams_counts_4_tr$ngram, prob = ngrams_counts_4_tr$ngram_count/ngrams_counts_tot_4_tr)
#ngrams_probs_5_tr <- tibble(ngram = ngrams_counts_5_tr$ngram, prob = ngrams_counts_5_tr$ngram_count/ngrams_counts_tot_5_tr)

# confirm probabilities sum to 1
#sum(ngrams_probs_1_tr$prob) # 1
#sum(ngrams_probs_2_tr$prob) # 1
#sum(ngrams_probs_3_tr$prob) # 1
#sum(ngrams_probs_4_tr$prob) # 1
#sum(ngrams_probs_5_tr$prob) # 1

# save information about corpora sampling and training/testing/validation distribution,
# ngrams, and counts of ngrams
save(num_seed, num_samp, num_tot,
     frac_training, frac_testing, frac_validation,
     ngrams_1_tr, ngrams_2_tr, ngrams_3_tr, ngrams_4_tr, ngrams_5_tr,
     ngrams_1_ts, ngrams_2_ts, ngrams_3_ts, ngrams_4_ts, ngrams_5_ts,
     ngrams_1_vl, ngrams_2_vl, ngrams_3_vl, ngrams_4_vl, ngrams_5_vl,
     ngrams_counts_1_tr, ngrams_counts_2_tr, ngrams_counts_3_tr, ngrams_counts_4_tr, ngrams_counts_5_tr,
     file = "ngrams_counts.RData")

# For each n-gram model level, save:
# - information about corpora sampling and training/testing/validation distribution
# - n, n-grams, and their counts for use in model
# first, add n column to each tibble as this will facilitate modeling later
ns_ngrams_counts_1_tr <- mutate(ngrams_counts_1_tr, n = rep(as.integer(1),length(ngram)))
ns_ngrams_counts_1_tr <- relocate(ns_ngrams_counts_1_tr, n)
ns_ngrams_counts_2_tr <- mutate(ngrams_counts_2_tr, n = rep(as.integer(2),length(ngram)))
ns_ngrams_counts_2_tr <- relocate(ns_ngrams_counts_2_tr, n)
ns_ngrams_counts_3_tr <- mutate(ngrams_counts_3_tr, n = rep(as.integer(3),length(ngram)))
ns_ngrams_counts_3_tr <- relocate(ns_ngrams_counts_3_tr, n)
ns_ngrams_counts_4_tr <- mutate(ngrams_counts_4_tr, n = rep(as.integer(4),length(ngram)))
ns_ngrams_counts_4_tr <- relocate(ns_ngrams_counts_4_tr, n)
ns_ngrams_counts_5_tr <- mutate(ngrams_counts_5_tr, n = rep(as.integer(5),length(ngram)))
ns_ngrams_counts_5_tr <- relocate(ns_ngrams_counts_5_tr, n)

# (For each level of back-off model, we need that level's n-grams and lower level n-grams.)
# unigram:
save(num_seed, num_samp, num_tot,
     frac_training, frac_testing, frac_validation,
     ns_ngrams_counts_1_tr,
     file = "ns_ngrams_counts_for_model_1.RData")
# bigram:
save(num_seed, num_samp, num_tot,
     frac_training, frac_testing, frac_validation,
     ns_ngrams_counts_1_tr, ns_ngrams_counts_2_tr,
     file = "ns_ngrams_counts_for_model_2.RData")
# trigram:
save(num_seed, num_samp, num_tot,
     frac_training, frac_testing, frac_validation,
     ns_ngrams_counts_1_tr, ns_ngrams_counts_2_tr, ns_ngrams_counts_3_tr,
     file = "ns_ngrams_counts_for_model_3.RData")
# 4-gram:
save(num_seed, num_samp, num_tot,
     frac_training, frac_testing, frac_validation,
     ns_ngrams_counts_1_tr, ns_ngrams_counts_2_tr, ns_ngrams_counts_3_tr, ns_ngrams_counts_4_tr,
     file = "ns_ngrams_counts_for_model_4.RData")
# 5-gram:
save(num_seed, num_samp, num_tot,
     frac_training, frac_testing, frac_validation,
     ns_ngrams_counts_1_tr, ns_ngrams_counts_2_tr, ns_ngrams_counts_3_tr, ns_ngrams_counts_4_tr, ns_ngrams_counts_5_tr,
     file = "ns_ngrams_counts_for_model_5.RData")