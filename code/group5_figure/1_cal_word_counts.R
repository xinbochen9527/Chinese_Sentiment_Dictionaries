##########################
# Figure 1 cal word counts
##########################
# Load required library
library(Matrix)

# Clear the environment
rm(list = ls())

# Load the document-term matrix (DTM) from the RData file
load("data/output/Robust_MNIR/dtm.RData")

# Read positive and negative word lists from text files
ret_pos <- readLines("data/output/Robust_MNIR/dictionaries/ML_positive_ret_D0_2019_2021.txt")
ret_neg <- readLines("data/output/Robust_MNIR/dictionaries/ML_negative_ret_D0_2019_2021.txt")

# Find column indices of positive and negative words in the DTM
ret_pos_word_indices <- match(ret_pos, colnames(dtm))
ret_neg_word_indices <- match(ret_neg, colnames(dtm))

# Calculate word counts for all words in each document
word_counts <- rowSums(dtm, na.rm = TRUE)

# Print the dimensions of the document-term matrix
print(dim(dtm))

# Calculate word counts for positive and negative words in each document
ret_pos_word_counts <- rowSums(dtm[, ret_pos_word_indices], na.rm = TRUE)
ret_neg_word_counts <- rowSums(dtm[, ret_neg_word_indices], na.rm = TRUE)

# Print the length of the positive word counts
print(length(ret_pos_word_counts))

# Read metadata from a CSV file
meta <- read.csv("data/input/regression_ret.csv")

# Normalize positive and negative word counts by total word counts
meta$ret_pos_word_counts <- ret_pos_word_counts / word_counts
meta$ret_neg_word_counts <- ret_neg_word_counts / word_counts

# Write the updated metadata to a new CSV file
write.csv(meta, file = 'data/output/group5_figure/regression_ret.csv', row.names = FALSE)
