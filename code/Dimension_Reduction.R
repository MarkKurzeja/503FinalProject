library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(GGally)
library(gridExtra)

dat = read_csv("503projectdata.csv", col_names = TRUE)
dat = dat[-c(16, 476),]
dat$schoolwins = as.factor(dat$schoolwins)
data_mat = as.matrix(dat[,c(8:10, 21:25, 27:29, 31)])

# Remove rows with missing turnover percentage
pc = princomp(scale(data_mat))
summary(pc)

pcs_1and2 = data.frame(cbind(pc$scores[,1:2], schoolwins = dat$schoolwins)) %>%
  ggplot(aes(x = Comp.1, y = Comp.2)) + 
  geom_point(aes(color = schoolwins)) +
  xlab("PC 1") +
  ylab("PC 2")

pcs_1and3 = data.frame(cbind(pc$scores[,1:3], schoolwins = dat$schoolwins)) %>%
  ggplot(aes(x = Comp.1, y = Comp.3)) + 
  geom_point(aes(color = schoolwins)) +
  xlab("PC 1") +
  ylab("PC 3")

pcs_2and3 = data.frame(cbind(pc$scores[,2:3], schoolwins = dat$schoolwins)) %>%
  ggplot(aes(x = Comp.2, y = Comp.3)) + 
  geom_point(aes(color = schoolwins)) +
  xlab("PC 2") +
  ylab("PC 3")

grid.arrange(pcs_1and2, pcs_1and3, pcs_2and3, nrow = 2)

quant_vars = c("winlosspct", "srs", "sos", "fta_per_fga_pct", "fg3a_per_fga_pct",
                "ts_pct", "trb_pct", "ast_pct", "blk_pct", "efg_pct", "tov_pct",
                "ft_rate0")
possible_plots<- expand.grid(0:6, quant_vars)

create_boxplot = function(predictor){
  result = dat %>% 
    ggplot(aes_string(x = "schoolwins", y = predictor)) +
    geom_boxplot()
  return(result)
}

boxplot_list = lapply(quant_vars, create_boxplot)
do.call("grid.arrange", boxplot_list)
ggpairs(data.frame(data_mat))

data.frame(n = 1:12, var = pc$sdev^2/sum(pc$sdev^2)) %>%
  ggplot(aes(x = n, y = var)) +
  geom_point() +
  ylab("Prop. of variance explained") +
  xlab("Number of prin. comps.") +
  ggtitle("PCA skree plot")
