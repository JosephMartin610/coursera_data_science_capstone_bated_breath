# make sure Good-Turing discounting works and see how it changes counts
# and redistributes probability
# run after make_ngrams_scr.R

# specify and set working directory
dir_wd <- "C:\\Users\\josep\\data_science\\Data_Science_Capstone"
setwd(dir_wd)

# load libraries
library(tibble)
library(stringr)
library(dplyr)
library(edgeR)
library(ggplot2)

# source functions called
source("simple_good_turing.R")

# load output from make_ngrams_scr.R
# n = 1
#load(file = "ns_ngrams_counts_for_model_1.RData")
#ns_ngrams_counts_sel <- ns_ngrams_counts_1_tr
#rm(ns_ngrams_counts_1_tr)
# n = 2
#load(file = "ns_ngrams_counts_for_model_2.RData")
#ns_ngrams_counts_sel <- ns_ngrams_counts_2_tr
#rm(ns_ngrams_counts_1_tr,ns_ngrams_counts_2_tr)
# n = 3
#load(file = "ns_ngrams_counts_for_model_3.RData")
#ns_ngrams_counts_sel <- ns_ngrams_counts_3_tr
#rm(ns_ngrams_counts_1_tr,ns_ngrams_counts_2_tr,ns_ngrams_counts_3_tr)
# n = 4
#load(file = "ns_ngrams_counts_for_model_4.RData")
#ns_ngrams_counts_sel <- ns_ngrams_counts_4_tr
#rm(ns_ngrams_counts_1_tr,ns_ngrams_counts_2_tr,ns_ngrams_counts_3_tr,ns_ngrams_counts_4_tr)
# n = 5
load(file = "ns_ngrams_counts_for_model_5.RData")
ns_ngrams_counts_sel <- ns_ngrams_counts_5_tr
rm(ns_ngrams_counts_1_tr,ns_ngrams_counts_2_tr,ns_ngrams_counts_3_tr,ns_ngrams_counts_4_tr,ns_ngrams_counts_5_tr)

# number of unique n-grams:
#dim(ns_ngrams_counts_sel)[1]
# n = 1:   155,952
# n = 2: 1,758,500
# n = 3: 3,689,046
# n = 4: 4,219,642
# n = 5: 3,811,174

sum_counts <- sum(ns_ngrams_counts_sel$ngram_count)
#sum_counts
# n = 1: 8,245,154
# n = 2: 6,862,705
# n = 3: 5,718,742
# n = 4: 4,754,776
# n = 5: 3,930,862

# t1 (type 1): Simple Good-Turing function that should be in corpustools
#              conf = 1.96 is built into this function
#              simple_good_turing returns the fraction of the total count so have to multiply by sum
ns_ngrams_counts_sel$ngram_count_gtd_t1 <- simple_good_turing(ns_ngrams_counts_sel$ngram_count) *
                                           sum_counts
 
# t2 (type 2): Simple Good-Turing function in edgeR
#              set conf = 1.96
gtd_t2_list <- goodTuring(ns_ngrams_counts_sel$ngram_count, conf = 1.96)
# initialize column for t2 results
ns_ngrams_counts_sel$ngram_count_gtd_t2 <- rep(NaN,dim(ns_ngrams_counts_sel)[1])
# goodTuring returns an element for each unique count, instead of a match to input counts,
# so use a loop to do assignments
# goodTuring returns the fraction of the total count so have to multiply by sum
loop_time_start <- Sys.time()
for (q in 1:length(gtd_t2_list$count)) {
  count_q <- gtd_t2_list$count[q]
  proportion_q <- gtd_t2_list$proportion[q]
  inds_q <- which(ns_ngrams_counts_sel$ngram_count == count_q)
  ns_ngrams_counts_sel$ngram_count_gtd_t2[inds_q] <- proportion_q * sum_counts
}
loop_time_end <- Sys.time()
#loop_time_end - loop_time_start
# n = 1:  4.254628 secs
# n = 2: 32.53312  secs
# n = 3: 48.66094  secs
# n = 4: 18.0676   secs
# n = 5:  4.918856 secs

# compare results from two functions
#diff_counts_t1_t2 <- ns_ngrams_counts_sel$ngram_count_gtd_t2 - ns_ngrams_counts_sel$ngram_count_gtd_t1
# sum_counts_t1_t2 <- ns_ngrams_counts_sel$ngram_count_gtd_t1 + ns_ngrams_counts_sel$ngram_count_gtd_t2
#rel_perc_diff <- abs(diff_counts_t1_t2) / (sum_counts_t1_t2/2) * 100
#min(rel_perc_diff)
#mean(rel_perc_diff)
#max(rel_perc_diff)
# relative percent difference (%)
# n = 1: min = 0,       , mean = 1.487831e-13, max = 5.003447e-13
# n = 2: min = 0.153723 , mean = 0.2517083   , max = 4.213868  
# n = 3: min = 0,       , mean = 2.41444e-13 , max = 4.973953e-13
# n = 4: min = 0,       , mean = 1.214763e-13, max = 3.529907e-13
# n = 5: min = 0.2819331, mean = 0.2896589   , max = 3.275435

# minimum and maximum counts before and after discounting
#min(ns_ngrams_counts_sel$ngram_count)
#max(ns_ngrams_counts_sel$ngram_count)
#min(ns_ngrams_counts_sel$ngram_count_gtd_t1)
#max(ns_ngrams_counts_sel$ngram_count_gtd_t1)
#min(ns_ngrams_counts_sel$ngram_count_gtd_t2)
#max(ns_ngrams_counts_sel$ngram_count_gtd_t2)
# n = 1:     initial: min = 1        ,  max = 392,082
#        discount t1: min = 0.5066466,  max = 392,581.8
#        discount t2: min = 0.5066466,  max = 392,581.8
# n = 2:     initial: min = 1        ,  max =  35,125
#        discount t1: min = 0.3083256,  max =  35,209.14
#        discount t2: min = 0.3087999,  max =  35,263.31
# n = 3:     initial: min = 1        ,  max =   2,791  
#        discount t1: min = 0.1618492,  max =   2,802.158
#        discount t2: min = 0.1618492,  max =   2,802.158
# n = 4:     initial: min = 1        ,  max =     637     
#        discount t1: min = 0.0703001,  max =     637.5794
#        discount t2: min = 0.0703001,  max =     637.5794
# n = 5:     initial: min = 1        ,  max =     289     
#        discount t1: min = 0.02681259, max =     288.236
#        discount t2: min = 0.0267371 , max =     287.4245

# I do not know why there is no difference between t1 and t2 in the n = 1, 3, and 4 cases
# but some difference, although small, in the n = 2 and 5 cases.
# It would take too long to analyze the source code to figure this out,
# and some of the source code may be compiled and difficult to access.
# It is not expected to have a big impact on the results.

# probability shifted to unobserved n-grams
#1 - sum(ns_ngrams_counts_sel$ngram_count_gtd_t1/sum_counts)
#1 - sum(ns_ngrams_counts_sel$ngram_count_gtd_t2/sum_counts)
# n = 1: discount t1: 0.009560282
#        discount t2: 0.009560282
# n = 2: discount t1: 0.1864893
#        discount t2: 0.1864893
# n = 3: discount t1: 0.5587988
#        discount t2: 0.5587988
# n = 4: discount t1: 0.8407698
#        discount t2: 0.8407698
# n = 5: discount t1: 0.952098
#        discount t2: 0.952098


# plot fractional amount of discounting as a function of original count
# this may be useful for the slide deck later

# for plotting purpose only need one example discounting for each count
# the discounting is the same for all n-grams with the same count
ns_ngrams_counts_sel_distinct <- ns_ngrams_counts_sel %>% 
                                 distinct(ngram_count, .keep_all = TRUE) %>%
                                 arrange(ngram_count)
# determine fractional change in count with discounting
frac_chng_t1 <- (ns_ngrams_counts_sel_distinct$ngram_count_gtd_t1 - ns_ngrams_counts_sel_distinct$ngram_count) / 
                 ns_ngrams_counts_sel_distinct$ngram_count
frac_chng_t2 <- (ns_ngrams_counts_sel_distinct$ngram_count_gtd_t2 - ns_ngrams_counts_sel_distinct$ngram_count) / 
                 ns_ngrams_counts_sel_distinct$ngram_count
# determine absolute fractional change
abs_frac_chng_t1 <- abs(frac_chng_t1)
abs_frac_chng_t2 <- abs(frac_chng_t2)

# use maximum count to determine x limits
max(ns_ngrams_counts_sel_distinct$ngram_count)
# use minimum and maximum fractional changes and absolute fractional changes
# to determine y limits
c(min(frac_chng_t1),max(frac_chng_t1))
c(min(frac_chng_t2),max(frac_chng_t2))
c(min(abs_frac_chng_t1),max(abs_frac_chng_t1))
c(min(abs_frac_chng_t2),max(abs_frac_chng_t2))

# n <- 1
#n_plot <- 1
#x_lims <- c(0,400000)
#x_breaks <- seq(0,400000,50000)
##x_lims <- c(0,1000)
##x_breaks <- seq(0,1000,100)
##x_lims <- c(0,20)
##x_breaks <- seq(0,20,1)
#y_lims <- c(-0.5,0.0025)
#y_breaks <- seq(-0.5,0.05,0.05)
#y_lims_abs <- c(1e-07,1)

# n <- 2
#n_plot <- 2
#x_lims <- c(0,40000)
#x_breaks <- seq(0,40000,5000)
##x_lims <- c(0,500)
##x_breaks <- seq(0,500,50)
##x_lims <- c(0,50)
##x_breaks <- seq(0,50,10)
#y_lims <- c(-0.7,0.004)
#y_breaks <- seq(-0.7,0.004,0.05)
#y_lims_abs <- c(1e-08,1)

# n = 3
#n_plot <- 3
#x_lims <- c(0,3000)
#x_breaks <- seq(0,3000,250)
##x_lims <- c(0,500)
##x_breaks <- seq(0,500,50)
##x_lims <- c(0,20)
##x_breaks <- seq(0,20,1)
#y_lims <- c(-0.85,0.004)
#y_breaks <- seq(-0.8,0,0.1)
#y_lims_abs <- c(1e-06,1)

# n = 4
#n_plot <- 4
#x_lims <- c(0,700)
#x_breaks <- seq(0,700,50)
##x_lims <- c(0,20)
##x_breaks <- seq(0,20,1)
#y_lims <- c(-0.95,0.001)
#y_breaks <- seq(-0.9,0,0.1)
#y_lims_abs <- c(1e-05,1)

# n = 5
n_plot <- 5
x_lims <- c(0,300)
x_breaks <- seq(0,300,25)
##x_lims <- c(0,20)
##x_breaks <- seq(0,20,1)
#y_lims <- c(-1,0)
#y_breaks <- seq(-1,0,0.1)
y_lims <- c(-0.1,0)
y_breaks <- seq(-0.1,0,0.01)
y_lims_abs <- c(1e-03,1)

ggplot(ns_ngrams_counts_sel_distinct, aes(x = ngram_count)) +
  geom_line(aes(y = frac_chng_t1), color = "darkred")   +
  geom_line(aes(y = frac_chng_t2), color = "steelblue") + 
  scale_x_continuous(limits = x_lims, breaks = x_breaks) + 
  scale_y_continuous(limits = y_lims, breaks = y_breaks) +
  theme_bw() + 
  labs(x = "N-Gram Count") +
  labs(y = "Fractional Change in N-Gram Count") +
  labs(title = paste( "Good-Turing Discounting, n = ", as.character(n_plot) )) + 
  theme(plot.title = element_text(hjust = 0.5))

ggplot(ns_ngrams_counts_sel_distinct, aes(x = ngram_count)) +
  geom_line(aes(y = abs_frac_chng_t1), color = "darkred")   +
  geom_line(aes(y = abs_frac_chng_t2), color = "steelblue") +
  scale_x_continuous(limits = x_lims, breaks = x_breaks) +
  scale_y_continuous(trans='log10', limits = y_lims_abs) +
  theme_bw() +
  labs(x = "N-Gram Count") +
  labs(y = "Absolute Fractional Change in N-Gram Count") +
  labs(title = paste( "Good-Turing Discounting, n = ", as.character(n_plot) )) +
  theme(plot.title = element_text(hjust = 0.5))

# Note: A warning message such as:
# "Removed 784 row(s) containing missing values (geom_path)"
# occurs if geom_line is plotting things outside the specified limits

ns_ngrams_counts_sel_distinct$ngram_count[max(which(frac_chng_t1 < 0))]
ns_ngrams_counts_sel_distinct$ngram_count[min(which(frac_chng_t1 > 0))]
ns_ngrams_counts_sel_distinct$ngram_count[max(which(frac_chng_t2 < 0))]
ns_ngrams_counts_sel_distinct$ngram_count[min(which(frac_chng_t2 > 0))]
# n = 1: t1: change ranges from negative to slightly positive between counts of 604 and 605
#        t2: change ranges from negative to slightly positive between counts of 604 and 605
#        saved figures to images\disc_n1.png and log_abs_disc_n1.png
# n = 2: t1: change ranges from negative to slightly positive between counts of 463 and 464
#        t2: change ranges from negative to slightly positive between counts of 283 and 284
#        t1 is still negative at higher counts beyond where t2 became positive
#        t1 has an unexpected kink at count of 6, which is concerning, but it is not a major difference
#        after the transition to positive, t2 is slightly larger
#        saved figures to images\disc_n2.png and log_abs_disc_n2.png
# n = 3: t1: change ranges from negative to slightly positive between counts of 340 and 341
#        t2: change ranges from negative to slightly positive between counts of 340 and 341
#        t1 and t2 both have an unexpected kink at count of 8, which is concerning, 
#        but it is not a big deviation, and does occur in both t1 and t2 
#        saved figures to images\disc_n3.png and log_abs_disc_n3.png
# n = 4: t1: change ranges from negative to slightly positive between counts of 432 and 495
#        t2: change ranges from negative to slightly positive between counts of 432 and 495
#        saved figures to images\disc_n4.png and log_abs_disc_n4.png
# n = 5: 
#        t1: change is always negative
#        t2: change is always negative
#        t1 and t2's deviation from each other is more noticeable at higher counts 
#        where the t2 change is more negative (more discounting)
#        saved figures to images\disc_n5.png and log_abs_disc_n5.png
# The most discounting occurs at the lowest counts, which is expected, because these counts 
# are expected to be less well known in the population of all n-grams.
# The differences between t1 and t2 are not that concerning, so I will just use t1
# because it is easier to implement.