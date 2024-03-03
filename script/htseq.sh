#!/bin/bash/
name=$(echo $1 | grep -o 'SRR[0-9]*')  
htseq-count -f bam -r name -n 20 --quiet --stranded $2 --type exon --idattr gene_id --mode intersection-nonempty $1 $5/hg38/gencode.v22.annotation.gtf > $5/$4/$3/result/${name}_counts.txt
 
