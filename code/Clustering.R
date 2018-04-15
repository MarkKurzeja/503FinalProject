library(readr)
library(cluster)
library(ggplot2)
library(gridExtra)
library(ggdendro)
library(factoextra)
library(mclust)

# Read in data, remove rows with missing turnover percentage
dat = read_csv("503projectdata.csv", col_names = TRUE)
dat = dat[-c(16, 476),]
dat$schoolwins = as.factor(dat$schoolwins)
predat = dat[,c(8:10, 21:25, 27:29, 31)]
scaledat = scale(predat) #just the good stuff, scaled

dis = dist(scaledat) #euclidean
mds = as.data.frame(cmdscale(dis, k=2)) #MDS for comparisons

ggplot(mds, aes(x=V2, y=V1)) + geom_point(alpha=0.6) #very unfavorable to clustering

set.seed(123)
gap = clusGap(scaledat, kmeans, K.max=10)
plot(gap) #minimized at 8, not great

dat.clust = Mclust(scaledat)
plot(dat.clust, what = 'BIC')
dat.clust #VVE: 4 components

set.seed(789)
clust_kmeans = kmeans(scaledat, 4)
mds_temp = cbind(mds, as.factor(clust_kmeans$cluster), dat$schoolwins)
names(mds_temp) = c('V1', 'V2', 'cluster','ßwins')
g1= ggplot(mds_temp, aes(x=cluster)) + 
    geom_bar(aes(fill=wins), position = 'dodge') + 
    labs(color = 'Wins', x='Cluster', y = 'Count')
g2= ggplot(mds_temp, aes(x=V2, y=V1, color=cluster, shape=wins)) +
    geom_point() +
    labs(shape='Wins', color='Cluster')
grid.arrange(g1, g2, ncol=2)

fviz_cluster(clust_kmeans, scaledat)

summary(cbind(clust_kmeans$cluster, predat)[which(clust_kmeans$cluster == 4),-1])
