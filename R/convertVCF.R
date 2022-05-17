rm(list=ls())

library(dplyr)
library( stringr )
library( vcfR )

files <- list.files( "data/13098", 
                     pattern="vcf", 
                     full.names = TRUE)

excluded <- c()

files <- files[ !(files %in% excluded) ]


loadVCF <- function( file ) { 
  ret <- tryCatch( 
    {
      vcf <- read.vcfR(file)
      return( vcf )
    }, 
    error = function(cond) { 
      message(paste("file had an error:", file))
      message(cond)
      return(NA)
    },
    
    warning=function(cond) {
      message(paste("warning:", file))
      message(cond)
      return(NA)
    } )
  return( ret )
}



system("touch files.txt")

for( file in files) { 
  print(paste("Working on:", file) )
  vcf <- NA
  ofile <- str_replace(file,".vcf",".rmd")

  cmd <- paste("echo '",file,"' >> files.txt", sep="")
  system( cmd )
  
    
  if( !file.exists(ofile) ) { 
    vcf <- loadVCF(file)
    if( !is.logical(vcf) ) { 
      print("  read")
      e <- extract.gt(vcf, as.numeric = TRUE)
      print("  converted")
      
      t(e) -> t
      as.data.frame(t) %>%
        mutate( ID = str_split( rownames(t), pattern = "_", simplify = TRUE)[,1] ) %>%
        mutate( Population = str_split(basename(file),pattern="_", simplify=T)[1,1] ) %>% 
        select( Population, ID, everything() ) -> df
      
      rownames(df) <- NULL
      head(df[,1:10])
      
      save(df, file=ofile)
      print("  saved")
    }
  }
  
  system("echo '    - done' >> files.txt ")
  

}







