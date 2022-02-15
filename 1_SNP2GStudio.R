#' This script takes the original data set and pulls out some of the meta data for analyses
#'  as well as defines a function that will grab a random locus from the main data set and 
#'  format it as a gstudio locus.

library( tidyverse )
library( stringr )

# remove everything
rm( list=ls() )
system("rm data/snps_*")
system("rm data/*.rda")

# pull names and locations and save as a data.frame
system("head -1 data/chr2.umich.phased.ordered.snp > data/snps_rss_names.txt")
system("head -5 data/chr2.umich.phased.ordered.snp | tail -1 > data/snps_positions.txt")
names <- str_split( readLines("data/snps_rss_names.txt", n=1), pattern = " " )[[1]]
locations <- str_split( readLines("data/snps_positions.txt", n=1), pattern = " " )[[1]]
df_snps <- data.frame( Name = names, Location = locations)

save( df_snps, file="data/df_snps.rda")

# Pull meta data and save a data.frame
system('cat data/chr2.umich.phased.ordered.snp| cut -d " " -f 1-7 | tail -1194 > snps_sample_info.txt')
read_delim("snps_sample_info.txt", delim = " ", col_names=FALSE) %>%
  distinct() %>%
  mutate(Sex = factor(ifelse( X7 == "m", "Male", "Female") ),
         Population = factor( X3 ), 
         Location = factor( X4 ), 
         Region = factor( X5 ) ) %>%
  select( ID = X1, Population, Location, Region, Sex ) -> df_samples
  save(df_samples, file="data/df_samples.rda")


  
  


# Remove any cruft that is hanging around.
rm( list=c("names","locations", "df_snps", "df_samples") )