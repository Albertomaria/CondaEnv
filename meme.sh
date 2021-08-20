#!/bin/bash
#BSUB -J meme
#BSUB -n 8
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -u albertomaria.moro@gmail.com

source ~/.bashrc

WD='/data/lai/moroa/CLIP/pipeline/results/CTK'
FASTA='/data/lai/moroa/Genomes/Drosophila/ucsc_dme_r6.21/dm6.fasta'
DB='/data/lai/moroa/Genomes/ATtRACT/pwm_Dme6.txt'
cd $WD

#for DIR in $WD/*/
#do
#IFS='/' read -r -a array <<< "$DIR"
#name="${array[8]}"
#cat $DIR/mode2/$name.tag.uniq.peak.sig.boundary.bed | awk '{if($3-$2>7) print}' | uniq > $name.sig.bed
#bedtools getfasta -s -fi $FASTA -bed $name.sig.bed -fo $name.sig.fasta
#meme $name.sig.fasta -oc meme.$name
#mv *bed meme.$name
#mv *fasta meme.$name
#done


#for DIR in $WD/*/
#do
#IFS='/' read -r -a array <<< "$DIR"
#name="${array[8]}"
#awk '{print $1"\t"int(($2+$3)/2)-250"\t"int(($2+$3)/2)+250"\t"$4"\t"$5"\t"$6}' $DIR/mode2/$name.tag.uniq.peak.sig.halfPH.bed > $WD/flank500/$name.peak.sig.center.bed
#bedtools getfasta -s -fi $FASTA -bed $WD/flank500/$name.peak.sig.center.bed -fo $WD/flank500/$name.peak.sig.center.fasta
#meme-chip $WD/flank500/$name.peak.sig.center.fasta -db $DB -oc $WD/flank500/meme_$name
#done


WD='/data/lai/moroa/CLIP/pipeline/results/Piranha'
cd $WD

for DIR in $WD/*.bed
do
IFS='/' read -r -a array <<< "$DIR"
IFS='.' read -r -a array <<< "${array[8]}"
name="${array[0]}"
awk '{print $1"\t"int(($2+$3)/2)-250"\t"int(($2+$3)/2)+250"\t"$4"\t"$5"\t"$6}' $WD/$name.bed > $WD/flank500/$name.center.bed
bedtools getfasta -s -fi $FASTA -bed $WD/flank500/$name.center.bed -fo $WD/flank500/$name.center.fasta
meme-chip $WD/flank500/$name.center.fasta -db $DB -oc $WD/flank500/meme_$name
done