#!/bin/bash
#BSUB -J 3seq
#BSUB -n 8
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -u albertomaria.moro@gmail.com

source ~/.bashrc

WD='/data/lai/moroa/3Seq/fresh_start/'
INDEX='/data/lai/moroa/Genomes/Drosophila/flybase_dmel_r6.21/ht2_index/Dme'
PrMask='/data/lai/moroa/Genomes/Drosophila/flybase_dmel_r6.21/dm6.priming.9.16.bed'

mkdir $WD/mapped
mkdir $WD/mapped/trimmed
mkdir $WD/mapped/untrimmed
mkdir $WD/htsjdk_tmp
touch $WD/sample_name.txt

for DIR in $WD/*
do
IFS='/' read -r -a array <<< "$DIR"
name="${array[7]}"
cd $DIR/fastq
files=(*.gz)
cd $DIR
if (( ${#files[@]} > 1 ))
then 
hisat2 -p 8 -x $INDEX -U $DIR/fastq/${files[0]},$DIR/fastq/${files[1]} -S $WD/mapped/untrimmed/$name.sam --summary-file $WD/mapped/untrimmed/$name.txt
else
hisat2 -p 8 -x $INDEX -U $DIR/fastq/$files -S $WD/mapped/untrimmed/$name.sam --summary-file $WD/mapped/untrimmed/$name.txt
fi
samtools sort -l 7 -o $WD/mapped/untrimmed/$name.bam $WD/mapped/untrimmed/$name.sam
samtools index $WD/mapped/untrimmed/$name.bam
java -Xmx4g -jar $HOME/Script/Sol/TrimUnmapped.jar trim3p -bam $WD/mapped/untrimmed/$name.bam -out $WD/mapped/$name.unmapped.fastq
gzip $WD/mapped/$name.unmapped.fastq
hisat2 -p 8 -x $INDEX -U $WD/mapped/$name.unmapped.fastq.gz -S $WD/mapped/trimmed/$name.sam --summary-file $WD/mapped/trimmed/$name.txt
samtools sort -l 7 -o $WD/mapped/trimmed/$name.bam $WD/mapped/trimmed/$name.sam
samtools index $WD/mapped/trimmed/$name.bam
rm $WD/mapped/trimmed/$name.sam
rm $WD/mapped/untrimmed/$name.sam

echo $name >> $WD/sample_name.txt
done

java -Xmx4g -Djava.io.tmpdir=htsjdk_tmp -jar $HOME/Script/Sol/ThreeSeqPipeline.jar DefineClusters -minDistinctReads 3 -inDir mapped -trimmed trimmed -untrimmed untrimmed -primingMask $PrMask -outDir gtf -baseNames sample_name.txt

