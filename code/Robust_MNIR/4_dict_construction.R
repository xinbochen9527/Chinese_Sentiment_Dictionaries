####################################################
## CONSTRUCT DICTIONARIES                          #
####################################################

# Preamble, setting working directory

rm(list = ls())

## packages
require(tibble)
require(dplyr)
require(readr)

##########################################################
# ML unigram  construct volatility unigram dictionary
##########################################################

## construct and save positive dictionary
read_csv("data/output/Robust_MNIR/ML_score_ret_D0_2019_2021.csv") %>% 
  filter(positive-negative >= 0.8) %>% 
  pull(word) %>% 
  write_lines(file = "data/output/Robust_MNIR/dictionaries/ML_positive_ret_D0_2019_2021.txt")

## construct and save positive dictionary
read_csv("data/output/Robust_MNIR/ML_score_ret_D0_2019_2021.csv") %>% 
  filter(negative-positive >= 0.8) %>% 
  pull(word) %>% 
  write_lines(file = "data/output/Robust_MNIR/dictionaries/ML_negative_ret_D0_2019_2021.txt")

