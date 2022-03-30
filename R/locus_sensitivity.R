library(tidyverse)
library(igraph)
library(popgraph)
library( gstudio )

load("data/df_samples.rda")
df_samples %>%
  filter( !( Population %in% c("CEU_HapMap","JPT_HapMap","YRI_HapMap", "CHB_HapMap" ) ) ) %>%
  droplevels() -> df_samples



file <- "data/random_convergence/graph_90_100.rda"
load(file)
G <- g 
g <- NULL


snps <- strsplit(graph.attributes(G)$SNPs,",")[[1]]
L <- laplacian_matrix(G,normalized = FALSE, sparse=FALSE)
eigs <- eigen(L)
orig <- eigs$values

df <- data.frame( SNP = snps, 
                  distance = NA )

m <- matrix(0,nrow = length(snps), ncol = length(orig) )
pops <- df_samples$Population

for( i in 1:length(snps) ) { 
  
  loci <- snps
  loci[i] <- NA
  loci <- loci[!is.na(loci)]
  
  data <- df_samples[,loci]
  mv <- to_mv( as.data.frame(data )  )
  
  cat(i,"Locus",snps[i],ncol(mv),"\n")
  g <- popgraph(mv, pops )
  L <- laplacian_matrix(g, normalized=FALSE, sparse = FALSE)
  eigs <- eigen(L)
  new <- eigs$values
  m[i,] <- new 
  
  
  
  df$distance[i] <- sqrt( sum( (orig - new)^2 ) )
  theLocus <- as.data.frame(df_samples[,snps[i]])
}


left_join( df)