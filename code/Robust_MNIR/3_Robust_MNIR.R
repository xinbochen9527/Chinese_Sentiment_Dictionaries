###################################################
# ESTIMATE ROBUST MNIR AND STRUCTURE OUTPUT       #
###################################################
rm(list = ls())

## Number of iterations for the robust MNIR algorithm
no.iterations <- 500

## Load packages
require(tibble)
require(dplyr)
require(readr)
require(parallel)
require(textir)
require(tm)
require(slam)
require(DescTools)
require(Matrix)
library(R.matlab)


##########################################
# Function to estimate MNIR 
##########################################

getMnirLoadings <- function(meta = meta, # Data with Y variable
                            filter = T, # Additional filter
                            dtm =  dtm,  # Document term Matrix
                            n.terms = 2^16, # number of terms used
                            nr.clusters = 20 # number of clusters used for MNIR implementation
){
    
  ## initiate cluster
  cl <- makeCluster(nr.clusters)
 
  ## only take the top X terms
  # if(ncol(dtm) > n.terms){dtm <- dtm[, 1:n.terms]}
  
  ## Filter 1: limit with provided filter
  meta <- meta[filter, ]
  dtm <- dtm[filter, ]
  
  ## Filter 2: take out empty documents
  filter2 <- row_sums(dtm) != 0
  meta <- meta[filter2, ]
  dtm <- dtm[filter2, ]
  
  ## Filter 3: take out empty terms
  filter3 <- col_sums(dtm) != 0
  dtm <- dtm[, filter3]
  
  ## Winsorize at 1-99%
  meta$ret_D0 <- Winsorize(meta$ret_D0, probs = c(0.01, 0.99))
  
  ## Fit the MNIR model
  fits <- dmr(cl,
              meta$ret_D0,
              dtm,
              bins = NULL,
              gamma = 0, 
              nlambda = 10,
              verb = 2)
  
  ## Extract MNIR coefs
  mnir.coef <- sort(coef(fits)[2,])
  
  ## end cluster
  stopCluster(cl)
  
  ## output
  return(mnir.coef)
}


##########################################
## Function to structure robust MNIR ouput
##########################################

structureRobustMnirOutput <- function(MNIRest = MNIRest, # output of function getMnirLoadings
                                      wordCount, # word count 
                                      filePath = NULL # output destination
){
  
  # Adjust colname
  names(MNIRest) <- 1:length(MNIRest)
  
  # make into a tibble
  lapply(names(MNIRest), function(cn){
    temp <- tibble(word = names(MNIRest[[cn]]))
    temp[[cn]] <- 0
    temp[[cn]][0 > as.vector(MNIRest)[[cn]]] <- -1
    temp[[cn]][0 < as.vector(MNIRest)[[cn]]] <- 1
    temp
  }) -> MNIRest
  
  # aggregate
  out <- MNIRest[[1]]
  for(i in 2:length(MNIRest)){out <- full_join(out, MNIRest[[i]])}
  MNIRest <- out
  rm(out) 
  
  # summarise 
  MNIRest[,-1] %>% 
    apply(., 1, function(x){
      c(positive = sum(x == 1, na.rm=T), 
        negative = sum(x == -1, na.rm=T), 
        missing = sum(is.na(x)))
    }) %>% 
    t() %>% 
    as_tibble() %>% 
    mutate(word = MNIRest[,1]) -> MNIRest
  MNIRest$word <- unlist(MNIRest$word)
  names(MNIRest$word) <- NULL
  
  # Add information 
  MNIRest %>%
    left_join(wordCount) %>%
    arrange(-(positive-negative)) %>%
    mutate(positive = positive / no.iterations) %>%
    mutate(negative = negative / no.iterations) %>%
    select(word, positive, negative, freq) -> MNIRest
  
  # save
  write.csv(MNIRest, file = filePath, row.names = F)
  
  # end
  return(NULL)}

###############################################
## Estimate Robust MNIR: unigrams, pre 2022
###############################################

## load data
meta <- read.csv(file="data/input/regression_ret.csv")
data <- readMat('data/output/Robust_MNIR/tfidf_matrix_2019_2022.mat')
dtm <- data$tfidf.matrix
words_col <- read.csv('data/output/Robust_MNIR/words_col.csv')
words <- words_col$index
dtm@Dimnames[[2]] <- words
save(dtm, file = "data/output/Robust_MNIR/dtm.RData")
# load("data/input/dtm.RData")

## Transforming the document-term-matrix
## This step is included to transform the document-term. 
## matrix to speed up the MNIR calculation. 

## drop na in meta
print(cat(ncol(meta), nrow(meta)))
has_na <- rowSums(is.na(meta)) > 0
meta <- meta[!has_na, ]
print(cat(ncol(meta), nrow(meta)))
dtm <- dtm[!has_na, ]


ix <- meta$Trddt <= '2021-12-31'
meta <- meta[ix, ]
dtm <- dtm[ix, ]

dtm <- Matrix::as.matrix(dtm)

## estimate robust MNIR
MNIRest <- list()
for(i in 1:no.iterations){
    cat("Iteration", i, "\n")

    # randomly select 5000 observations for each iteration
    filter.sample <- (1:nrow(meta)) %in% (sample(1:nrow(meta), 14000))

    # Call getMnirLoadings function
    MNIRest[[i]] <- getMnirLoadings(meta = meta,
                                    filter = filter.sample,
                                    dtm = dtm,
                                    n.terms = ncol(dtm),
                                    nr.clusters = 10)
}

## Get word counts
load("data/input/dtm.RData")
wordCount <- tibble(word = colnames(dtm), freq = col_sums(dtm))

## structure and save
structureRobustMnirOutput(MNIRest = MNIRest,
                          wordCount = wordCount,
                          filePath = "data/output/ML_score_ret_D0_2019_2021.csv")