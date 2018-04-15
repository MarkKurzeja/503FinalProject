
################################################################################
#                                                                              #
#                      Code for RF implementation on data                      #
#                                                                              #
################################################################################

library(magrittr)
library(plyr)
library(dplyr)
library(digest)
library(randomForest)
library(mi)

# Set the working directory so that relative file paths work
setwd("C:/Users/Mark k/Dropbox/Graduate School/05) Courses/Stats 503/Final Project/503FinalProject/code")

# Read in the data
data <- read.csv("../data/503projectdata.csv", header = T, stringsAsFactors = F)
# data$key <- vapply(data$schoolurls, FUN = function(i) {digest(i, algo = "murmur32")}, character(1))

# function for preprocessing the data - aim is to get it into a form that the algo can accept
preprocess <- function(din) {
  result <- din %>% 
    dplyr::select(-schoolnames, -schoolurls) %>%
    mutate(schoolwins = as.factor(schoolwins)) 
  
  # Remove the columns that have NA's because i'm too stupid to know what to do with them
  result[,apply(result, 2, function(x) {!any(is.na(x))})]
}

data <- preprocess(data)

# split into train and test sets
train_idx = sample(x = c(TRUE, FALSE), size = nrow(data), replace = T, prob = c(0.80, 0.20))
getTrain <- function() {
  data %>% filter(year != 2017)
}
getTest <- function() {
  data[-train_idx, ]
}

train_dat <- getTrain()
test_dat <- getTest()


# Build up the decision matrix
decisionMatrix <- expand.grid(preprocess = c("pca", "normal"), 
                              mtry = c(1,2,3,4))

adply(decisionMatrix, 1, function(i) {
  
  if(i$preprocess == "pca") {
    # train_dat_in <- train_dat %>% select(-key) %>% mutate(year = as.numeric(year))
    # train_dat_in <- princomp(train_dat_in, cor = T)
    # princomp(train_dat, cor = T)
    train_dat_in <- train_dat
  } else if(i$preprocess == "normal") {
    # do nothing
    train_dat_in <- train_dat
  }
  
  # browser()
  model <- randomForest(schoolwins ~ ., data = train_dat_in %>% select(-key), mtry = i$mtry)
  out <- predict(model, data %>% select(-key))
  result <- data.frame(key = data$key, pred = out) %>% 
    write.table(file = sprintf("./predictions/%s_%s_%i.csv", "rf", i$preprocess, i$mtry), 
                row.names = F, 
                sep = "\t")
})

                              
                              





