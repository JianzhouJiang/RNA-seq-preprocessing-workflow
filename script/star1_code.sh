#!/bin/bash/
cd $5/$4/$3/clean

#echo '### comparison reads ###'
if [[ $2 = 'SINGLE' ]]; then
STAR --genomeDir $5/$4/$3/hg38/star --readFilesIn ${1}_trimmed.fq --runThreadN 20 --outFilterMultimapScoreRange 1 --outFilterMultimapNmax 20 --outFilterMismatchNmax 10 --alignIntronMax 500000 --alignMatesGapMax 1000000 --sjdbScore 2 --alignSJDBoverhangMin 1 --genomeLoad NoSharedMemory --outFilterMatchNminOverLread 0.33 --outFilterScoreMinOverLread 0.33 --sjdbOverhang 100 --outSAMstrandField intronMotif --outSAMtype None --outSAMmode None --outFileNamePrefix ${1} > $5/$4/$3/log/${1}_star.log 2>&1 
elif [[ $2 = 'PAIRED' ]]; then
STAR --genomeDir $5/$4/$3/hg38/star --readFilesIn ${1}_1_val_1.fq ${1}_2_val_2.fq --runThreadN 20 --outFilterMultimapScoreRange 1 --outFilterMultimapNmax 20 --outFilterMismatchNmax 10 --alignIntronMax 500000 --alignMatesGapMax 1000000 --sjdbScore 2 --alignSJDBoverhangMin 1 --genomeLoad NoSharedMemory --outFilterMatchNminOverLread 0.33 --outFilterScoreMinOverLread 0.33 --sjdbOverhang 100 --outSAMstrandField intronMotif --outSAMtype None --outSAMmode None --outFileNamePrefix ${1} > $5/$4/$3/log/${1}_star.log 2>&1 
fi
