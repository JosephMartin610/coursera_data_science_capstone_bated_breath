# Coursera Data Science Specialization
# Capstone Project: Bated Breath Word Generator

**Goal**

The goal of this project is to make an interactive Shiny web app that takes a sequence of words (a sentence fragment) as input and then predicts the most probable possibilities for the next word as output. This should be achieved by using an n-gram model implemented in R.

**Data**

The data used for this project are a random subset of blogs, news, and tweet items (350,000 items) used to build a catalog of n-grams (sentence fragment of n words; n = 1:5) and their occurrence counts. The source blogs, news, and tweet data can be obtained [here](https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip). The source data files and intermediate data files are too large to be stored on GitHub, so to make use of this, please repeat all steps in R.

**Process Sequence**

The order in which to run the R scripts is as follows:
- read_corpora_scr.R (calls read_corpora.R)
- tknz_scr.R (calls rmv_pf.R and tokenize.R)
- make_ngrams_scr.R (calls make_ngrams_from_tokens.R)
- good_turing_disc_scr.R (calls simple_good_turing.R)
- merge_ns_ngrams_counts_for_model_gtd.R
- model_test_scr.R (calls pred_text_ngrams_kbo_gtd.R which calls model_ngrams_kbo_gtd.R)
- app.R to run Shiny app (calls pred_text_ngrams_kbo_gtd.R which calls model_ngrams_kbo_gtd.R)

Please note that list_profanity_words.txt is only inculded here to ensure the model is not based on strings containing profanity or racist or sexist words, because the model could end up predicting these same words. If you think you may be bothered or offended by these words, please do not review this file.

**Presentation**

The capstone presentation is [here](https://htmlpreview.github.io/?https://github.com/JosephMartin610/coursera_data_science_capstone_bated_breath_word_generator/blob/main/word_generator_presentation-rpubs.html). It has information about model basis and performance.

**App**

During the capstone project, the app was deployed on shinyapps.io, but having a word prediction app that performs decently requires significant memory, and that requires a paid plan on shinyapps.io, so it is not currently available.
