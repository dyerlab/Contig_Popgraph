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
sizes <- seq(125,475,by=50)
numReps <- 100
pops <- df$Population

# go through the sizes
for( size in sizes ) { 

  
  cat("[",size,"] ")
  for( rep in 1:numReps) {
    
    snps <- sample( df_snps$Name, size=size, replace = FALSE )   
    
    data <- df[ , snps ]
    mv <- to_mv( as.data.frame( data ) )
    g <- popgraph(mv, pops )
    graph.attributes(g)["SNPs"] <- paste( snps, collapse=",")
    fname <- paste("data/random_convergence/graph_",size,"_",rep,".rda", sep="")
    save(g, file=fname  )
    
    cat(".")
  }   
  cat("\n")
}











