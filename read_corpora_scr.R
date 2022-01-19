# specify and set working directory
dir_wd <- "C:\\Users\\josep\\data_science\\Data_Science_Capstone"
setwd(dir_wd)

# source functions
source("read_corpora.R")

# specify the base directory where the corpora are located
dir_base <- "C:\\Users\\josep\\data_science\\Data_Science_Capstone\\Coursera-SwiftKey\\final"

# specify the language
# "de_DE", "en_US", fi_FI", or "ru_RU"
str_lng <- "en_US"

# determine the complete directory name
dir_comp <- paste(dir_base, str_lng, sep="\\")

# determine the file names
fn_bl <- paste(str_lng, ".", "blogs"  , ".", "txt", sep="")
fn_nw <- paste(str_lng, ".", "news"   , ".", "txt", sep="")
fn_tw <- paste(str_lng, ".", "twitter", ".", "txt", sep="")

# determine the complete file paths
dir_fn_comp_bl <- paste(dir_comp, fn_bl, sep="\\")
dir_fn_comp_nw <- paste(dir_comp, fn_nw, sep="\\")
dir_fn_comp_tw <- paste(dir_comp, fn_tw, sep="\\")

# specify the file encoding ("latin1" or "UTF-8")
# See notes.docx in with data files for information
# about why these files are not exactly in UTF-8 encoding,
# and that there are still some undesirable characters
# in the files output by this script. That is, nothing
# has been done to remove them in this script. It is done
# later as necessary for the tokenization.
enc_bl <- "UTF-8" # blogs
enc_nw <- "UTF-8" # news
enc_tw <- "UTF-8" # twitter

# read in the corpora data
# blogs
start_time_read_bl <- Sys.time()
df_bl <- read_corpora(dir_fn_comp_bl,enc_bl)
end_time_read_bl <- Sys.time()
# news
start_time_read_nw <- Sys.time()
df_nw <- read_corpora(dir_fn_comp_nw,enc_nw)
end_time_read_nw <- Sys.time()
# twitter
start_time_read_tw <- Sys.time()
df_tw <- read_corpora(dir_fn_comp_tw,enc_tw)
end_time_read_tw <- Sys.time()

# determine amount of time it takes to read in data
#   blogs: 4.255616 secs on 2021/02/21 at 23:32
end_time_read_bl - start_time_read_bl
#    news: 2.143269 secs on 2021/02/21 at 23:32
end_time_read_nw - start_time_read_nw
# twitter: 2.427474 secs on 2021/02/21 at 23:32
end_time_read_tw - start_time_read_tw

# save data frames with complete corpora text data
save(df_bl, file = paste(str_lng, ".", "blogs"  , ".", "RData", sep=""))
save(df_nw, file = paste(str_lng, ".", "news"   , ".", "RData", sep=""))
save(df_tw, file = paste(str_lng, ".", "twitter", ".", "RData", sep=""))