#!/bin/bash/
echo '########## Build new index ##########'
path=$1
RunDir=$2

cd $path/$RunDir
dirnames=$(ls -l | awk '/^d/ {print $NF}')
for dir in $dirnames
do 
echo $dir
cd ./$dir/clean
STAR --runMode genomeGenerate --genomeDir $path/$RunDir/$dir/hg38/star/ --genomeFastaFiles $path/hg38/GRCh38.d1.vd1.fa --sjdbOverhang 100 --limitSjdbInsertNsj 5000000 --runThreadN 100 --sjdbFileChrStartEnd *SJ.out.tab > $path/$RunDir/$dir/log/index.log 2>&1 
cd $path/$RunDir
done
