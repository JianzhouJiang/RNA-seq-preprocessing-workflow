#!/bin/bash/
# input: 主路径；项目名称；下载方式（old、new）；解压方式（old、new）；是否下载文件（yes、no）
# 下载方式：old（下载sra文件再进行解压，生成fastq文件）；new（直接下载fastq.gz文件，进行解压） -> 推荐使用old，若old出错则使用new
# 解压方式：old（使用fastq-dump进行解压，并行生成fastq文件）；new（使用parallel-fastq-dump进行解压，逐个生成fastq文件） -> 推荐使用new，若出错则直接选择下载方式为new
# 下载文件：yes（运行下载程序，请检查下载程序后的文件完整性）；no（不运行下载程序，直接运行预处理脚本）

path=$1

if [ $5 = 'yes' ]; then
  if [ $3 = 'old' ]; then
    source $path/script/0_download_sra.sh $1 $2 $3
    source $path/script/1_convertsra2fastq.sh $1 $2 $4
    source $path/script/2_quality_control.sh $1 $2 
    source $path/script/3_first_alignment.sh $1 $2
    source $path/script/4_build_index.sh $1 $2
    source $path/script/5_second_alignment.sh $1 $2
    source $path/script/6_strand.sh $1 $2
    source $path/script/7_sort.sh $1 $2
    source $path/script/8_htseq_count.sh $1 $2
  elif [ $3 = 'new' ]; then
    source $path/script/0_download_sra.sh $1 $2 $3
    source $path/script/2_quality_control.sh $1 $2  
    source $path/script/3_first_alignment.sh $1 $2
    source $path/script/4_build_index.sh $1 $2
    source $path/script/5_second_alignment.sh $1 $2
    source $path/script/6_strand.sh $1 $2
    source $path/script/7_sort.sh $1 $2
    source $path/script/8_htseq_count.sh $1 $2
  fi
elif [ $5 = 'no' ] && [ $3 = 'old' ]; then
  source $path/script/1_convertsra2fastq.sh $1 $2 $4
  source $path/script/2_quality_control.sh $1 $2 
  source $path/script/3_first_alignment.sh $1 $2
  source $path/script/4_build_index.sh $1 $2
  source $path/script/5_second_alignment.sh $1 $2
  source $path/script/6_strand.sh $1 $2
  source $path/script/7_sort.sh $1 $2
  source $path/script/8_htseq_count.sh $1 $2
elif [ $5 = 'no' ] && [ $3 = 'new' ]; then
  source $path/script/2_quality_control.sh $1 $2
  source $path/script/3_first_alignment.sh $1 $2
  source $path/script/4_build_index.sh $1 $2
  source $path/script/5_second_alignment.sh $1 $2
  source $path/script/6_strand.sh $1 $2
  source $path/script/7_sort.sh $1 $2
  source $path/script/8_htseq_count.sh $1 $2
fi
