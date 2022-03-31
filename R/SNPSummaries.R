#' This script takes the original data set and pulls out some of the meta data for analyses
#'  as well as defines a function that will grab a random locus from the main data set and 
#'  format it as a gstudio locus.

library( tidyverse )
library( stringr )
library( gstudio )
library( dplyr )
library(DBI)

# remove everything
rm( list=ls() )


# pull names and locations and save as a data.frame
system("head -1 data/chr2.umich.phased.ordered.snp > data/snps_rss_names.txt")
system("head -5 data/chr2.umich.phased.ordered.snp | tail -1 > data/snps_positions.txt")
names <- str_split( readLines("data/snps_rss_names.txt", n=1), pattern = " " )[[1]]
locations <- str_split( readLines("data/snps_positions.txt", n=1), pattern = " " )[[1]]
data.frame( Name = names, 
            Location = as.numeric(locations),
            Ho = NA,
            He = NA,
            p = NA
            ) %>%
  arrange( Location ) -> df_snps 

# go through each of the snps and estimate Neighbor dist, Ho, He, p, and F
K <- nrow(df_snps)
df_snps$neighbor_dist <- NA
df_snps$neighbor_dist[2:K] = df_snps$Location[2:K] - df_snps$Location[1:(K-1)]


# Pull meta data and save a data.frame
system('cat data/chr2.umich.phased.ordered.snp| cut -d " " -f 1-7 | tail -1194 > data/snps_sample_info.txt')
read_delim("data/snps_sample_info.txt", delim = " ", col_names=FALSE) %>%
  distinct() %>%
  mutate(Sex = factor(ifelse( X7 == "m", "Male", "Female") ),
         Population = factor( X3 ), 
         Location = factor( X4 ), 
         Region = factor( X5 ) ) %>%
  select( ID = X1, Population, Location, Region, Sex ) -> df_samples
  





maxLoci <- 7+42588
lineLength <- 20 



for( i in 8:maxLoci) { 
  cat(".")
  cmd <- paste( 'cat data/chr2.umich.phased.ordered.snp | cut -d " " -f ', i, ' > data/tmp.csv' )
  system( cmd, wait = TRUE )  
  df <- readLines( "data/tmp.csv" )
  
  #make into loci
  alleles <- seq(6,length(df))
  idx1 <- alleles[ alleles %% 2 == 0]
  idx2 <- alleles[ alleles %% 2 == 1]
  
  rawAlleles <- paste( df[idx1], df[idx2], sep=":")
  loci <- locus( rawAlleles, type = "separated" )
  locus_name <- df_snps$Name[ (i - 7) ]
  df_samples[[locus_name]] <- loci
  
  df_snps$Ho[ df_snps$Name == locus_name] <- Ho(loci)$Ho
  df_snps$He[ df_snps$Name == locus_name] <- He(loci)$He
  df_snps$p[ df_snps$Name == locus_name] <- min(frequencies(loci)$Frequency)
  
  if( (i - 8) %% lineLength == 0) {
    cat("[", i/lineLength, "/", maxLoci, "]\n")
  }
  
}

df_snps$F <- 1.0 - df_snps$Ho / df_snps$He


save(df_samples, file="data/df_samples.rda")
save(df_snps, file="data/df_snps.rda")

  
  

# Remove any cruft that is hanging around.
unlink("data/snps_positions.txt")
unlink("data/snps_rss_names.txt")
unlink("data/snps_sample_info.txt")
unlink("data/tmp.csv")
rm( list=c("names","locations", "df_snps", "df_samples") )