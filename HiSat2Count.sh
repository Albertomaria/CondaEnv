#!/bin/bash
#BSUB -J HiSat2Count
#BSUB -n 8
#BSUB -R span[ptile=4]
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -B
#BSUB -u moroa@mskcc.org
#BSUB -L /bin/bash


source ~/.bashrc

WD='/data/lai/moroa/ELAV-data/'
INDEX='/data/lai/moroa/Drosophila/ht2_index/Dme'
GTF='/data/lai/moroa/Drosophila/dmel_r6.21_FB2018_02/gtf/dmel-all-r6.21.gtf'

for DIR in $WD/*
do
mkdir $DIR/results
cd $DIR/fastq
files=(*.gz)
SAM=$DIR/results/${files[0]/-_BC9EN2ANXX_L007_001.R1.fastq.gz/.sam}
BAM=$DIR/results/${files[0]/-_BC9EN2ANXX_L007_001.R1.fastq.gz/.bam}
TAB=$DIR/results/${files[0]/-_BC9EN2ANXX_L007_001.R1.fastq.gz/.tab}
hisat2 -p 8 -x $INDEX -1 $DIR/fastq/${files[0]} -2 $DIR/fastq/${files[1]} -S $SAM --un-conc $DIR/results --new-summary
samtools sort -@ 8 -l 7 -o $BAM $SAM
samtools index $BAM
rm $SAM
#htseq-count -f bam -r pos -t exon -i gene_id -a 5 $BAM $GTF > $TAB
done
