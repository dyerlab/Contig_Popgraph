load("../data/df_samples.rda")
load("../data/df_snps.rda")
library( tidyverse )
library( popgraph )
library( gstudio )

df_samples %>%
  filter( !(Population %in% c("CEU_HapMap","JPT_HapMap","YRI_HapMap" ))) -> df 

# Take sets of different sizes and construct population graphs
sizes <- c(10,seq(20,100,by=20))
numReps <- 100
pops <- df$Population

print(getwd())

# If there is no directory, then make one and pull out random shit
if( !dir.exists("data/random_convergence") ) { 
  dir.create("data/random_convergence") 

  # go through the sizes
  for( size in sizes ) { 
    for( rep in 1:numReps) {
      snps <- sample( df_snps$Name, size=size, replace = FALSE )   
      data <- df[ , snps ]
      mv <- to_mv( as.data.frame( data ) )
      g <- popgraph(mv, pops )
      g <- set.graph.attribute(g,"snps",paste(snps,collapse=","))
      fname <- paste("../data/random_convergence/graph_",size,"_",rep,".rda", sep="")
      save(g, file = fname )
      cat(".")
    }   
    cat("\n")
  }
}







