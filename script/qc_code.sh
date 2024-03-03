#!/bin/bash
cd $5/$4/$3/raw/
if [[ $2 = 'SINGLE' ]]; then
trim_galore -q 20 --phred33 --length 20 --stringency 3 -o $5/$4/$3/clean $1.fastq > $5/$4/$3/log/${1}_fastq_trimming.log 2>&1 
elif [[ $2 = 'PAIRED' ]]; then
trim_galore -q 20 --phred33 --length 20 --stringency 3 --paired -o $5/$4/$3/clean ${1}_1.fastq ${1}_2.fastq > $5/$4/$3/log/${1}_fastq_trimming.log 2>&1 
fi
