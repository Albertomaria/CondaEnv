#!/bin/bash
#BSUB -J BamCoverage
#BSUB -n 8
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -u albertomaria.moro@gmail.com


source ~/.bashrc

WD='/data/lai/moroa/3Seq'
CINFO='/data/lai/moroa/Genomes/Drosophila/flybase_dmel_r6.21/chromInfo.txt'
for DIR in $WD/*
do
IFS='/' read -r -a array <<< "$DIR"
name="${array[5]}"
#if [ -e $DIR/mapped/$name.-.bw ]
#then echo "$name.-.bw exist"
#else
cd $DIR
TmpScale=$(bc <<< "scale=6;1000000/$(samtools view -f 0 -c $DIR/mapped/$name.bam)")
bedtools genomecov -bg -split -strand + -g $CINFO -scale $TmpScale -ibam $DIR/mapped/$name.bam > $name.P.bedGraph
bedtools genomecov -bg -split -strand - -g $CINFO -scale $TmpScale -ibam $DIR/mapped/$name.bam > $name.M.bedGraph
bedtools sort -i $name.P.bedGraph > s_$name.P.bedGraph
bedtools sort -i $name.M.bedGraph > s_$name.M.bedGraph
cat s_$name.M.bedGraph | awk '{print $1"\t"$2"\t"$3"\t"$4*-1}' > si_$name.M.bedGraph
bedGraphToBigWig s_$name.P.bedGraph $CINFO $DIR/mapped/$name.+.bw
bedGraphToBigWig si_$name.M.bedGraph $CINFO $DIR/mapped/$name.-.bw
cp $DIR/mapped/$name.+.bw /data/lai/moroa/igv_file/3seq/bw_strand/
cp $DIR/mapped/$name.-.bw /data/lai/moroa/igv_file/3seq/bw_strand/
rm *bw
rm *bedGraph
#fi
done



WD='/data/lai/moroa/CLIP/pipeline/results/bam/'
CINFO='/data/lai/moroa/Genomes/Drosophila/ucsc_dme_r6.21/chrInfo.txt'
for file in $WD/*.bam
do
IFS='/' read -r -a array <<< "$file"
name="${array[9]}"
TmpScale=$(bc <<< "scale=6;1000000/$(samtools view -f 0 -c $WD/$name)")
#bedtools genomecov -bg -split -strand + -g $CINFO -scale $TmpScale -ibam $WD/$name > $name.P.bedGraph
bedtools genomecov -bg -split -strand - -g $CINFO -scale $TmpScale -ibam $WD/$name > $name.M.bedGraph
#bedtools sort -i $name.P.bedGraph > s_$name.P.bedGraph
bedtools sort -i $name.M.bedGraph > s_$name.M.bedGraph
cat s_$name.M.bedGraph | awk '{print $1"\t"$2"\t"$3"\t"$4*-1}' > si_$name.M.bedGraph
#bedGraphToBigWig s_$name.P.bedGraph $CINFO $WD/$name.+.bw
bedGraphToBigWig si_$name.M.bedGraph $CINFO $WD/$name.-.bw
#cp $WD/$name.+.bw /data/lai/moroa/igv_file/CLIP/bw_strand/${name/bam/+.bw}
cp $WD/$name.-.bw /data/lai/moroa/igv_file/CLIP/bw_strand/${name/bam/-.bw}
rm *bw
rm *bedGraph
done
