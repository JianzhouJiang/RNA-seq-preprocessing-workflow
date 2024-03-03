#!/bin/bash
## Paralel download the sra files 
cat $1/$2/$3/SRR.txt | parallel prefetch {} -O $1/$2/$3/raw

## Download the sra files in turn
#cat $1/$2/$3/SRR.txt | while read srr
#do
#echo $srr
#prefetch $srr -O $1/$2/$3/raw/
#done

## Remove downloaded reference files
for dir in $1/$2/SRR*/; do
  if [ -d "$dir" ]; then    
        echo "Deleting directory: $dir"  
        rm -rf "$dir"  
    fi  
done  
  
## Check SRR directory 
cd $1/$2/$3/raw
find ./SRR* -mindepth 1 -type f -exec mv -t . {} +
find . -mindepth 1 -type d -exec rm -rf {} +
