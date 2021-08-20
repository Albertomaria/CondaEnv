#!/bin/bash
#BSUB -J BamCoverage
#BSUB -n 8
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -u albertomaria.moro@gmail.com

source ~/.bashrc

WD='/data/lai/moroa/CLIP/pipeline/results/CTK'

for DIR in $WD/*/
do
IFS='/' read -r -a array <<< "$DIR"
name="${array[8]}"
cd $DIR/mode1
bedToGenePred $name.tag.uniq.peak.bed mutation && genePredToGtf file temp $name.tag.uniq.peak.gtf && mv *gtf /data/lai/moroa/igv_file/CLIP/gtf/CKT/mutation
bedToGenePred $name.tag.uniq.peak.boundary.bed boundary && genePredToGtf file boundary $name.tag.uniq.peak.boundary.gtf && mv *gtf /data/lai/moroa/igv_file/CLIP/gtf/CKT/boundary/
cd $DIR/mode2
bedToGenePred $name.tag.uniq.peak.sig.bed mutation && genePredToGtf file mutation $name.tag.uniq.peak.sig.gtf && mv *gtf /data/lai/moroa/igv_file/CLIP/gtf/CKT/mutation
bedToGenePred $name.tag.uniq.peak.sig.boundary.bed boundary && genePredToGtf file boundary $name.tag.uniq.peak.sig.boundary.gtf && mv *gtf /data/lai/moroa/igv_file/CLIP/gtf/CKT/boundary/
done

WD='/data/lai/moroa/igv_file/CLIP/gtf/CKT'

for file in $WD/mutation/*
do
IFS='/' read -r -a array <<< "$file"
name="${array[9]}"
touch $WD/${name/.tag.uniq.peak/} 
sed 's/ transcript_id.*/color=#FF0000/g' $file >> $WD/${name/.tag.uniq.peak/} 
sed 's/ transcript_id.*/color=#A1C3D1/g' $WD/boundary/${name/gtf/boundary.gtf}  >> $WD/${name/.tag.uniq.peak/} 
done

source ~/.bashrc

WD='/data/lai/moroa/CLIP/pipeline/results/bam/Piranha'
for file in $WD/*.out
do
cat $file | awk '{print $1"\t"$2"\t"$3"\tpV="$7";Peak="$5"\t"0"\t"$6}' > ${file/out/bed}
bedToGenePred ${file/out/bed} temp && genePredToGtf file temp ${file/out/gtf} && mv *gtf /data/lai/moroa/igv_file/CLIP/gtf/Piranha/
rm temp
done
