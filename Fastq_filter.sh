#!/bin/bash
#BSUB -J CLIP
#BSUB -n 8
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -u albertomaria.moro@gmail.com

source ~/.bashrc

INDEX='/data/lai/moroa/Drosophila/ht2_index/Dme'

index1=(ATCG GCTA CGAT TAGC GACT TCGA);
samples1=(ElavWT_ElavAb_rep1 Elav3X_ElavAb ElavWT_FlagAb Elav3X_FlagAb FneWT_FlagAb Fne3X_FlagAb);
mkdir /data/lai/moroa/CLIP/ERF1_R1
mkdir /data/lai/moroa/CLIP/ERF1_R1/results

samples2=(Rbp9WT_FlagAb Rbp93X_FlagAb ElavWT_FlagAb_wholefly ElavWT_ElavAb_rep2 ElavWT_ElavAb_rep3)
index2=(CTAG GATC TCGA ATCG GCTA)
mkdir /data/lai/moroa/CLIP/ERF2_R1
mkdir /data/lai/moroa/CLIP/ERF2_R1/results

for ((i=0;i<=5;i=i+1)); do
idx1=${index1[$i]}
name1=${samples1[$i]}
#perl /data/lai/moroa/Programs/ctk-master/fastq_filter.pl -v -if sanger -index 7:$idx1 -of fastq -f mean:0-38:20 /data/lai/moroa/CLIP/ERF1_R1.fastq - | gzip -c > /data/lai/moroa/CLIP/ERF1_R1/$name1.fastq.gz
#zcat /data/lai/moroa/CLIP/ERF1_R1/$name1.fastq.gz | fastx_clipper -a GTGTCAGTCACTTCCAGCGGCAGGA -l 29 -n | fastq_quality_trimmer -t 5 -l 29 -z -o /data/lai/moroa/CLIP/ERF1_R1/$name1.trim.fastq.gz
#perl /data/lai/moroa/Programs/ctk-master/fastq2collapse.pl /data/lai/moroa/CLIP/ERF1_R1/$name1.trim.fastq.gz - | gzip -c > /data/lai/moroa/CLIP/ERF1_R1/$name1.trim.c.fastq.gz
#perl /data/lai/moroa/Programs/ctk-master/stripBarcode.pl -format fastq -len 12 /data/lai/moroa/CLIP/ERF1_R1/$name1.trim.c.fastq.gz - | gzip -c > /data/lai/moroa/CLIP/ERF1_R1/$name1.trim.c.tag.fastq.gz
#SAM1=/data/lai/moroa/CLIP/ERF1_R1/results/$name1.sam
#BAM1=/data/lai/moroa/CLIP/ERF1_R1/results/$name1.bam
#hisat2 -p 8 -x $INDEX -U /data/lai/moroa/CLIP/ERF1_R1/$name1.trim.c.tag.fastq.gz -S $SAM1 --un-conc /data/lai/moroa/CLIP/ERF1_R1/results/ --new-summary
#samtools sort -@ 8 -l 7 -o $BAM1 $SAM1
#samtools index $BAM1
#rm $SAM1
bwa aln -t 4 -n 0.06 -q 20 /data/lai/moroa/Drosophila/bwa/Dme_bwa.fasta /data/lai/moroa/CLIP/ERF1_R1/$name1.trim.c.tag.fastq.gz | bwa samse /data/lai/moroa/Drosophila/bwa/Dme_bwa.fasta /data/lai/moroa/CLIP/ERF1_R1/$name1.trim.c.tag.fastq.gz | gzip -c > /data/lai/moroa/CLIP/ERF1_R1/$name1.trim.c.tag.sam.gz
idx2=${index2[$i]}
name2=${samples2[$i]}
#perl /data/lai/moroa/Programs/ctk-master/fastq_filter.pl -v -if sanger -index 7:$idx2 -of fastq -f mean:0-38:20 /data/lai/moroa/CLIP/ERF2_R1.fastq - | gzip -c > /data/lai/moroa/CLIP/ERF2_R1/$name2.fastq.gz
#zcat /data/lai/moroa/CLIP/ERF2_R1/$name2.fastq.gz | fastx_clipper -a GTGTCAGTCACTTCCAGCGGCAGGA -l 29 -n | fastq_quality_trimmer -t 5 -l 29 -z -o /data/lai/moroa/CLIP/ERF2_R1/$name2.trim.fastq.gz
#perl /data/lai/moroa/Programs/ctk-master/fastq2collapse.pl /data/lai/moroa/CLIP/ERF2_R1/$name2.trim.fastq.gz - | gzip -c > /data/lai/moroa/CLIP/ERF2_R1/$name2.trim.c.fastq.gz
#perl /data/lai/moroa/Programs/ctk-master/stripBarcode.pl -format fastq -len 12 /data/lai/moroa/CLIP/ERF2_R1/$name2.trim.c.fastq.gz - | gzip -c > /data/lai/moroa/CLIP/ERF2_R1/$name2.trim.c.tag.fastq.gz
#SAM2=/data/lai/moroa/CLIP/ERF2_R1/results/$name2.sam
#BAM2=/data/lai/moroa/CLIP/ERF2_R1/results/$name2.bam
#hisat2 -p 8 -x $INDEX -U /data/lai/moroa/CLIP/ERF2_R1/$name2.trim.c.tag.fastq.gz -S $SAM2 --new-summary
#samtools sort -@ 8 -l 7 -o $BAM2 $SAM2
#samtools index $BAM2
#rm $SAM2
done
