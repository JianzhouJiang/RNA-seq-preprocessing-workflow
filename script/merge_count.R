
library(dplyr)
library(clusterProfiler)
library(org.Hs.eg.db)
library(stringr)

#setwd('/raid1/chenruzhen/sra/sra_befaft')
#setwd('/raid1/chenruzhen/sra/ae')
#setwd('/raid1/chenruzhen/sra/sra_acquire')
#setwd('/raid1/chenruzhen/sra/sra_sup')
setwd('/raid1/jiangjz/CTRDB_2/sra_finished')
#setwd('/raid/jiangjz/CTRDB_2/sra_finish')


gse <- list.files('.')

for(set in gse){ 
  #path <- file.path('/raid1/chenruzhen/sra/sra_befaft',set,'result')
  #path <- file.path('/raid1/chenruzhen/sra/ae',set,'result')
  #path <- file.path('/raid1/chenruzhen/sra/sra_acquire',set,'result')
  #path <- file.path('/raid1/chenruzhen/sra/sra_sup',set,'result')
  path <- file.path('/raid1/jiangjz/CTRDB_2/sra_finished', set, 'result')
  #path <- file.path('/raid/jiangjz/CTRDB_2/sra_finish', set, 'result')

  file <- list.files(path, full.names = T)
  merge <- read.csv(file.path('.',set,'merge.csv'), header = F)
  merge$V4 <- paste0(path, '/', merge$V1, '_counts.txt')

  merge_f <- filter(merge, V4 %in% file) 
  merge_f$size <- file.info(merge_f$V4)$size
  merge_f <- filter(merge_f, size!= 0)
  counts <- paste0(merge_f$V1, '_counts.txt') 
  name <- merge_f$V3

  c <- head(read.delim(file.path(path, counts[1]), header = F), -5)
  colnames(c) <- c('ENSEMBL', as.character(name[1]))
  c$ENSEMBL <- substr(c$ENSEMBL, 1, 15)
   
  for(i in seq(length(counts[-1]))){
    tmp <- counts[-1][i]
    size <- file.info(file.path(path, tmp))$size
    d <- head(read.delim(file.path(path, tmp), header = F), -5)
    colnames(d) <- c('ENSEMBL', as.character(name[-1][i]))
    d$ENSEMBL <- substr(d$ENSEMBL, 1, 15)
    
    c <- left_join(c, d, by = 'ENSEMBL')
  }
  
  df <- bitr(c$ENSEMBL, fromType = 'ENSEMBL', toType = 'SYMBOL', OrgDb = org.Hs.eg.db)
  c <- left_join(c, df, by='ENSEMBL')
  c <- c[,c(1,dim(c)[2],2:(dim(c)[2]-1))]
  
  c <- c[!duplicated(c$ENSEMBL),] # remove duplicated ensembl
  row.names(c) <- c$ENSEMBL
  
  write.csv(c, file = file.path('.', set, paste0(set,'_','counts.csv')), row.names = F)
  print(file.path('.', set, paste0(set,'_','counts.csv')))
}


