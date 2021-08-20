#!/bin/bash
#BSUB -J STAR
#BSUB -n 5
#BSUB -R rusage[mem=8]
#BSUB -W 96:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -u albertomaria.moro@gmail.com

params_miR=' --runThreadN 16
--readFilesCommand zcat
--outFilterMismatchNmax 1
--outFilterMultimapScoreRange 0
--quantMode TranscriptomeSAM GeneCounts
--outReadsUnmapped Fastx
--outSAMtype BAM SortedByCoordinate
--outFilterMultimapNmax 10
--outSAMunmapped Within
--outFilterScoreMinOverLread 0
--outFilterMatchNminOverLread 0
--outFilterMatchNmin 16
--alignSJDBoverhangMin 1000
--alignIntronMax 1
--outWigType wiggle
--outWigStrand Stranded
--outWigNorm RPM
'

params=' --runThreadN 16
--readFilesCommand zcat
--quantMode TranscriptomeSAM GeneCounts
--outReadsUnmapped Fastx
--outSAMtype BAM SortedByCoordinate
--outFilterType BySJout
--outFilterMultimapNmax 20
--alignSJoverhangMin 8
--alignSJDBoverhangMin 1
--outFilterMismatchNmax 999
--outFilterMismatchNoverReadLmax 0.05
--alignIntronMin 20
--alignIntronMax 1000000
--alignMatesGapMax 1000000
--outWigType bedGraph read1_5p
--outWigStrand Stranded
--outWigNorm RPM
'

#STAR-2.6.0a/bin/Linux_x86_64/STAR --genomeDir ~/Drosophila/STAR_index/ --readFilesIn ~/ELAV-data/Sample_PIERO-1-AR001/fastq/PIERO-1-AR001_ATCACG-_BC9EN2ANXX_L007_001.R1.fastq.gz ~/ELAV-data/Sample_PIERO-1-AR001/fastq/PIERO-1-AR001_ATCACG-_BC9EN2ANXX_L007_001.R2.fastq.gz $params --outFileNamePrefix ~/ELAV-data/Sample_PIERO-1-AR001/STAR/PIERO-1-AR001_.STAR. --sjdbGTFfile ~/Drosophila/Drosophila_melanogaster.BDGP6.92.gtf

#~/STAR-2.6.0a/bin/Linux_x86_64/STAR --genomeDir ~/Drosophila/STAR_index/ --readFilesIn ~/ELAV-data/Sample_PIERO-1-AR001/fastq/PIERO-1-AR001_ATCACG-_BC9EN2ANXX_L007_001.R1.fastq.gz ~/ELAV-data/Sample_PIERO-1-AR001/fastq/PIERO-1-AR001_ATCACG-_BC9EN2ANXX_L007_001.R2.fastq.gz $params --outFileNamePrefix ~/ELAV-data/Sample_PIERO-1-AR001/STAR/ --sjdbGTFfile ~/Drosophila/Drosophila_melanogaster.BDGP6.92.gtf

source ./.bashrc

for dir in /data/lai/moroa/RNA-seq/Sample_3X-cyt-chrom-*
do DIR=$dir/STAR
if [ -d "$DIR" ] 
then echo "$DIR exists." 
else mkdir $dir/STAR
cd $dir/fastq
files=(*.gz)
STAR --genomeDir /data/lai/moroa/Drosophila/STAR_index/ --readFilesIn ${files[0]} ${files[1]} $params --outFileNamePrefix $dir/STAR/${files[0]/_BHNWNLBCXY_L002_001.R1.fastq.gz/.STAR.} --sjdbGTFfile /data/lai/moroa/Drosophila/dmel_r6.21_FB2018_02/gtf/dmel-all-r6.21.gtf
cd ~
fi
done

for dir in /data/lai/moroa/RNA-seq/Sample_ERF-Hu-WT-*
do DIR=$dir/STAR
if [ -d "$DIR" ] 
then echo "$DIR exists." 
else mkdir $dir/STAR
cd $dir/fastq
files=(*.gz)
STAR --genomeDir /data/lai/moroa/Drosophila/STAR_index/ --readFilesIn ${files[0]} ${files[1]} $params --outFileNamePrefix $dir/STAR/${files[0]/_BHNWNLBCXY_L001_001.R1.fastq.gz/.STAR.} --sjdbGTFfile /data/lai/moroa/Drosophila/dmel_r6.21_FB2018_02/gtf/dmel-all-r6.21.gtf
cd ~
fi
done
