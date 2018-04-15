library(readr)
library(cluster)
library(ggplot2)
library(gridExtra)
library(ggdendro)
library(factoextra)
library(mclust)
library(dplyr)

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
mdsplot = function(cl){
  mds_temp = cbind(mds, as.factor(cl), dat$schoolwins)
  names(mds_temp) = c('V1', 'V2', 'cluster','wins')
  g1= ggplot(mds_temp, aes(x=cluster)) + 
    geom_bar(aes(fill=wins), position = 'dodge') + 
    labs(color = 'Wins', x='Cluster', y = 'Count')
  g2= ggplot(mds_temp, aes(x=V2, y=V1, color=cluster, shape=wins)) +
    geom_point() +
    labs(shape='Wins', color='Cluster')
  grid.arrange(g1, g2, ncol=2)
}
mdsplot(clust_kmeans$cluster)

fviz_cluster(clust_kmeans, scaledat)
weak = function(cl, weak){
  plotdat = cbind(weakclust = cl ==weak, scaledat)
  plotdat = apply(plotdat[which(plotdat[,1]==1),],2,mean)[-1]
  plotdat = melt(plotdat)
  ggplot(plotdat,aes(x=rownames(plotdat), y=value)) + 
    geom_col() +
    labs(x='Predictor',y='Normalized Value, Relative to Center')
}

weak(clust_kmeans$cluster,4)

silk = silhouette(clust_kmeans$cluster, dis)
fviz_silhouette(silk)

#alternative distances to consider
dis2 = dist(scaledat, method = 'manhattan') #manhattan
dis3 = daisy(scaledat, metric = 'gower')

sing = list(dis = agnes(dis, diss=T, method='single'), 
                 dis2 = agnes(dis2, diss=T, method='single'),
                 dis3 = agnes(dis3, diss=T, method='single'))

comp = list(dis = agnes(dis, diss=T, method='complete'), 
                 dis2 = agnes(dis2, diss=T, method='complete'),
                 dis3 = agnes(dis3, diss=T, method='complete'))

ward = list(dis = agnes(dis, diss=T, method='ward'), 
                 dis2 = agnes(dis2, diss=T, method='ward'),
                 dis3 = agnes(dis3, diss=T, method='ward'))

get_sil = function(distance, k){
  sil_sing = silhouette(cutree(sing[[deparse(substitute(distance))]], k=k), distance)
  sil_comp = silhouette(cutree(comp[[deparse(substitute(distance))]], k=k), distance)
  sil_ward = silhouette(cutree(ward[[deparse(substitute(distance))]], k=k), distance)
  mds_temp = cbind(mds, 
                   as.factor(sil_sing[,1]), 
                   as.factor(sil_comp[,1]), 
                   as.factor(sil_ward[,1]))
  names(mds_temp) = c('V1', 'V2', 'sing_clust', 'comp_clust', 'ward_clust')
  
  gp1 = ggplot(mds_temp, aes(x=V2, y=V1, color=sing_clust)) +
    geom_point() + theme(legend.position="none")
  gp2 = ggplot(mds_temp, aes(x=V2, y=V1, color=comp_clust)) +
    geom_point() + theme(legend.position="none")
  gp3 = ggplot(mds_temp, aes(x=V2, y=V1, color=ward_clust)) +
    geom_point() + theme(legend.position="none")
  grid.arrange(gp1, gp2, gp3, ncol=3)
  return(data.frame(mean_sing = mean(sil_sing[,3]), mean_comp = mean(sil_comp[,3]), mean_ward = mean(sil_ward[,3])))
}

get_sil(dis,4)

sil_comp = silhouette(cutree(comp[[deparse(substitute(dis))]], k=4), dis)

mdsplot(sil_comp[,1])
weak(sil_comp[,1],2)

sil_ward = silhouette(cutree(ward[[deparse(substitute(dis))]], k=4), dis)
mdsplot(sil_ward[,1])
weak(sil_ward[,1],3)

fviz_silhouette(sil_comp)
fviz_silhouette(sil_ward)


