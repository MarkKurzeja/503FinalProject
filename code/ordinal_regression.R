
################################################################################
#                                                                              #
#                     Code for Ordinal Regression on Data                      #
#                                                                              #
################################################################################

library(magrittr)
library(plyr)
library(dplyr)
library(digest)
library(randomForest)
library(mi)

# Set the working directory so that relative file paths work
setwd("C:/Users/Mark/Dropbox/Graduate School/05) Courses/Stats 503/Final Project/503FinalProject/code")

# Read in the data
data <- read.csv("../data/503projectdata_clean_key.csv", header = T, stringsAsFactors = F)

# function for preprocessing the data - aim is to get it into a form that the algo can accept
preprocess <- function(din) {
  result <- din %>% 
    mutate(schoolwins = as.factor(schoolwins)) 
  result
}

data <- preprocess(data)

# split into train and test sets
getTrain <- function() {
  data %>% filter(year != 2017)
}
getTest <- function() {
  data %>% filter(year == 2017)
}

train_dat <- getTrain()
test_dat <- getTest()


# Build up the decision matrix
# decisionMatrix <- expand.grid(preprocess = c("pca", "normal"), 
#                               mtry = c(1,2,3,4))
# 
# adply(decisionMatrix, 1, function(i) {
#   
#   if(i$preprocess == "pca") {
#     # train_dat_in <- train_dat %>% select(-key) %>% mutate(year = as.numeric(year))
#     # train_dat_in <- princomp(train_dat_in, cor = T)
#     # princomp(train_dat, cor = T)
#     train_dat_in <- train_dat
#   } else if(i$preprocess == "normal") {
#     # do nothing
#     train_dat_in <- train_dat
#   }
#   
#   # browser()
#   model <- randomForest(schoolwins ~ ., data = train_dat_in %>% select(-key), mtry = i$mtry)
#   out <- predict(model, test_dat %>% select(-key))
#   result <- data.frame(key = test_dat$key, pred = out) %>% 
#     write.table(file = sprintf("./predictions/%s_%s_%i.csv", "rf", i$preprocess, i$mtry), row.names = F)
# })

# Run the analysis using Rstanarm so that we can have an diea of what is driving the analysis

scaled_train_data <- train_dat %>% 
  select(-key) %>% 
  {.[3:ncol(.)]} %>% 
  scale() %>% 
  data.frame() %>% 
  cbind(train_dat %>% select(schoolwins), .)

library(rstanarm)
options(mc.cores = 8)
post0 <- stan_polr(schoolwins ~ ., data = scaled_train_data, 
                   prior = R2(0.05), prior_counts = dirichlet(1),
                   chains = 4, cores = 8, seed = 123, iter = 1000)

save(post0, file = "polr_model_results.stan")
load(file = "polr_model_results.stan")

launch_shinystan(post0)











