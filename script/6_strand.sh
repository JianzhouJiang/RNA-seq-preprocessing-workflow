#!/bin/bash/
echo '########## Strand type ##########'
path=$1
RunDir=$2

cd $path/$RunDir 
dirnames=$(ls -l | awk '/^d/ {print $NF}')
for dir in $dirnames
do
echo $dir
bam=($(find $path/$RunDir/$dir/bam -name '*Aligned.out.bam' -size +0k))

infer_experiment.py -r $path/hg38/gencode.v22.annotation.bed -i ${bam[0]} > $path/$RunDir/$dir/log/strand.log 

n=($(cat $path/$RunDir/$dir/log/strand.log | sed -n '5,$p' | awk -F ': ' '{print $2}'))
a=$(echo "scale=2; ${n[0]}/2" | bc)
b=$(echo "scale=2; ${n[1]}/2" | bc)

yes=$(echo "$a > ${n[1]}" | bc)
reverse=$(echo "$b > ${n[0]}" | bc)

if [[ $yes -eq 1 ]];then
echo 'yes' > $path/$RunDir/$dir/strand.txt
elif [[ $reverse -eq 1 ]];then
echo 'reverse' > $path/$RunDir/$dir/strand.txt
else
echo 'no' > $path/$RunDir/$dir/strand.txt
fi

done
