### 生成bam_link.csv


# 参数 ----------------------------------------------------------------------

## 输入参数
parameters = commandArgs(T)
path <- parameters[1]
RunDir <- parameters[2]
dir <- parameters[3]


# 生成bam_link --------------------------------------------------------------

srr_gsm <- read.table(paste0(path, '/', RunDir, '/', dir, '/SRR_GSM.txt'), header = F)
srr_gsm$V1 <- paste0(path, '/', RunDir, '/', dir, '/bam/', srr_gsm$V1, 'Aligned.out.bam')
result <- aggregate(V1 ~ V2, data = srr_gsm, paste, collapse = " ")

srr <- read.csv(paste0(path, '/', RunDir, '/', dir, '/rec2.csv'), header = F)
srr$V2 <- gsub(':.*', "", srr$V2)

result <- merge(result, srr, by = 'V2')
result <- result[,3:2]
result$V1.y <- paste0(path, '/', RunDir, '/', dir, '/new_bam/', result$V1.y, '.bam')

# 写出新文件 -------------------------------------------------------------------

write.table(result, file = paste0(path, '/', RunDir, '/', dir, '/bam_link.txt'), row.names = F, col.names = F, quote = F,sep = ' ')



