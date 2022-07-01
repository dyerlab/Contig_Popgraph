rm(list=ls())


fly <- list.files("data/13098", pattern=".rda", full.names = TRUE )

load(fly[1])

# load in all and find intersection of all loci
loci <- names(df)
for( file in fly[2:length(fly)]) {
  print( paste("loading", file ) )
  load( file )
  loci <- intersect( loci, names(df))
}



# load them all in for loci in commmon
load(fly[1])
data <- df[ , loci]
for( file in fly[2:length(fly)]) {
  print( paste("loading", file ) )
  load( file )
  data <- rbind( data, df[, loci])
}

dim(data)
summary( factor(data$Population) )


