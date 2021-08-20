#!/bin/bash
#BSUB -J fastQC
#BSUB -n 8
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -N
#BSUB -u albertomaria.moro@gmail.com

source ~/.bashrc
#WD='/data/lai/moroa/RNA-seq'
WD='/data/lai/moroa/3Seq'


for DIR in $WD/*
do
IFS='/' read -r -a array <<< "$DIR"
name="${array[5]}"
if [ $name == "METADATA" ]
then
echo "questo é METADATA"
elif [ -e $WD/METADATA/fastQC/$name\_QC.tar.gz ]
then
echo "$name already QC"
else
mkdir $WD/METADATA/temp/$name\_QC
cd $DIR/fastq
files=(*.gz)
for file in "${files[@]}"
do
fastqc $file -o $WD/METADATA/temp/$name\_QC
done
cd $WD/METADATA/temp
tar -czf $WD/METADATA/fastQC/$name\_QC.tar.gz $name\_QC
rm -r $WD/METADATA/temp/$name\_QC
fi
done
