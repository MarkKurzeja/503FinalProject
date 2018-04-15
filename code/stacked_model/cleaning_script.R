#####################################################################
# Cleaning Script - take in the clean data and split it out into 
# training, validation, and testing sets
#####################################################################

rm(list = ls())

# Set the working directory so that relative file paths work
setwd("C:/Users/Mark k/Dropbox/Graduate School/05) Courses/Stats 503/503FinalProject/code/stacked_model")

# Read in the data
data <- read.csv("./503projectdata_clean.csv", header = T, stringsAsFactors = F)

data$schoolwins %<>% as.factor()
data_full <- data
save(data_full, file = "data_full.data")


# Select columns to predict on and then scale each quantitive predictor
takeout <- 
data_reduced <- data %>% 
  dplyr::select(-schoolnames, - schoolurls, -overallwins, -overalllosses, -wins_conf, - losses_conf, -year, -games)
data_reduced[,-c(1,ncol(data_reduced))] %<>% scale()

# data_reduced_pca <- data_reduced %>%
#     dplyr::select(-key, -schoolwins) %>% 
#     princomp() %>% 
#     .$scores %>% 
#     .[,1:9] %>% 
#     cbind(data_reduced %>% dplyr::select(key, schoolwins), .)

# Get the testing data
test_idx <- which(data_full$year == 2018)
data_test <- data_reduced[test_idx, ]
# data_test_pca <- data_reduced_pca[test_idx, ]
save(data_test, file = "data_test.data")
# save(data_test, file = "data_test_pca.data")


# Get the training data
train_idx = sample(seq_len(nrow(data_reduced)), size = 0.7 * nrow(data_reduced))
train_idx = setdiff(train_idx, test_idx)
data_train <- data_reduced[train_idx, ]
save(data_train, file = "data_train.data")

# Get the validation data
validation_idx = 1:nrow(data_reduced) %>% setdiff(test_idx) %>% setdiff(train_idx)
data_validation <- data_reduced[validation_idx, ]
save(data_validation, file = "data_validation.data")

