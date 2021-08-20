#!/bin/bash
#BSUB -J CLIP
#BSUB -n 8
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -N
#BSUB -u albertomaria.moro@gmail.com

source ~/.bashrc

#for ((i=0;i<=10;i=i+1)); do
#perl /data/lai/moroa/Program/ctk-master/fastq_filter.pl -v -if sanger -index $i:ATCG -of fastq /data/lai/moroa/CLIP/ERF1_R1.fastq - | gzip -c > test_$i.fastq.gz
#done

#mkdir /data/lai/moroa/CLIP/pipeline

WD='/data/lai/moroa/CLIP/pipeline'
Program='/data/lai/moroa/Program/ctk-master'
FASTA='/data/lai/moroa/Drosophila/ucsc/bwa-index/bwa-dm6.fasta'

touch $WD/results_CLIP.txt

#index1=(ATCG GCTA CGAT TAGC GACT TCGA)
#samples1=(ElavWT_ElavAb_rep1 Elav3X_ElavAb ElavWT_FlagAb Elav3X_FlagAb FneWT_FlagAb Fne3X_FlagAb)

#for ((i=0;i<=6;i=i+1)); do
#idx=${index1[$i]}
#name=${samples1[$i]}
#perl $Program/fastq_filter.pl -v -if sanger -index 0:$idx -f mean:0-38:20 -of fastq /data/lai/moroa/CLIP/ERF1_R1.fastq - | gzip -c > $WD/$name.fastq.gz
#done

#index2=(CTAG GATC TCGA ATCG GCTA)
#samples2=(Rbp9WT_FlagAb Rbp93X_FlagAb ElavWT_FlagAb_wholefly ElavWT_ElavAb_rep2 ElavWT_ElavAb_rep3)

#for ((i=0;i<=5;i=i+1)); do 
#idx=${index2[$i]}
#name=${samples2[$i]}
#perl $Program/fastq_filter.pl -v -if sanger -index 7:$idx -f mean:0-38:20 -of fastq /data/lai/moroa/CLIP/ERF2_R1.fastq - | gzip -c > $WD/$name.fastq.gz 
#done

#mkdir $WD/results

#for file in $WD/*.gz; do
#IFS='/' read -r -a array <<< "$file"
#long="${array[6]}"
#IFS='.' read -r -a array <<< "$long"
#name="${array[0]}"
#zcat $file | fastx_clipper -a GTGTCAGTCACTTCCAGCGGCAGGA -l 29 -n | fastq_quality_trimmer -t 5 -l 29 -z -o $WD/$name.trim.fastq.gz
#perl $Program/fastq2collapse.pl $WD/$name.trim.fastq.gz - | gzip -c > $WD/$name.trim.c.fastq.gz
#perl $Program/stripBarcode.pl -format fastq -len 12 $WD/$name.trim.c.fastq.gz - | gzip -c > $WD/$name.trim.c.s.tag.fastq.gz
##SAM1=/data/lai/moroa/CLIP/ERF1_R1/results/$name1.sam
##BAM1=/data/lai/moroa/CLIP/ERF1_R1/results/$name1.bam
##hisat2 -p 8 -x $INDEX -U /data/lai/moroa/CLIP/ERF1_R1/$name1.trim.c.tag.fastq.gz -S $SAM1 --un-conc /data/lai/moroa/CLIP/ERF1_R1/results/ --new-summary
##samtools sort -@ 8 -l 7 -o $BAM1 $SAM1
##samtools index $BAM1
##rm $SAM1
#bwa aln -t 4 -n 0.06 -q 20 $FASTA $WD/$name.trim.c.s.tag.fastq.gz > $WD/results/$name.sai
#bwa samse $FASTA $WD/results/$name.sai $WD/$name.trim.c.s.tag.fastq.gz > $WD/results/$name.sam
#done

#cd $WD/results
#for file in ./*.sam; do 
#samtools sort -l 7 -o ${file/sam/bam} $file
#gzip -c $file > $file.gz
#done

#mkdir $WD/results/mutation
#mkdir $WD/results/bam
#mv $WD/results/*.bam $WD/results/bam
rm $WD/results/*.sai
rm $WD/results/*.sam$
cd $WR/results

for file in $WD/results/*.gz; do
IFS='/' read -r -a array <<< "$file"
long="${array[7]}"
IFS='.' read -r -a array <<< "$long"
name="${array[0]}"
mkdir $WD/results/$name
perl $Program/parseAlignment.pl -v --map-qual 1 --min-len 18 --mutation-file $WD/results/mutation/$name.mutation.txt $WD/results/$name.sam.gz $WD/results/$name/$name.tag.bed
cd $WD/results/$name
#join -j 1 <(sort -k1 /data/lai/moroa/Drosophila/dm6_alias.tab) <(sort -k1 $name.bed) -o 1.2,2.2,2.3,2.4,2.5,2.6,2.7,2.8,2.9,2.10,2.11,2.12| column -t | tr -d '\r' > $name.tag.bed
perl $Program/tag2collapse.pl -v -big --random-barcode -EM 30 --seq-error-model alignment -weight --weight-in-name --keep-max-score --keep-tag-name $WD/results/$name/$name.tag.bed $WD/results/$name/$name.tag.uniq.bed
python2 $Program/joinWrapper.py $WD/results/mutation/$name.mutation.txt $name.tag.uniq.bed 4 4 N $WD/results/mutation/$name.tag.uniq.mutation.txt
perl $Program/bed2annotation.pl -dbkey dm6 -ss -big -region -v -summary $name.tag.uniq.annot.summary.txt $name.tag.uniq.bed $name.tag.uniq.annot.txt
mkdir mode1
perl $Program/tag2peak.pl -big -ss -v --valley-seeking --valley-depth 0.9 $name.tag.uniq.bed $name.tag.uniq.peak.bed --out-boundary $name.tag.uniq.peak.boundary.bed --out-half-PH $name.tag.uniq.peak.halfPH.bed
perl  $Program/bed2annotation.pl -dbkey dm6 -ss -big -region -v -summary $name.tag.uniq.peak.annot.summary.txt $name.tag.uniq.peak.bed $name.tag.uniq.peak.annot.txt
mv *peak* mode1
mkdir mode2
perl $Program/tag2peak.pl -big -ss -v --valley-seeking -p 0.05 --valley-depth 0.9 --dbkey dm6 --multi-test $name.tag.uniq.bed $name.tag.uniq.peak.sig.bed --out-boundary $name.tag.uniq.peak.sig.boundary.bed --out-half-PH $name.tag.uniq.peak.sig.halfPH.bed
perl  $Program/bed2annotation.pl -dbkey dm6 -ss -big -region -v -summary $name.tag.uniq.peak.sig.annot.summary.txt $name.tag.uniq.peak.sig.bed $name.tag.uniq.peak.sig.annot.txt
mv *peak* mode2
done

#e.g., for raw reads
#for f in `ls $WD/*.fastq.gz`; do c=`zcat $f | wc -l`; c=$((c/4)); echo $f $c >> $WD/results_CLIP.txt; done

#e.g., type of mutation
#for file in ./*uniq*.txt;do echo $file; awk '$9 == "-"' $file | wc -l; done  #deletion
#for file in ./*uniq*.txt;do echo $file; awk '$9 == ">"' $file | wc -l; done  #substitution
#for file in ./*uniq*.txt;do echo $file; awk '$9 == "+"' $file | wc -l; done  #insertion
