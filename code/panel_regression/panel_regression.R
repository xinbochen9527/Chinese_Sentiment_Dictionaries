
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

################################################
# Table  regression based on all dictionaries
################################################

## Load data
meta <- read.csv("data/output/signals/regression_ret.csv")

# drop null
cat(ncol(meta), nrow(meta))
meta <- na.omit(meta)
cat(ncol(meta), nrow(meta))

## Winsorize all variables used in the regression1
for(var in c("ret_D0", "me", "bm", "turnover", "ff3_alpha")){
  meta[[var]] <- DescTools::Winsorize(meta[[var]], probs = c(0.01, 0.99))
}

## take out data used for training
ix <- meta$Trddt > "2021-12-31"
meta <- meta[ix,]
meta$ret_D0 <- meta$ret_D0 * 100
cat(ncol(meta), nrow(meta))

#######################################################
# Table  compare with YFWJZ annual report dictionaries
#######################################################

## Regressions
reg <- list()

reg[[1]] <- felm(
  ret_D0 ~
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta))

reg[[2]] <- felm(
    ret_D0 ~
    + ML_YFWJZ_uni_pos + ML_YFWJZ_uni_neg
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta))

reg[[3]] <- felm(
    ret_D0 ~
    + YFWJZ_ML_uni_pos + YFWJZ_ML_uni_neg
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta)
)

reg[[4]] <- felm(
    ret_D0 ~
    + ML_YFWJZ_int_pos + ML_YFWJZ_int_neg
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta)
)

reg[[5]] <- felm(
    ret_D0 ~
    + ML_YFWJZ_uni_pos + ML_YFWJZ_uni_neg
    + YFWJZ_ML_uni_pos + YFWJZ_ML_uni_neg
    + ML_YFWJZ_int_pos + ML_YFWJZ_int_neg
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta)
)

reg_summary <- stargazer(reg,
          type = "text",
          keep.stat = c("n", "rsq"),
          digits = 2, 
          digits.extra = 0,
          align = T, 
          no.space = T,
          report = "vc*t"
          )

## save the regression results
writeLines(reg_summary, "data/output/panel_regression/regression_YFWJZ.txt")

# #######################################################
# # Table  compare with YFWJZ social media dictionaries
# #######################################################
## Regressions
reg <- list()

reg[[1]] <- felm(
  ret_D0 ~
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta))

reg[[2]] <- felm(
    ret_D0 ~
    + ML_YFWJZ_media_uni_pos + ML_YFWJZ_media_uni_neg
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta))

reg[[3]] <- felm(
    ret_D0 ~
    + YFWJZ_media_ML_uni_pos + YFWJZ_media_ML_uni_neg
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta)
)

reg[[4]] <- felm(
    ret_D0 ~
    + ML_YFWJZ_media_int_pos + ML_YFWJZ_media_int_neg
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta)
)

reg[[5]] <- felm(
    ret_D0 ~
    + ML_YFWJZ_media_uni_pos + ML_YFWJZ_media_uni_neg
    + YFWJZ_media_ML_uni_pos + YFWJZ_media_ML_uni_neg
    + ML_YFWJZ_media_int_pos + ML_YFWJZ_media_int_neg
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta)
)

reg_summary <- stargazer(reg,
          type = "text",
          keep.stat = c("n", "rsq"),
          digits = 2, 
          digits.extra = 0,
          align = T, 
          no.space = T,
          report = "vc*t"
          )

## save the regression results
writeLines(reg_summary, "data/output/panel_regression/regression_YFWJZ_media.txt")

############################################
# Table  compare with JLMZ dicitionaries
############################################
## Regressions
reg <- list()

reg[[1]] <- felm(
  ret_D0 ~
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta))

reg[[2]] <- felm(
    ret_D0 ~
    + ML_JLMZ_uni_pos + ML_JLMZ_uni_neg
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta))

reg[[3]] <- felm(
    ret_D0 ~
    + JLMZ_ML_uni_pos + JLMZ_ML_uni_neg
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta)
)

reg[[4]] <- felm(
    ret_D0 ~
    + ML_JLMZ_int_pos + ML_JLMZ_int_neg
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta)
)

reg[[5]] <- felm(
    ret_D0 ~
    + ML_JLMZ_uni_pos + ML_JLMZ_uni_neg
    + JLMZ_ML_uni_pos + JLMZ_ML_uni_neg
    + ML_JLMZ_int_pos + ML_JLMZ_int_neg
    + log(me) + log(bm) + log(turnover) + ff3_alpha
  | Trdmnt | 0 | Trdmnt,
  data = filter(meta)
)

reg_summary <- stargazer(reg,
          type = "text",
          keep.stat = c("n", "rsq"),
          digits = 2, 
          digits.extra = 0,
          align = T, 
          no.space = T,
          report = "vc*t"
          )

## save the regression results
writeLines(reg_summary, "data/output/panel_regression/regression_JLMZ.txt")
