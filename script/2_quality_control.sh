#!/bin/bash/
echo '########## Quality control ##########'
path=$1
RunDir=$2

cd $path/$RunDir
dirnames=$(ls -l | awk '/^d/ {print $NF}')

for dir in $dirnames
do
  echo $dir
  mkdir ./$dir/clean
  cat $path/$RunDir/$dir/merge.csv | awk -v FS=',' '{print $1,$2}' | parallel --trim lr -d ' ' echo | parallel -j 60 --max-args=2 source $path/script/qc_code.sh {1} {2} $dir $RunDir $path
done


