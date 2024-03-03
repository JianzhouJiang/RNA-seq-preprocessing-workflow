#!/bin/bash/
echo '##########  merge & sort & count ##########'
path=$1
RunDir=$2

cd $path/$RunDir
dirnames=$(ls -l | awk '/^d/ {print $NF}')

# merge bam files
for dir in $dirnames; do
  echo $dir
  mkdir $path/$RunDir/$dir/new_bam
  find $path/$RunDir/$dir/bam -name '*Aligned.out.bam' | sort > $path/$RunDir/$dir/bam.csv
  cat $path/$RunDir/$dir/bam.csv | sed 's#.*/\([^A]*\)[^/]*$#\1#' > $path/$RunDir/$dir/SRR_new.csv  # 保留通过质控和比对的SRR号
  awk -F',' 'NR==FNR{a[$1]=$3;next} ($1 in a) {print $1, a[$1]}' $path/$RunDir/$dir/merge.csv $path/$RunDir/$dir/SRR_new.csv > $path/$RunDir/$dir/SRR_GSM.txt
  cat $path/$RunDir/$dir/SRR_GSM.txt | awk -v FS=' ' '{print $2}' | uniq > $path/$RunDir/$dir/GSM.txt
  Rscript $path/script/BamLink.R $path $RunDir $dir

  num=$(cat $path/$RunDir/$dir/bam_link.txt | wc -l)
  echo "Number of merging: $num"
  count=0
  cat $path/$RunDir/$dir/bam_link.txt | while read mg
  do
      echo $mg | xargs samtools merge -@ 80
      ((count++))
      echo "Merge completed is $count"
  done
  echo "Completion of merger"
done

# sort bam files
for dir in $dirnames; do
  echo $dir
  find $path/$RunDir/$dir/new_bam -name '*.bam' | sort > $path/$RunDir/$dir/new_bam.csv
  num=$(cat $path/$RunDir/$dir/new_bam.csv | wc -l)
  if [[ $num -gt 20 ]];then
	  block=$(echo "$num/20+1" | bc) 
  else
	  block=1
  fi

  i=1
  for i in $(seq $block); do
      st=$(echo "($i-1)*20+1" | bc)
      ed=$(echo "$i*20" | bc)
      echo "block: $i"
      cat $path/$RunDir/$dir/new_bam.csv | sed -n "${st},${ed}p" > ./$dir/bam_block_$i.csv 
      cat $path/$RunDir/$dir/bam_block_$i.csv | parallel samtools sort -@ 8 -l 5 -o {}.sort {}
      cat $path/$RunDir/$dir/bam_block_$i.csv | parallel samtools index -@ 8 {}.sort 
    done
done

# count sort files
for dir in $dirnames; do
  echo $dir
  mkdir $path/$RunDir/$dir/result
  s=$(sed -n '1p' $path/$RunDir/$dir/strand.txt) 
  num=$(cat $path/$RunDir/$dir/new_bam.csv | wc -l)
  if [[ $num -gt 40 ]];then
	  block=$(echo "$num/40+1" | bc) 
  else
	  block=1
  fi

  i=1
  for i in $(seq $block); do
      st=$(echo "($i-1)*40+1" | bc)
      ed=$(echo "$i*40" | bc)
      echo "block: $i"
      cat $path/$RunDir/$dir/new_bam.csv | sed -n "${st},${ed}p" > ./$dir/count_block_$i.csv 
      cat $path/$RunDir/$dir/count_block_$i.csv | parallel source $path/script/htseq.sh {}.sort $s $dir $RunDir $path
    done
done
