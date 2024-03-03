#!/bin/bash
path=$1
RunDir=$2

cat /$path/GSE_PRJNA.csv | while read id 
do 
  gse=$(echo $id | awk -v FS=',' '{print $1}')
  prj=$(echo $id | awk -v FS=',' '{print $2}')
  mkdir $path/$RunDir/$gse
  echo $gse

  echo 'download info'
  esearch -db sra -query $prj < /dev/null | efetch -format runinfo > $path/$RunDir/$gse/info.txt

  echo 'download xml' 
  esearch -db sra -query $prj < /dev/null | efetch -format docsum > $path/$RunDir/$gse/xml.txt 

  echo 'build merge'
  cat $path/$RunDir/$gse/info.txt | cut -d, -f1,16 | awk -v FS=',' -v OFS="," '{print $1,$2}' | sed -n '2,$p' | sort -t ',' -k 1 > $path/$RunDir/$gse/rec1.csv
  cat $path/$RunDir/$gse/xml.txt | xtract -pattern DocumentSummary -element Title,Run@acc |  awk -v FS='\t' -v OFS="," '{print $2,$1}' | sort -t ',' -k 1 > $path/$RunDir/$gse/rec2.csv
  join -t ',' -j 1 $path/$RunDir/$gse/rec1.csv $path/$RunDir/$gse/rec2.csv  | sed 's/:.*//g' > $path/$RunDir/$gse/merge.csv 
  cat $path/$RunDir/$gse/merge.csv | awk -v FS=',' '{print $1}' > $path/$RunDir/$gse/SRR.txt

  mkdir $path/$RunDir/$gse/raw
  if [ $3 = 'old' ]; then
      source $path/script/download.sh $path $RunDir $gse
  elif [ $3 = 'new' ]; then
      source $path/script/download_wget.sh $path $RunDir $gse
  fi
 
  mkdir $path/$RunDir/$gse/log
  mkdir $path/$RunDir/$gse/hg38 && mkdir $path/$RunDir/$gse/hg38/star
  find $path/hg38/star | parallel cp {} $path/$RunDir/$gse/hg38/star

done
