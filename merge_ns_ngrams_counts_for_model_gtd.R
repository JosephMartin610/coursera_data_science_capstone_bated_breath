# model_ngram_size: specify n-gram size to use in model (>= 2)
#                   1 = unigram (predicts using previous 0 words)
#                   2 =  bigram (predicts using previous 1 word)
#                   3 = trigram (predicts using previous 2 words)
#                   4 =  4-gram (predicts using previous 3 words)
#                   5 =  5-gram (predicts using previous 4 words)
#                   and so forth
model_ngram_size <- 5

# packages
require(tibble)
require(stringr)
require(dplyr)

# load corpora ns, n-grams, and counts used for model training
# specify directory containing results of make_ngrams_scr.R and good_turing_disc_scr.R
dir_wd <- "C:\\Users\\josep\\data_science\\Data_Science_Capstone"
# load output from make_ngrams_scr.R and good_turing_disc_scr.R for use in model
# num_seed, num_samp, num_tot
# frac_training, frac_testing, frac_validation
# ns_ngrams_counts_1_tr, ns_ngrams_counts_2_tr, ns_ngrams_counts_3_tr, ... up to model_ngram_size
fn_ngrams_counts <- paste0(dir_wd, "\\", "ns_ngrams_counts_for_model_gtd_", as.character(model_ngram_size), ".RData")
load(file = fn_ngrams_counts)
# stack ns_ngrams_counts_*_tr into one argument that can be passed to model_ngrams_kbo_gtd,
# instead of trying to handle a variable number of arguments in model_ngrams_kbo_gtd, which is used recursively
ns_ngrams_counts <- tibble(ns              = vector(mode = "integer"     , length = 0),
                           ngram           = vector(mode = "character"   , length = 0),
                           ngram_count     = vector(mode = "integer"     , length = 0),
                           ngram_count_gtd = vector(mode = "integer"     , length = 0))
for (q in 1:model_ngram_size) {
  nnc_exp_str_q <- paste0("ns_ngrams_counts_", as.character(q), "_tr")
  eval(parse(text = paste0("ns_ngrams_counts <- rbind(ns_ngrams_counts,", nnc_exp_str_q, ")")))
  # remove individual ns_ngrams_counts_*_tr, as it is no longer needed   
  eval(parse(text = paste0("rm(", nnc_exp_str_q, ")")))
}
# remove objects that will not be used for modeling
rm(dir_wd, fn_ngrams_counts, num_seed, num_samp, num_tot, 
   frac_training, frac_testing, frac_validation,
   q, nnc_exp_str_q)

# save ns_ngrams_counts for use in model
save(ns_ngrams_counts, 
     file = paste0("ns_ngrams_counts_for_model_gtd_merge_", as.character(model_ngram_size), ".RData"))