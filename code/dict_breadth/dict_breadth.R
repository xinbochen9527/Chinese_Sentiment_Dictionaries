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

##########################################
# Function to format (round) output
##########################################

print_dec <- function(r,n){
  res <- format(round(r, n), nsmall=n, big.mark = ",")
  res[is.na(r)] <- ""
  res}

#############################################
# Table: the number of dictionary words 
#############################################

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


## load data
load("data/input/dtm.RData")

MLposCov <- sum(dtm[, dtm@Dimnames[[2]] %in% ML_pos]) / sum(dtm@x)
MLnegCov <- sum(dtm[, dtm@Dimnames[[2]] %in% ML_neg]) / sum(dtm@x)

YFWJZposCov <- sum(dtm[, dtm@Dimnames[[2]] %in% YFWJZ_pos]) / sum(dtm@x)
YFWJZnegCov <- sum(dtm[, dtm@Dimnames[[2]] %in% YFWJZ_neg]) / sum(dtm@x)

YFWJZmediaposCov <- sum(dtm[, dtm@Dimnames[[2]] %in% YFWJZ_media_pos]) / sum(dtm@x)
YFWJZmedianegCov <- sum(dtm[, dtm@Dimnames[[2]] %in% YFWJZ_media_neg]) / sum(dtm@x)

JLMZposCov <- sum(dtm[, dtm@Dimnames[[2]] %in% JLMZ_pos]) / sum(dtm@x)
JLMZnegCov <- sum(dtm[, dtm@Dimnames[[2]] %in% JLMZ_neg]) / sum(dtm@x)


## Output positive dictionaries
rbind(
  c("Robust-MNIR dictionaries positive", 
    print_dec(length(ML_pos), 0), 
    print_dec(MLposCov*100, 1)), 
  
  c("YFWJZ dictionaries positive", 
    print_dec(length(YFWJZ_pos), 0), 
    print_dec(YFWJZposCov*100, 1)),

  c("YFWJZ media dictionaries positive", 
    print_dec(length(YFWJZ_media_pos), 0), 
    print_dec(YFWJZmediaposCov*100, 1)),

  c("JLMZ dictionaries positive", 
    print_dec(length(JLMZ_pos), 0), 
    print_dec(JLMZposCov*100, 1))

) -> tempPos


## Output negative dictionaries
rbind(
  c("Robust-MNIR dictionaries negative", 
    print_dec(length(ML_neg), 0), 
    print_dec(MLnegCov*100, 1)), 
  
  c("YFWJZ dictionaries negative", 
    print_dec(length(YFWJZ_neg), 0), 
    print_dec(YFWJZnegCov*100, 1)),

  c("YFWJZ media dictionaries negative", 
    print_dec(length(YFWJZ_media_neg), 0), 
    print_dec(YFWJZmedianegCov*100, 1)),

  c("JLMZ dictionaries negative", 
    print_dec(length(JLMZ_neg), 0), 
    print_dec(JLMZnegCov*100, 1))

) -> tempNeg

# Save tempPos and tempNeg to CSV files
write.csv(tempPos, file = "data/output/dict_breadth/tempPos.csv", row.names = FALSE)
write.csv(tempNeg, file = "data/output/dict_breadth/tempNeg.csv", row.names = FALSE)