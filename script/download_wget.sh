#!/bin/bash
echo '####### download fastq by wget #######'
path=$1
RunDir=$2
gse=$3

# create link file
mkdir $path/$RunDir/$gse/raw/log
cat $path/$RunDir/$gse/merge.csv | while read id
do
  srr=$(echo $id | awk -v FS=',' '{print $1}')
  num=$(echo $id | awk -v FS=',' '{print $1}' | wc -m)
  type=$(echo $id | awk -v FS=',' '{print $2}')
  if [ $type = 'PAIRED' ]; then
      srr_n1=$(echo $srr | sed 's/$/_1.fastq.gz/')
      srr_n2=$(echo $srr | sed 's/$/_2.fastq.gz/')
      if [ $num -eq 12 ]; then
          x=$(echo $srr | cut -b 1-6)
          y=$(echo $srr | cut -b 10-11)
          echo "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$x/0$y/$srr/$srr_n1" >> $path/$RunDir/$gse/SRR_link.txt
          echo "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$x/0$y/$srr/$srr_n2" >> $path/$RunDir/$gse/SRR_link.txt
      elif [ $num -eq 11 ]; then
          x=$(echo $srr | cut -b 1-6)
          y=$(echo $srr | cut -b 10-10)
          echo "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$x/00$y/$srr/$srr_n1" >> $path/$RunDir/$gse/SRR_link.txt
          echo "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$x/00$y/$srr/$srr_n2" >> $path/$RunDir/$gse/SRR_link.txt
      elif [ $num -eq 10 ]; then
          x=$(echo $srr | cut -b 1-6)
          echo "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$x/$srr/$srr_n1" >> $path/$RunDir/$gse/SRR_link.txt
          echo "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$x/$srr/$srr_n2" >> $path/$RunDir/$gse/SRR_link.txt
      fi
  elif [ $type = 'SINGLE' ]; then
      srr_n=$(echo $srr | sed 's/$/.fastq.gz/')
      if [ $num -eq 12 ]; then
          x=$(echo $srr | cut -b 1-6)
          y=$(echo $srr | cut -b 10-11)
          echo "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$x/0$y/$srr/$srr_n" >> $path/$RunDir/$gse/SRR_link.txt
      elif [ $num -eq 11 ]; then
          x=$(echo $srr | cut -b 1-6)
          y=$(echo $srr | cut -b 10-10)
          echo "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$x/00$y/$srr/$srr_n" >> $path/$RunDir/$gse/SRR_link.txt
      elif [ $num -eq 10 ]; then
          x=$(echo $srr | cut -b 1-6)
          echo "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$x/$srr/$srr_n" >> $path/$RunDir/$gse/SRR_link.txt
      fi
  fi
done

# download link by wget
cd $path/$RunDir/$gse/raw
wget -nc -t 0 -T 60 -c -i $path/$RunDir/$gse/SRR_link.txt

# check and re-download
echo "### Check fastq.gz for the first time ###"
cd $path/$RunDir/$gse/raw
find *.gz | parallel -j 20 pigz -p 30 -t {} 2>&1 | tee ./log/download_check_1.log
rev ./log/download_check_1.log | awk '{print $1}' | rev > $path/$RunDir/$gse/SRR_part.txt
comm -23 <(find *.gz | sort) <(awk -F'/' '{print $NF}' $path/$RunDir/$gse/SRR_link.txt | sort) >> $path/$RunDir/$gse/SRR_part.txt
cat $path/$RunDir/$gse/SRR_part.txt | parallel rm -rf {}

if [ $(wc -c < $path/$RunDir/$gse/SRR_part.txt) -gt $((0 * $(wc -c < $path/$RunDir/$gse/SRR_part.txt))) ]; then
  cat $path/$RunDir/$gse/SRR_part.txt | while read id
  do
    srr=$(echo $id | awk -F_ '{print $1}')
    num=$(echo $id | awk -F_ '{print $1}' | wc -m)
    if [ $num -eq 12 ]; then
      x=$(echo $srr | cut -b 1-6)
      y=$(echo $srr | cut -b 10-11)
      echo "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$x/0$y/$srr/$id" >> $path/$RunDir/$gse/SRR_redownload.txt
    elif [ $num -eq 11 ]; then
      x=$(echo $srr | cut -b 1-6)
      y=$(echo $srr | cut -b 10-10)
      echo "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$x/00$y/$srr/$id" >> $path/$RunDir/$gse/SRR_redownload.txt
    elif [ $num -eq 10 ]; then
      x=$(echo $srr | cut -b 1-6)
      echo "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$x/$srr/$id" >> $path/$RunDir/$gse/SRR_redownload.txt
    fi
  done
  wget -nc -t 0 -T 60 -c -i $path/$RunDir/$gse/SRR_redownload.txt
  
  # check twice
  echo "### Check fastq.gz for the second time ###"
  cd $path/$RunDir$gse/raw
  find *.gz | parallel -j 20 pigz -p 30 -t {} 2>&1 | tee ./log/download_check_2.log
  rev ./log/download_check_2.log | awk '{print $1}' | rev > $path/$RunDir/$gse/SRR_manual.txt
  comm -23 <(find *.gz | sort) <(awk -F'/' '{print $NF}' $path/$RunDir/$gse/SRR_link.txt | sort) >> $path/$RunDir/$gse/SRR_manual.txt
fi

# uncompress
echo '### uncompress fastq files ###'
find *.gz | parallel -j 20 pigz -p 50 -d {}
echo '### uncompression complete ###'
