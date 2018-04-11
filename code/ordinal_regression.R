
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
library(stringr)
library(bayesplot)
library(rstan)
library(rstanarm)
theme_set(theme_grey())
options(mc.cores = 8)

# Set the working directory so that relative file paths work
setwd("C:/Users/Mark/Dropbox/Graduate School/05) Courses/Stats 503/503FinalProject/code")

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


# Run the analysis using Rstanarm so that we can have an diea of what is driving the analysis

scaled_train_data <- train_dat %>% 
  select(-key) %>% 
  {.[3:ncol(.)]} %>% 
  scale() %>% 
  data.frame() %>% 
  cbind(train_dat %>% select(schoolwins), .)


post0 <- stan_polr(schoolwins ~ ., data = scaled_train_data, 
                   prior = R2(0.05), prior_counts = dirichlet(1),
                   chains = 4, cores = 8, seed = 123, iter = 1000)
save(post0, file = "polr_model_results.stan")
load(file = "./polr_model_results.stan")

# Plot the joint of overall wins and games played
post0 %>% as.matrix() %>% .[,1:3] %>% as.data.frame() %>% GGally::ggpairs()
ggsave("../fig/polr_correlation.pdf", device = "pdf", height = 4, width = 6)



################################################################################
#                                                                              #
#                         Remove Multicolliner Columns                         #
#                                                                              #
################################################################################

post0_updated <- stan_polr(schoolwins ~ (.)^2, data = scaled_train_data %>% select(-overallwins, -games, - efg_pct), 
                   prior = R2(0.05), prior_counts = dirichlet(1),
                   chains = 4, cores = 8, seed = 123, iter = 1000)
save(post0_updated, file = "polr_model_results_updated.stan")
load(file = "./polr_model_results_updated.stan")


pp_check(post0_updated, plotfun = "bars")
ggsave("../fig/polr_nonames_pp.pdf", device = "pdf", height = 4, width = 6)
# 
# post0_updated %>% as.matrix() %>% as.data.frame() %>% .[,1:17] %>% head() %>%
#   {adply(.data = ., 2, .fun = function(i) {
#     data.frame(mean(i, na.rm = T))
#   })}


# launch_shinystan(post0)
# launch_shinystan(post0_updated)


np <- bayesplot::nuts_params(post0_updated)
bayesplot::mcmc_nuts_energy(np) 
ggsave("../fig/polr_chain_convergence.pdf", device = "pdf", height = 4, width = 6)

rstan::stan_ac(post0_updated, pars = c("overalllosses", "wins_conf", "pts", "ts_pct"), fill = "blue", color = "blue", nrow = 2, ncol = 2)
ggsave("../fig/polr_autocorr.pdf", device = "pdf", height = 4, width = 6)



# See how it predicts in_sample
k <- posterior_predict(post0, scaled_train_data, draws = 2000)
pred_result <- apply(k, 2, function(i) {
  sort(table(i), decreasing = T) %>% names() %>% .[1] %>% as.numeric()
})
table(scaled_train_data$schoolwins %>% as.numeric() %>% {.-1}, pred_result)  %>% xtable::xtable()


# Get the estimates of the coefficients
post0_points <- as.matrix(post0_updated) %>% 
  as.data.frame() %>% 
  {.[,1:17]} %>% 
  {apply(., 2, median)}
# Plot the posterior intervals
posterior_interval(post0_updated, prob = .95)[1:17,1:2] %>% 
  as.data.frame() %>% 
  mutate(param = rownames(.), median = post0_points) %>% 
  ggplot(.) + 
  theme_gray() +
  geom_hline(yintercept = 0) +
  geom_linerange(aes(x = param, ymin = `2.5%`, ymax = `97.5%`), size = 1.25) + 
  geom_point(aes(x = param, y = median), color = "red", shape = 15) + 
  geom_point(aes(x = param, y = `2.5%`), shape = "[", size = 3) +
  geom_point(aes(x = param, y = `97.5%`), shape = "]", size = 3) +
  ggtitle("95% Credible Intervals for the Log-Odds", 
          str_wrap("Credible Intervals that contain zero give indication that the overall effect does not differ significant from an odds change of 1.")) +
  coord_flip()
ggsave("../fig/polr_coef.pdf", device = "pdf", height = 4, width = 6)






# plot(post0, show_density = TRUE, ci_level = 0.5, fill_color = "purple")
# plot(post0, plotfun = "hist", pars = "games", include = FALSE)
# plot(post0, plotfun = "trace", pars = c("games"), inc_warmup = TRUE)
# plot(post0, plotfun = "rhat") + ggtitle("Example of adding title to plot")


###############################################################################
#                                                                              #
#           Now work with the names of the schools as predictors too           #
#                                                                              #
################################################################################

# Read in the data
data <- read.csv("../data/503projectdata_clean.csv", header = T, stringsAsFactors = F)

# function for preprocessing the data - aim is to get it into a form that the algo can accept
preprocess <- function(din) {
  din %>% 
    mutate(schoolwins = as.factor(schoolwins)) %>%
    mutate(schoolnames = as.factor(schoolnames))
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

scaled_train_data <- train_dat
scaled_train_data[4:23] <- scale(scaled_train_data[4:23])
scaled_train_data %<>% select(-key)
scaled_train_data %<>% select(- schoolurls)

# Create an indicator to say whether they have won the tournament before



library(rstanarm)
options(mc.cores = 8)
post1 <- stan_polr(schoolwins ~ ., data = scaled_train_data , 
                   prior = R2(0.05), prior_counts = dirichlet(1),
                   chains = 4, cores = 8, seed = 123, iter = 1000, algorithm = "sampling")

# save(post1, file = "polr_model_results_w_names.stan")
load(file = "polr_model_results_w_names.stan")

pp_check(post1, plotfun = "bars")

# launch_shinystan(post1)
posterior_interval(post1, prob = .95) %>% 
  as.matrix() %>% {.[1:275, ]} %>% 
  {as.data.frame(.,)} %>%
  mutate(idx = 1:275) %>% 
  ggplot() + 
  geom_linerange(aes(x = idx, ymin = `2.5%`, ymax = `97.5%`), alpha = 0.75, color = "blue") + 
  geom_hline(yintercept = 0) + 
  ggtitle("95% Credible Intervals for the Log-Odds for each Team in the Tournament")
ggsave("../fig/polr_team_log_odds.pdf", device = "pdf", height = 4, width = 6)












