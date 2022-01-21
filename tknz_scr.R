# specify and set working directory
dir_wd <- "C:\\Users\\josep\\data_science\\Data_Science_Capstone"
setwd(dir_wd)

# source functions called
source("rmv_pf.R")
source("tokenize.R")

# load libraries
library(dplyr)
library(stringr)
library(tibble) # needed to look at tibble data frame produced by tokenize

# specify the language
# "de_DE", "en_US", fi_FI", or "ru_RU"
str_lng <- "en_US" 

# load data frames with complete corpora text data
load(file = paste(str_lng, ".", "blogs"  , ".", "RData", sep="")) # df_bl
load(file = paste(str_lng, ".", "news"   , ".", "RData", sep="")) # df_nw
load(file = paste(str_lng, ".", "twitter", ".", "RData", sep="")) # df_tw

# See notes.docx in with data files for more information about the purpose of this step.
# this step removes problematic character sets that come from encoding issues
# this step should be moved to a function later
# 1. filter out lines with various codes starting with "\u00"
# Note: str_detect expects the full four digits "\u00**" to be specified,
# and that is why all known cases are listed
# 2. also filter out "â" followed by a euro sign which seems to primarily occur in the blogs file,
#    but because R cannot save this script with a euro sign in its usual encoding (ISO8859-1),
#    just remove all rows with "â" without euro as well. This ends up removing some French words
#    and proper names.

df_bl_orig <- df_bl
df_bl <- filter(df_bl, !str_detect(text,"\u0091"))
df_bl <- filter(df_bl, !str_detect(text,"\u0092"))
df_bl <- filter(df_bl, !str_detect(text,"\u0093"))
df_bl <- filter(df_bl, !str_detect(text,"\u0094"))
df_bl <- filter(df_bl, !str_detect(text,"\u0095"))
df_bl <- filter(df_bl, !str_detect(text,"\u0096"))
df_bl <- filter(df_bl, !str_detect(text,"\u0097"))
df_bl <- filter(df_bl, !str_detect(text,"â"))

df_nw_orig <- df_nw
df_nw <- filter(df_nw, !str_detect(text,"\u0091"))
df_nw <- filter(df_nw, !str_detect(text,"\u0092"))
df_nw <- filter(df_nw, !str_detect(text,"\u0093"))
df_nw <- filter(df_nw, !str_detect(text,"\u0094"))
df_nw <- filter(df_nw, !str_detect(text,"\u0095"))
df_nw <- filter(df_nw, !str_detect(text,"\u0096"))
df_nw <- filter(df_nw, !str_detect(text,"\u0097"))
df_nw <- filter(df_nw, !str_detect(text,"â"))

df_tw_orig <- df_tw
df_tw <- filter(df_tw, !str_detect(text,"\u0091"))
df_tw <- filter(df_tw, !str_detect(text,"\u0092"))
df_tw <- filter(df_tw, !str_detect(text,"\u0093"))
df_tw <- filter(df_tw, !str_detect(text,"\u0094"))
df_tw <- filter(df_tw, !str_detect(text,"\u0095"))
df_tw <- filter(df_tw, !str_detect(text,"\u0096"))
df_tw <- filter(df_tw, !str_detect(text,"\u0097"))
df_tw <- filter(df_tw, !str_detect(text,"â"))

# concatenate the data frames from the three coropora types, as we want our
# prediction model to have contributions from all three types
df_all <- rbind(df_bl, df_nw, df_tw)

# set the parameters for the size of the training, testing, and validation sets
# these may need to be adjusted as we improve the model
# fraction assigned to training, testing, and validation
frac_training   <- 0.7
frac_testing    <- 0.2
frac_validation <- 0.1
# determine number of text lines to be used for training, testing, and validation 
# may need to be increased if the model is not good enough
# our initial assumption is that the model can be built on a subset of available text lines
# the processing below would take much too long if we did not use a subset
# any NLP model has to be based on a text subset, as we could never use all text ever written
num_tot <- 500000
num_training   <- frac_training   * num_tot
num_testing    <- frac_testing    * num_tot
num_validation <- frac_validation * num_tot

# obtain a random subset of df_all from which we will extract
# the training, testing, and validation sets
# this approach is used because although the lines in the corpora files
# appear random, we do not actually know how they were produced
# by taking a random subset after concatenation the different types of corpora text lines
# will be extracted in approximate proportion to their individual number of lines
# keep seed at 0 so that we have repeatability
# sample 5% more than total number wanted so that we still have at least num_tot
# lines still available after removing lines with profanity 
num_seed <- 0
set.seed(num_seed)
num_samp <- (1+0.05)*num_tot
text_tot <- sample(df_all$text, size = num_samp)
df_samp <- data.frame(text = text_tot, stringsAsFactors = FALSE)

# force all text to be lowercase. this may be revisited later.
df_samp_orig_1 <- df_samp
df_samp <- mutate(df_samp, text = str_to_lower(text))

# profanity removal: we do not want our model to make profane, racist, or sexist predictions.
# If a string has profanity or racist or sexist slurs the whole string is removed,
# because the meaning will be lost if we try to exclude a single word,
# we do not have a way to replace that word, and we do not want to promote that meaning anyway.
# **it may be possible to optimize the rmv_pf.R function using dplyr functions**
# **note that it only looks for lowercase**
start_time_rmv_pf <- Sys.time()
list_rm_pf <- rmv_pf(df_samp$text)
end_time_rmv_pf <- Sys.time()
# determine amount of time it takes to remove profanity
end_time_rmv_pf - start_time_rmv_pf
# time difference of  4.258319 mins  for  21,000 strings on 2021/02/22 at 19:03
# time difference of 24.98119  mins  for 105,000 strings on 2021/03/14 at 00:41
# time difference of  2.549008 hours for 525,000 strings on 2021/03/21 at 23:54 
df_samp_orig_2 <- df_samp
df_samp <- data.frame(text = list_rm_pf$text_vec_no_pf, stringsAsFactors = FALSE)

# extract training, testing, and validation sections
# (note: num_samp is likely larger than num_tot, so just taking topmost rows)
text_tr <- df_samp$text[1:num_training]
text_ts <- df_samp$text[(num_training+1):(num_training+num_testing)]
text_vl <- df_samp$text[(num_training+num_testing+1):num_tot]

# tokenization
# **it may be possible to optimize the tokenize.R function using dplyr functions**

start_time_tknzd_tr <- Sys.time()
tknzd_tr <- tokenize(text_tr)
end_time_tknzd_tr <- Sys.time()
end_time_tknzd_tr - start_time_tknzd_tr
# time difference of  7.467304 mins  for  14,000 strings on 2021/02/22 at 19:41
# time difference of 24.66569  mins  for  70,000 strings on 2021/03/14 at 01:05
# time difference of 11.2113   hours for 350,000 strings on 2021/03/22 at 11:07

start_time_tknzd_ts <- Sys.time()
tknzd_ts <- tokenize(text_ts)
end_time_tknzd_ts <- Sys.time()
end_time_tknzd_ts - start_time_tknzd_ts
# time difference of 39.65079  secs for   4,000 strings on 2021/02/22 at 19:42
# time difference of  2.481985 mins for  20,000 strings on 2021/03/14 at 01:08
# time difference of 48.74317  mins for 100,000 strings on 2021/03/22 at 11:56

start_time_tknzd_vl <- Sys.time()
tknzd_vl <- tokenize(text_vl)
end_time_tknzd_vl <- Sys.time()
end_time_tknzd_vl - start_time_tknzd_vl
# time difference of 11.61247 secs for  2,000 strings on 2021/02/22 at 19:42
# time difference of 50.27962 secs for 10,000 strings on 2021/03/14 at 01:09
# time difference of 12.52552 mins for 50,000 strings on 2021/03/22 at 12:08

# saved tokenized output
save(frac_training, frac_testing, frac_validation,
     num_tot, num_seed, num_samp,
     text_tr, text_ts, text_vl,
     tknzd_tr, tknzd_ts, tknzd_vl,
     file = "tknzd.RData") 