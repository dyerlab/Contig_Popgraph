library( gstudio ) 
library( popgraph )
library( igraph ) 

files <- list.files(path="data/random_convergence",  pattern="graph_300_",full.names = TRUE) 

m <- matrix(0,nrow=length(files), ncol=29)
a <- matrix(0,nrow=29,ncol=29)

for( i in 1:length(files) ) { 
  file <- files[i]
  g <- NULL
  load(file)
  L <- laplacian_matrix(g)  
  eigs <- eigen(L)
  m[i,] <- eigs$values
  a <- a + to_matrix(g)
}

rownames(m) <- basename(files)

d <- dist(m,method = "euc")
h <- hclust(d)

plot(h)






g1 <- graph.adjacency(a, mode="undirected", weighted = TRUE)
plot(g1)




a[ a == 0 ] <- NA
library(raster)
r <- raster(a)
plot(r)
