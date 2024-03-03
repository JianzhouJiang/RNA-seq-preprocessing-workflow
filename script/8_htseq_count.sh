#!/bin/bash/
echo '########## htseq-count #########'
path=$1
RunDir=$2

cd $path/$RunDir
dirnames=$(ls -l | awk '/^d/ {print $NF}')
for dir in $dirnames
do
echo $dir
mkdir ./$dir/result
s=$(sed -n '1p' ./$dir/strand.txt) 
num=$(cat $path/$RunDir/$dir/bam.csv | wc -l)
if [[ $num -gt 40 ]];then
	block=$(echo "$num/40+1" | bc) 
else
	block=1
fi

i=1
for i in $(seq $block) 
do
st=$(echo "($i-1)*40+1" | bc)
ed=$(echo "$i*40" | bc)
echo "block: $i"
cat $path/$RunDir/$dir/bam.csv | sed -n "${st},${ed}p" > ./$dir/sort_block_$i.csv 
cat $path/$RunDir/$dir/sort_block_$i.csv | parallel source $path/script/htseq.sh {}.sort $s $dir $RunDir $path
done
done
