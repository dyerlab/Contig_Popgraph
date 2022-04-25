load("data/df_samples.rda")
load("data/df_snps.rda")
library( tidyverse )
library( popgraph )
library( gstudio )
library( igraph )

df_snps %>%
  filter( p >= 0.05,
          F >= quantile(F,1/10),
          F <= quantile(F,9/10)) -> df_snps

# Take sets of different sizes and construct population graphs
sizes <- seq(10, 500, by=10)
numReps <- 100
pops <- df_samples$Population

# go through the sizes
for( size in sizes ) { 
  cat("[",size,"] ")
  for( rep in 1:numReps) {
    g <- NULL
    
    fname <- paste("data/random_convergence/graph_",size,"_",rep,".rda", sep="")
    if( !file.exists(fname) ) { 
      snps <- sample( df_snps$Name, size=size, replace = FALSE )   
      data <- df_samples[ , snps ]
      mv <- to_mv( as.data.frame( data ) )
      g <- popgraph(mv, pops )
      graph.attributes(g)["SNPs"] <- paste( snps, collapse=",")
      save(g, file=fname  )  
    }
    
    cat(".")
  }   
  cat("\n")
}











