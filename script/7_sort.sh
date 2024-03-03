#!/bin/bash/ 
echo '########## Sort #########'
path=$1
RunDir=$2

cd $path/$RunDir
dirnames=$(ls -l | awk '/^d/ {print $NF}')
for dir in $dirnames
do
echo $dir
find $path/$RunDir/$dir/bam -name '*Aligned.out.bam' > ./$dir/bam.csv
num=$(cat $path/$RunDir/$dir/bam.csv | wc -l)
if [[ $num -gt 20 ]];then
	block=$(echo "$num/20+1" | bc) 
else
	block=1
fi

i=1
for i in $(seq $block) 
do
st=$(echo "($i-1)*20+1" | bc)
ed=$(echo "$i*20" | bc)
echo "block: $i"
cat $path/$RunDir/$dir/bam.csv | sed -n "${st},${ed}p" > ./$dir/bam_block_$i.csv 
cat $path/$RunDir/$dir/bam_block_$i.csv | parallel samtools sort -@ 8 -l 5 -o {}.sort {}
cat $path/$RunDir/$dir/bam_block_$i.csv | parallel samtools index {}.sort 
done
done
