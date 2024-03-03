#!/bin/bash/
echo '##########  Convert sra 2 fastq ##########'
path=$1
RunDir=$2

cd $path/$RunDir
dirnames=$(ls -l | awk '/^d/ {print $NF}')

for dir in $dirnames
do
  echo $dir
  cd ./$dir/raw
  if [ $3 = 'new' ]; then
      ## parallel-fastq-dump 
      for sra_file in *.sra; do parallel-fastq-dump --sra $sra_file -t 60 --split-3; done
  elif [ $3 = 'old' ]; then
      ## fastq-dump
      readlink -f *.sra | parallel fasterq-dump -3 -e 10 {}
  fi

  cd $path 
done
