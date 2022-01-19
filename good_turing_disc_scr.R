# run after make_ngrams_scr.R 

# apply Good-Turning discounting to counts
# tested out in test_good_turing_scr.R

# specify and set working directory
dir_wd <- "C:\\Users\\josep\\data_science\\Data_Science_Capstone"
setwd(dir_wd)

# source functions called
source("simple_good_turing.R")

# load libraries
library(tibble)
library(stringr)
library(dplyr)

# load output from make_ngrams_scr.R
# only need to load one with highest n (n = 5), because it has all lower level n-grams
load(file = "ns_ngrams_counts_for_model_5.RData")

# determine counts after application of Good-Turing discounting
ns_ngrams_counts_1_tr$ngram_count_gtd <- simple_good_turing(ns_ngrams_counts_1_tr$ngram_count) *
                                         sum(ns_ngrams_counts_1_tr$ngram_count)
ns_ngrams_counts_2_tr$ngram_count_gtd <- simple_good_turing(ns_ngrams_counts_2_tr$ngram_count) *
                                         sum(ns_ngrams_counts_2_tr$ngram_count)
ns_ngrams_counts_3_tr$ngram_count_gtd <- simple_good_turing(ns_ngrams_counts_3_tr$ngram_count) *
                                         sum(ns_ngrams_counts_3_tr$ngram_count)
ns_ngrams_counts_4_tr$ngram_count_gtd <- simple_good_turing(ns_ngrams_counts_4_tr$ngram_count) *
                                         sum(ns_ngrams_counts_4_tr$ngram_count)
ns_ngrams_counts_5_tr$ngram_count_gtd <- simple_good_turing(ns_ngrams_counts_5_tr$ngram_count) *
                                         sum(ns_ngrams_counts_5_tr$ngram_count)

# save n-grams and discounted counts for use in model
# (For each level of back-off model, we need that level's n-grams and lower level n-grams.)
# unigram:
save(num_seed, num_samp, num_tot,
     frac_training, frac_testing, frac_validation,
     ns_ngrams_counts_1_tr,
     file = "ns_ngrams_counts_for_model_gtd_1.RData")
# bigram:
save(num_seed, num_samp, num_tot,
     frac_training, frac_testing, frac_validation,
     ns_ngrams_counts_1_tr, ns_ngrams_counts_2_tr,
     file = "ns_ngrams_counts_for_model_gtd_2.RData")
# trigram:
save(num_seed, num_samp, num_tot,
     frac_training, frac_testing, frac_validation,
     ns_ngrams_counts_1_tr, ns_ngrams_counts_2_tr, ns_ngrams_counts_3_tr,
     file = "ns_ngrams_counts_for_model_gtd_3.RData")
# 4-gram:
save(num_seed, num_samp, num_tot,
     frac_training, frac_testing, frac_validation,
     ns_ngrams_counts_1_tr, ns_ngrams_counts_2_tr, ns_ngrams_counts_3_tr, ns_ngrams_counts_4_tr,
     file = "ns_ngrams_counts_for_model_gtd_4.RData")
# 5-gram:
save(num_seed, num_samp, num_tot,
     frac_training, frac_testing, frac_validation,
     ns_ngrams_counts_1_tr, ns_ngrams_counts_2_tr, ns_ngrams_counts_3_tr, ns_ngrams_counts_4_tr, ns_ngrams_counts_5_tr,
     file = "ns_ngrams_counts_for_model_gtd_5.RData")