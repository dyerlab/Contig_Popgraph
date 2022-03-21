load("data/df_samples.rda")
load("data/df_snps.rda")
library( tidyverse )
library( popgraph )
library( gstudio )
library( igraph )

df_samples %>%
  filter( !(Population %in% c("CEU_HapMap","JPT_HapMap","YRI_HapMap", "CHB_HapMap" ))) %>%
  droplevels() -> df 

# Take sets of different sizes and construct population graphs
sizes <- seq(90,100,by=10)
numReps <- 100
pops <- df$Population

# go through the sizes
for( size in sizes ) { 
  
  
  cat("[",size,"] ")
  for( rep in 1:numReps) {
    
    startLoc <- round(runif( 1, min = 2*max(sizes), max=( nrow(df_snps) - 2*max(sizes) ) ) )
    endLoc <- startLoc + size
    
    snps <- df_snps$Name[ startLoc:endLoc ]
    
    data <- df[ , snps ]
    mv <- to_mv( as.data.frame( data ) )
    g <- popgraph(mv, pops )
    graph.attributes(g)["StartLoc"] <- startLoc 
    graph.attributes(g)["SNPRange"] <- df_snps$Location[endLoc] - df_snps$Location[startLoc]
    graph.attributes(g)["SNPs"] <- paste( snps, collapse=",")
    fname <- paste("data/sequential_convergence/graph_",size,"_",rep,".rda", sep="")
    save(g, file=fname  )
    cat(".")
  }   
  cat("\n")
}











