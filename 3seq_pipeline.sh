#!/bin/bash
#BSUB -J 3seq
#BSUB -n 8
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -u albertomaria.moro@gmail.com

source ~/.bashrc

WD='/data/lai/moroa/3Seq_copy'
INDEX='/data/lai/moroa/Drosophila/ht2_index/Dme'
PrMask='/data/lai/moroa/Drosophila/dmel_r6.21_FB2018_02/dm6.priming.9.16.bed'

for DIR in $WD/*
do
IFS='/' read -r -a array <<< "$DIR"
name="${array[5]}"
if [ -e $DIR/$name.gtf/atlas.gtf ]
then echo "$name.gtf exist" 
else
mkdir $DIR/mapped
mkdir $DIR/mapped/trimmed
mkdir $DIR/mapped/untrimmed
mkdir $DIR/htsjdk_tmp
touch $DIR/sample_name.txt
touch $DIR/$name.results.txt

cd $DIR/fastq
files=(*.gz)
cd $DIR
if (( ${#files[@]} > 1 ))
then 
hisat2 -p 8 -x $INDEX -U $DIR/fastq/${files[0]},$DIR/fastq/${files[1]} -S $DIR/mapped/untrimmed/$name.sam --summary-file $DIR/mapped/untrimmed/$name.txt
else
hisat2 -p 8 -x $INDEX -U $DIR/fastq/$files -S $DIR/mapped/untrimmed/$name.sam --summary-file $DIR/mapped/untrimmed/$name.txt
fi
samtools sort -l 7 -o $DIR/mapped/untrimmed/$name.bam $DIR/mapped/untrimmed/$name.sam
samtools index $DIR/mapped/untrimmed/$name.bam
java -Xmx4g -jar $HOME/Script/Sol/TrimUnmapped.jar trim3p -bam $DIR/mapped/untrimmed/$name.bam -out $DIR/mapped/$name.unmapped.fastq
gzip $DIR/mapped/$name.unmapped.fastq
hisat2 -p 8 -x $INDEX -U $DIR/mapped/$name.unmapped.fastq.gz -S $DIR/mapped/trimmed/$name.sam --summary-file $DIR/mapped/trimmed/$name.txt
samtools sort -l 7 -o $DIR/mapped/trimmed/$name.bam $DIR/mapped/trimmed/$name.sam
samtools index $DIR/mapped/trimmed/$name.bam
rm $DIR/mapped/trimmed/$name.sam
rm $DIR/mapped/untrimmed/$name.sam

echo $name > $DIR/sample_name.txt
echo $files "->" $name > $DIR/$name.results.txt
echo "UNTIRMMED" > $DIR/$name.results.txt
cat $DIR/mapped/untrimmed/$name.txt >> $DIR/$name.results.txt
echo "TIRMMED" >> $DIR/$name.results.txt
cat $DIR/mapped/trimmed/$name.txt >> $DIR/$name.results.txt
printf $name\\t ; cat $DIR/$name.results.txt | tr [:blank:] \\t | sed '1,3d' | sed '6,7d' | tr -s "\\t" | awk '{print $1,$2}' | tr \\n \\t ; echo >> ../Results_alignment.tab

java -Xmx4g -Djava.io.tmpdir=htsjdk_tmp -jar $HOME/Script/Sol/ThreeSeqPipeline.jar DefineClusters -minDistinctReads 3 -inDir mapped -trimmed trimmed -untrimmed untrimmed -primingMask $PrMask -outDir $name.gtf -baseNames sample_name.txt
mv $name.gtf/atlas.gtf $name.gtf/$name.gtf
samtools merge $DIR/mapped/$name.bam $DIR/mapped/untrimmed/$name.bam $DIR/mapped/trimmed/$name.bam
samtools index $DIR/mapped/$name.bam

bamCoverage -b $DIR/mapped/$name.bam --normalizeUsing CPM --exactScaling -o $DIR/mapped/$name.bw
BAM=$DIR/mapped/*bam
cp $DIR/mapped/$name.bam /data/lai/moroa/igv_file/3seq/bam/
cp $DIR/mapped/$name.bam.bai /data/lai/moroa/igv_file/3seq/bam/
cp $DIR/mapped/$name.bw /data/lai/moroa/igv_file/3seq/bw/
cp $DIR/$name.gtf/$name.gtf /data/lai/moroa/igv_file/3seq/gtf/
echo "\t\t<Category name="'"'"$name"'"'">
\t\t\t<Resource name="'"'"$name".bam'"'" path="'"'"TOCHANGE/albertomaria/igv_file/3Seq/bam/"$name".bam"'"'"/>
\t\t\t<Resource name="'"'"$name".bw'"'" path="'"'"TOCHANGE/albertomaria/igv_file/3Seq/bw/"$name".bw"'"'"/>
\t\t\t<Resource name="'"'"$name".gtf'"'" path="'"'"TOCHANGE/albertomaria/igv_file/3Seq/gtf/"$name".gtf"'"'"/>
\t\t</Category>" >> /data/lai/moroa/igv_file/3seq/3seq_dataset.xml
fi
done
