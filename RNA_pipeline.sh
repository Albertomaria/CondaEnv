#!/bin/bash
#BSUB -J RNAseq_pipeline
#BSUB -n 8
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -N
#BSUB -u albertomaria.moro@gmail.com

source ./.bashrc
WD='/data/lai/moroa/RNA-seq'
INDEX='/data/lai/moroa/Drosophila/ht2_index/Dme' 
CINFO='/data/lai/moroa/Drosophila/chromInfo.txt'

for DIR in $WD/*
do
IFS='/' read -r -a array <<< "$DIR"
name="${array[5]}"
mkdir $DIR/HiSat_results
#mkdir $DIR/for_isoSCM
cd $DIR/fastq
files=(*.gz)
cd $DIR
if (( ${#files[@]} > 1 ))
then 
#hisat2 -p 8 --no-spliced-alignment -x $INDEX -1 $DIR/fastq/${files[0]} -2 $DIR/fastq/${files[1]} --summary-file $DIR/$name-NS-results.txt -S $DIR/for_isoSCM/$name.sam
#samtools sort -@ 8 -l 7 -o $DIR/for_isoSCM/$name.bam $DIR/for_isoSCM/$name.sam
#samtools index $DIR/for_isoSCM/$name.bam
#rm $DIR/for_isoSCM/$name.sam
hisat2 -p 8 --rna-strandness RF -x $INDEX -1 $DIR/fastq/${files[0]} -2 $DIR/fastq/${files[1]} --summary-file $DIR/$name-results.txt -S $DIR/HiSat_results/$name.sam
samtools sort -@ 8 -l 7 -o $DIR/HiSat_results/$name.bam $DIR/HiSat_results/$name.sam
samtools index $DIR/HiSat_results/$name.bam
rm $DIR/HiSat_results/$name.sam
else
#hisat2 -p 8 --no-spliced-alignment -x $INDEX -U $DIR/fastq/${files[0]} --summary-file $DIR/$name-results.txt -S $DIR/for_isoSCM/$name.sam
#samtools sort -@ 8 -l 7 -o $DIR/for_isoSCM/$name.bam $DIR/for_isoSCM/$name.sam
#samtools index $DIR/for_isoSCM/$name.bam
#rm $DIR/for_isoSCM/$name.sam
hisat2 -p 8 --rna-strandness RF -x $INDEX -U $DIR/fastq/${files[0]}  --summary-file $DIR/$name-results.txt -S $DIR/HiSat_results/$name.sam
samtools sort -@ 8 -l 7 -o $DIR/HiSat_results/$name.bam $DIR/HiSat_results/$name.sam
samtools index $DIR/HiSat_results/$name.bam
rm $DIR/HiSat_results/$name.sam
fi
#java -Xmx4g -jar ~/Script/IsoSCM-2.0.12.jar assemble -s reverse_forward -bam $DIR/for_isoSCM/$name.bam -base $name -insert_size_quantile 0.95 -coverage false
#mv isoscm/tmp/$name.seg.bed isoscm/tmp/$name.scaffolded.bed
#rm isoscm/tmp/$name.sj*
#samtools view -H $DIR/for_isoSCM/$name.bam | grep SQ | sed 's/:/\t/g' | cut -f 3,5 > isoscm/chrom_sizes.txt
TmpScale=$(bc <<< "scale=6;1000000/$(samtools view -f 0 -c $DIR/HiSat_results/$name.bam)")
bedtools genomecov -bg -split -strand + -g $CINFO -scale $TmpScale -ibam $DIR/HiSat_results/$name.bam > $name.P.bedGraph
bedtools genomecov -bg -split -strand - -g $CINFO -scale $TmpScale -ibam $DIR/HiSat_results/$name.bam > $name.M.bedGraph
bedtools sort -i $name.P.bedGraph > s_$name.P.bedGraph
bedtools sort -i $name.M.bedGraph > s_$name.M.bedGraph
cat s_$name.M.bedGraph | awk '{print $1"\t"$2"\t"$3"\t"$4*-1}' > si_$name.M.bedGraph
bedGraphToBigWig s_$name.P.bedGraph $CINFO $DIR/HiSat_results/$name.+.bw
bedGraphToBigWig si_$name.M.bedGraph $CINFO $DIR/HiSat_results/$name.-.bw
rm $name.P.bedGraph
rm $name.M.bedGraph
rm s_$name.P.bedGraph
rm s_$name.M.bedGraph
rm si_$name.M.bedGraph
cp $DIR/HiSat_results/$name.+.bw /data/lai/moroa/igv_file/RNAseq/bw_strand/
cp $DIR/HiSat_results/$name.-.bw /data/lai/moroa/igv_file/RNAseq/bw_strand/
cp $DIR/HiSat_results/$name.bam /data/lai/moroa/igv_file/RNAseq/bam/
cp $DIR/HiSat_results/$name.bam.bai /data/lai/moroa/igv_file/RNAseq/bam/
#echo "\t\t<Category name="'"'"$name"'"'">
#\t\t\t<Resource name="'"'"$name".bam'"'" path="'"'"http://iski0004/~sol/LaiLab/albertomaria/igv_file/RNAseq/bam/"$name".bam"'"'"/>
#\t\t\t<Resource name="'"'"$name".+.bw'"'" path="'"'"http://iski0004/~sol/LaiLab/albertomaria/igv_file/RNAseq/bw_strand/"$name".+.bw"'"'"/>
#\t\t\t<Resource name="'"'"$name".-.bw'"'" path="'"'"http://iski0004/~sol/LaiLab/albertomaria/igv_file/RNAseq/bw_strand/"$name".-.bw"'"'"/>
#\t\t</Category>" >> /data/lai/moroa/igv_file/RNAseq/RNAseq_dataset.xml
done
