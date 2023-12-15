## Preamble: set working directory
rm(list = ls())

## packages
require(tibble)
require(dplyr)
require(readr)
require(lfe)
require(stargazer)
require(DescTools)
require(tm)
require(slam)
require(ggplot2)
require(ggthemes)
require(Matrix)
require(fixest)
require(openxlsx)

############################################
## Function to compute words frequency
############################################

## compute sentiment
computeFrequency <- function(
    dict,
    dtm,
    normalize = T, 
    winsorize = T
){
  ## compute sentiment
  sent <- row_sums(dtm[, colnames(dtm) %in% dict], na.rm=T) / row_sums(dtm)
  
  ## normalize
  if(normalize){sent <- sent/sd(sent)}
  
  ## winsorize
  if(winsorize){sent <- DescTools::Winsorize(sent, probs = c(0.01, 0.99))}
  
  ## output
  return(sent)
}

##########################################
# Function to format (round) output
##########################################

print_dec <- function(r,n){
  res <- format(round(r, n), nsmall=n, big.mark = ",")
  res[is.na(r)] <- ""
  res}

############################################################
# Calculate the volatility signals for Earnings calls
############################################################

## Load data
meta_ret <- read.csv("data/input/regression_ret.csv") 
load("data/output/Robust_MNIR/dtm.RData")
print(ncol(dtm))
print(nrow((dtm)))

## return dictionaries constructed using Robust-MNIR
ML_pos <- readLines("data/output/Robust_MNIR/dictionaries/ML_positive_ret_D0_2019_2021.txt")
ML_neg <- readLines("data/output/Robust_MNIR/dictionaries/ML_negative_ret_D0_2019_2021.txt")

## prevailing return dictionaries
JLMZ_pos <- readLines("data/output/Robust_MNIR/dictionaries/JLMZ_pos.txt")
JLMZ_neg <- readLines("data/output/Robust_MNIR/dictionaries/JLMZ_neg.txt")
YFWJZ_media_pos <- readLines("data/output/Robust_MNIR/dictionaries/YFWJZ_media_pos.txt")
YFWJZ_media_neg <- readLines("data/output/Robust_MNIR/dictionaries/YFWJZ_media_neg.txt")
YFWJZ_pos <- readLines("data/output/Robust_MNIR/dictionaries/YFWJZ_pos.txt")
YFWJZ_neg <- readLines("data/output/Robust_MNIR/dictionaries/YFWJZ_neg.txt")

## Compute words frequency
meta_ret$ML_pos <- computeFrequency(ML_pos, dtm)
meta_ret$ML_neg <- computeFrequency(ML_neg, dtm)
meta_ret$JLMZ_pos <- computeFrequency(JLMZ_pos, dtm)
meta_ret$JLMZ_neg <- computeFrequency(JLMZ_neg, dtm)
meta_ret$YFWJZ_media_pos <- computeFrequency(YFWJZ_media_pos, dtm)
meta_ret$YFWJZ_media_neg <- computeFrequency(YFWJZ_media_neg, dtm)
meta_ret$YFWJZ_pos <- computeFrequency(YFWJZ_pos, dtm)
meta_ret$YFWJZ_neg <- computeFrequency(YFWJZ_neg, dtm)

## Compute unique words frequency and intersect words frequency
meta_ret$ML_JLMZ_uni_pos <- computeFrequency(setdiff(ML_pos, JLMZ_pos), dtm)
meta_ret$ML_JLMZ_uni_neg <- computeFrequency(setdiff(ML_neg, JLMZ_neg), dtm)
meta_ret$JLMZ_ML_uni_pos <- computeFrequency(setdiff(JLMZ_pos, ML_pos), dtm)
meta_ret$JLMZ_ML_uni_neg <- computeFrequency(setdiff(JLMZ_neg, ML_neg), dtm)
meta_ret$ML_JLMZ_int_pos <- computeFrequency(intersect(ML_pos, JLMZ_pos), dtm)
meta_ret$ML_JLMZ_int_neg <- computeFrequency(intersect(ML_neg, JLMZ_neg), dtm)

meta_ret$ML_YFWJZ_uni_pos <- computeFrequency(setdiff(ML_pos, YFWJZ_pos), dtm)
meta_ret$ML_YFWJZ_uni_neg <- computeFrequency(setdiff(ML_neg, YFWJZ_neg), dtm)
meta_ret$YFWJZ_ML_uni_pos <- computeFrequency(setdiff(YFWJZ_pos, ML_pos), dtm)
meta_ret$YFWJZ_ML_uni_neg <- computeFrequency(setdiff(YFWJZ_neg, ML_neg), dtm)
meta_ret$ML_YFWJZ_int_pos <- computeFrequency(intersect(ML_pos, YFWJZ_pos), dtm)
meta_ret$ML_YFWJZ_int_neg <- computeFrequency(intersect(ML_neg, YFWJZ_neg), dtm)

meta_ret$ML_YFWJZ_media_uni_pos <- computeFrequency(setdiff(ML_pos, YFWJZ_media_pos), dtm)
meta_ret$ML_YFWJZ_media_uni_neg <- computeFrequency(setdiff(ML_neg, YFWJZ_media_neg), dtm)
meta_ret$YFWJZ_media_ML_uni_pos <- computeFrequency(setdiff(YFWJZ_media_pos, ML_pos), dtm)
meta_ret$YFWJZ_media_ML_uni_neg <- computeFrequency(setdiff(YFWJZ_media_neg, ML_neg), dtm)
meta_ret$ML_YFWJZ_media_int_pos <- computeFrequency(intersect(ML_pos, YFWJZ_media_pos), dtm)
meta_ret$ML_YFWJZ_media_int_neg <- computeFrequency(intersect(ML_neg, YFWJZ_media_neg), dtm)

## save the csv 
write.csv(meta_ret, file='data/output/signals/regression_ret.csv', row.names=FALSE)
