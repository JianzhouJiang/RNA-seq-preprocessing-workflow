#!/bin/bash
echo '########## First alignment ##########'
path=$1
RunDir=$2

cd $path/$RunDir 
dirnames=$(ls -l | awk '/^d/ {print $NF}')
for dir in $dirnames
do
echo $dir
num=$(cat $path/$RunDir/$dir/merge.csv | wc -l)

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
cat $path/$RunDir/$dir/merge.csv | sed -n "${st},${ed}p" > $path/$RunDir/$dir/block_$i.csv  
cat $path/$RunDir/$dir/block_$i.csv | awk -v FS=',' '{print $1,$2}' | parallel --trim lr -d ' ' echo | parallel --max-args=2 source $path/script/star1_code.sh {1} {2} $dir $RunDir $path
done
done
