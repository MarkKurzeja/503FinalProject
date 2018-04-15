
################################################################################
#                                                                              #
#                         Stacked Model Implementation                         #
#                                                                              #
################################################################################
rm(list = ls())

library(magrittr)
library(plyr)
library(dplyr)
library(digest)
library(randomForest)
library(mi)
library(nnet)
library(MASS)
library(commentr)
library(e1071)
library(party)
library(ggplot2)
library(tidyr)
library(adabag)


################################################################################
#                                                                              #
#                                Problem Setup                                 #
#                                                                              #
################################################################################
setwd("C:/Users/Mark k/Dropbox/Graduate School/05) Courses/Stats 503/503FinalProject/code/stacked_model")
load("data_train.data")
load("data_validation.data")
load("data_test.data")

validation_out = data_validation
test_out = data_test

################################################################################
#                                                                              #
#                                Random Forest                                 #
#                                                                              #
################################################################################
decisionMatrix <- expand.grid(mtry = c(1,2,4,8, 20), maxnodes = c(NULL, 2,4,8, 50))

a_ply(decisionMatrix, 1, function(i) {
  train_dat_in <- data_train %>% dplyr::select(-key)
  name = sprintf("rf_mtry_%i_maxnodes_%i", i$mtry, i$maxnodes)
  
  model <- randomForest(schoolwins ~ ., data = train_dat_in, mtry = i$mtry, maxnodes = i$maxnodes)
  valout <- predict(model, data_validation %>% dplyr::select(-key))
  testout <- predict(model, data_test %>% dplyr::select(-key))
  
  valout %<>% as.numeric %>% data.frame()
  names(valout) <- name
  testout %<>% as.numeric %>% data.frame()
  names(testout) <- name
  
  validation_out <<- cbind(validation_out, valout)
  test_out <<- cbind(test_out, testout)
  
}, .progress = progress_win("Random Forest Progress"))

################################################################################
#                                                                              #
#                                Decision Trees                                #
#                                                                              #
################################################################################                              
decisionMatrix <- expand.grid(mtry = c(1,2,3,4,5,8,10,12,15), 
                              maxdepth = c(0, 2,4,8, 10, 20, 50), 
                              mincriterion = c(0.90, 0.95, 0.99, 0.999))

a_ply(decisionMatrix, 1, function(i) {
  train_dat_in <- data_train %>% dplyr::select(-key)
  name = sprintf("DT_mtry_%i_mdep_%i_mcrit_%.3f", i$mtry, i$maxdepth, i$mincriterion)
  
  model <- party::ctree(schoolwins ~ ., data = train_dat_in, controls = ctree_control(mtry = i$mtry, maxdepth = i$maxdepth, mincriterion = i$mincriterion))
  valout <- predict(model, data_validation %>% dplyr::select(-key))
  testout <- predict(model, data_test %>% dplyr::select(-key))
  
  valout %<>% as.numeric %>% data.frame()
  names(valout) <- name
  testout %<>% as.numeric %>% data.frame()
  names(testout) <- name
  
  validation_out <<- cbind(validation_out, valout)
  test_out <<- cbind(test_out, testout)
  
}, .progress = progress_win("Decision Tree Progress"))

################################################################################
#                                                                              #
#                          Ordinal Regression Models                           #
#                                                                              #
################################################################################
decisionMatrix <- expand.grid(method = c("logistic", "probit", "loglog"), stringsAsFactors = F)

a_ply(decisionMatrix, 1, function(i) {
  train_dat_in <- data_train %>% dplyr::select(-key)
  name = sprintf("ORD_R_%.5s", i$method)
  
  model <- MASS::polr(schoolwins ~ ., data = train_dat_in, method = i$method)
  valout <- predict(model, data_validation %>% dplyr::select(-key))
  testout <- predict(model, data_test %>% dplyr::select(-key))
  
  valout %<>% as.numeric %>% data.frame()
  names(valout) <- name
  testout %<>% as.numeric %>% data.frame()
  names(testout) <- name
  
  validation_out <<- cbind(validation_out, valout)
  test_out <<- cbind(test_out, testout)
  
}, .progress = progress_win("Ordinal Regression Progress"))

################################################################################
#                                                                              #
#                        Multinomial Regression Models                         #
#                                                                              #
################################################################################
decisionMatrix <- expand.grid(method = c("Run it!!!"), stringsAsFactors = F)

a_ply(decisionMatrix, 1, function(i) {
  train_dat_in <- data_train %>% dplyr::select(-key)
  name = sprintf("Multinomial_Regression")
  
  model <- multinom(schoolwins ~ ., data = train_dat_in, method = i$method)
  valout <- predict(model, data_validation %>% dplyr::select(-key))
  testout <- predict(model, data_test %>% dplyr::select(-key))
  
  valout %<>% as.numeric %>% data.frame()
  names(valout) <- name
  testout %<>% as.numeric %>% data.frame()
  names(testout) <- name
  
  validation_out <<- cbind(validation_out, valout)
  test_out <<- cbind(test_out, testout)
  
}, .progress = progress_win("Multinomial Regression Progress"))

################################################################################
#                                                                              #
#                                     SVM                                      #
#                                                                              #
################################################################################

decisionMatrix <- expand.grid(kernel = c("linear", "radial", "polynomial"), 
                              cost = exp(c(-5:3)), 
                              gamma = c(0.01, 0.05, 0.10))


a_ply(decisionMatrix, 1, function(i) {
  train_dat_in <- data_train %>% dplyr::select(-key)
  name = sprintf("SVM_%.4s_cost_%.2f_gam_%.2f", i$kernel, i$cost, i$gamma)
  
  model <- svm(schoolwins ~ ., data = train_dat_in, kernel = i$kernel, cost = i$cost, gamma = i$gamma)
  valout <- predict(model, data_validation %>% dplyr::select(-key))
  testout <- predict(model, data_test %>% dplyr::select(-key))
  
  valout %<>% as.numeric %>% data.frame()
  names(valout) <- name
  testout %<>% as.numeric %>% data.frame()
  names(testout) <- name
  
  validation_out <<- cbind(validation_out, valout)
  test_out <<- cbind(test_out, testout)
  
}, .progress = progress_win("SVM Progress"))

################################################################################
#                                                                              #
#                                   Adaboost                                   #
#                                                                              #
################################################################################
# decisionMatrix <- expand.grid(mfinal = c(20, 50, 100), 
#                               coeflearn = c("Breiman", "Freund"), 
#                               stringsAsFactors = F)
# 
# a_ply(decisionMatrix, 1, function(i) {
#   
#   train_dat_in <- data_train %>% dplyr::select(-key)
#   name = sprintf("ABOST_mfinal_%i_coefl_%.3s", i$mfinal, i$coeflearn)
#   model <- boosting(schoolwins ~ ., data = train_dat_in, mfinal = i$mfinal,
#                     coeflearn = i$coeflearn)
#   valout <- predict(model, data_validation %>% dplyr::select(-key))
#   testout <- predict(model, data_test %>% dplyr::select(-key))
# 
#   valout %<>% .$class %>% as.numeric %>% data.frame()
#   names(valout) <- name
#   testout %<>% .$class %>% as.numeric %>% data.frame()
#   names(testout) <- name
# 
#   validation_out <<- cbind(validation_out, valout)
#   test_out <<- cbind(test_out, testout)
# 
# }, .progress = progress_win("Adaboost Progress"))

################################################################################
#                                                                              #
#                       Determine which Columns to Keep                        #
#                                                                              #
################################################################################

# Method - rank by smallest correlation to others and by best fit 
# then do a rank weight of those
firstColOfModels <- ncol(data_train) + 1
totalCols <- ncol(validation_out)
selectedModels <- numeric(0)

npreds <- 20

# Employ a greedy algorithm that does the following:
# Gets all models that have not been selected already
# out of those, find the model that has the lowest corrleation 
#    to those selected and highest accuracy
# Find npreds number of such models 
# Stop when done!
for(modelnum in seq_len(npreds)) {
  modelsToConsider = setdiff(firstColOfModels:totalCols, selectedModels)
  rankings <- ldply(modelsToConsider, function(col) {
    totalCor = 0
    
    # If we don't have a model yet, just select the one with the greatest accuracy
    if (length(selectedModels) == 0) {
      totalCor = 1
    } else {
      for(i in selectedModels) {
        totalCor <- totalCor + mean(validation_out[,i] == validation_out[,col])^2
      }
    }
    
    totalAcc <- mean(validation_out[,col] == validation_out$schoolwins)
    data.frame(col, corr = totalCor, acc = totalAcc)
  }, .progress = progress_win(sprintf("Computing the Correlations and Accuracy (%i/%i)", modelnum, npreds)))
  
  # Lower is better for correlation and higher is better for accuracy
  rankings %<>% 
    mutate(corr = dplyr::percent_rank(-corr)) %>% 
    mutate(acc = dplyr::percent_rank(acc)) %>% 
    mutate(score = acc + corr) %>% 
    arrange(-score)
  selectedModels <- append(selectedModels, rankings$col[1])
}

# Get the new validation matrix and test matrix
validation_out <- validation_out[,c(1:(firstColOfModels-1), selectedModels)]
test_out <- test_out[,c(1:(firstColOfModels-1), selectedModels)]


################################################################################
#                                                                              #
#                           Train the Stacking Model                           #
#                                                                              #
################################################################################

ftn <- function(x) {as.numeric(as.character(x))}

# Train a basic decision tree
stacked_model <- ctree(schoolwins ~ . , data = validation_out %>% dplyr::select(-key))


FinalAccuracy_stacked = mean(ftn(predict(stacked_model, test_out)) == ftn(test_out$schoolwins))
PMOneError_stacked = mean(abs(ftn(predict(stacked_model, test_out)) - ftn(test_out$schoolwins)) <= 1)

cat(sprintf("Error Analysis:\n   Final Accuracy: %f\n   PMOneError : %f", FinalAccuracy_stacked * 100, 100 * PMOneError_stacked))

# Get the accuracy for each of the individual models that the stacked model will be trained on
standAloneAccuracy = numeric(0)
standAlonePMOneError = numeric(0)
for(i in firstColOfModels:(firstColOfModels + npreds - 1)) {
  standAloneAccuracy = append(standAloneAccuracy, mean(test_out[,i]== ftn(test_out$schoolwins)))
  standAlonePMOneError = append(standAlonePMOneError, mean(abs(test_out[,i] - ftn(test_out$schoolwins)) <= 1))
}

# Append the Stacked model accuracy to the end of the vectors
standAloneAccuracy = c(standAloneAccuracy, FinalAccuracy_stacked)
standAlonePMOneError = c(standAlonePMOneError, PMOneError_stacked)

# Get the names of all of the models for plotting
plotnames <- c(colnames(test_out)[firstColOfModels:(firstColOfModels + npreds - 1)], "Stacked Model")
pnf <- factor(plotnames, levels = plotnames, ordered = T)

plotdat <- data.frame(`Overall Accuracy` = standAloneAccuracy, 
                      `+/-1 Accuracy` = standAlonePMOneError, 
                      idx = pnf,
                      check.names = F) %>% 
  tidyr::gather("key", "value", -idx) %>% 
  rowwise %>% 
  mutate(value_txt = sprintf("%.0f%%", value * 100))
ggplot(plotdat) +
  geom_text(aes(value, idx, label = value_txt)) + 
  facet_grid(~key) +
  ggtitle("Stacked Model Accuracy", "Individual Out of Sample Model Errors Vs Stacked Model Out of Sample Errors") + 
  labs(x = "Percentage Accuracy", y = "Model Name") + 
  theme(axis.title.y = element_blank()) + 
  scale_x_continuous(labels = scales::percent)

ggsave("../../fig/StackedModelAccuracy.pdf", device = "pdf", width = 8, height = 4)


# Confusion Matrix
table(test_out$schoolwins, predict(stacked_model, test_out))


