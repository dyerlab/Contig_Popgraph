library( ggplot2 ) 
library( gstudio )
library( igraph )



loci <- c(seq(10,100,by=10), seq(125,500,by=25) ) 

res <- matrix(NA,nrow=length(loci),ncol=50 ) 



for( i in 1:length(loci) ) { 
  locus <- loci[i]
  search <- paste("graph_",locus,"_",sep="")
  files <- list.files("data/random_convergence/", pattern=search,full.names = TRUE) 
  
  A <- matrix(0,nrow=29,ncol=29)
  for( file in files ) { 
    g <- NULL
    load(file)
    A <- A + to_matrix(g,mode="adjacency")
  }
  
  g <- graph.adjacency(A,mode="undirected", weighted = TRUE)
  
  res[i,] <- hist(E(g)$weight, breaks=seq(0,100,by=2), plot=FALSE)$counts
  
}

rownames(res) <- loci
colnames(res) <- hist(E(g)$weight, breaks=seq(0,100,by=2), plot=FALSE)$mids


library( raster )
plot( raster(res))
                
df$y <- rep( loci, times=50)
df$x <- rep( hist(E(g)$weight, breaks=seq(0,100,by=2), plot=FALSE)$mids, each=26)

ggplot( df, aes(x,y,fill=layer) ) + 
  geom_tile()
