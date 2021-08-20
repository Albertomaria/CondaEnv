#!/bin/bash
#BSUB -J HiSat2
#BSUB -n 8
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -N
#BSUB -u albertomaria.moro@gmail.com

source ./.bashrc

for dir in /data/lai/moroa/RNA-seq/Sample_3X-cyt-chrom-*
do
cd $dir/fastq
files=(*.gz)
SAM=$dir/${files[0]/_BHNWNLBCXY_L002_001.R1.fastq.gz/.sam}
BAM=$dir/${files[0]/_BHNWNLBCXY_L002_001.R1.fastq.gz/.bam}
UN=$dir/${files[0]/_BHNWNLBCXY_L002_001.R1.fastq.gz/_unmapped}
#hisat2 -p 8 -x /data/lai/moroa/Drosophila/ht2_index/Dme -1 $dir/fastq/${files[0]} -2 $dir/fastq/${files[1]} -S $SAM
#samtools sort -@ 8 -l 7 -o $BAM $SAM
#samtools index $BAM
#rm $SAM
samtools view -f4 $BAM > $UN.sam
cut -f1 $UN.sam | sort | uniq > $UN.lst
seqtk subseq $dir/fastq/${files[0]} $UN.lst > $UN.fastq
rm $UN.sam
rm $UN.lst
cd ~
done

for dir in /data/lai/moroa/RNA-seq/Sample_ERF-Hu-WT-*
do
cd $dir/fastq
SAM=$dir/${files[0]/_BHNWNLBCXY_L001_001.R1.fastq.gz/.sam}
BAM=$dir/${files[0]/_BHNWNLBCXY_L001_001.R1.fastq.gz/.bam}
UN=$dir/${files[0]/_BHNWNLBCXY_L001_001.R1.fastq.gz/_unmapped}
files=(*.gz)
#hisat2 -p 8 -x /data/lai/moroa/Drosophila/ht2_index/Dme -1 $dir/fastq/${files[0]} -2 $dir/fastq/${files[1]} -S $SAM
#samtools sort -@ 8 -l 7 -o $BAM $SAM
#samtools index $BAM
#rm $SAM
samtools view -f4 $BAM > $UN.sam
cut -f1 $UN.sam | sort | uniq > $UN.lst
seqtk subseq $dir/fastq/${files[0]} $UN.lst > $UN.fastq
rm $UN.sam
rm $UN.lst
cd ~
done

#Rscript ~/Script/FeatureCounts.R
