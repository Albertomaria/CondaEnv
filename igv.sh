#!/bin/bash
#BSUB -J file_x_igv
#BSUB -n 8
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -u albertomaria.moro@gmail.com

source ./.bashrc

cd /data/lai/moroa/3Seq
for dir in *
do 
name=$dir
bamCoverage -b $dir/mapped/$name.bam --normalizeUsing CPM --exactScaling -o $dir/mapped/$name.bw
cp $dir/mapped/*bam* /data/lai/moroa/igv_file/3seq/bam/
cp $dir/mapped/*bw /data/lai/moroa/igv_file/3seq/bw/
cp $dir/$name.gtf/*gtf /data/lai/moroa/igv_file/3seq/gtf/
echo "\t\t<Category name="'"'"$name"'"'">\n
\t\t\t<Resource name="'"'"$name".bam" path="'"'"TOCHANGE/"$name".bam"'"'"/>\n
\t\t\t<Resource name="'"'"$name".bw" path="'"'"TOCHANGE/"$name".bw"'"'"/>\n
\t\t\t<Resource name="'"'"$name".gtf" path="'"'"TOCHANGE/"$name".gtf"'"'"/>\n
\t\t</Category>" >> /data/lai/moroa/igv_file/3seq/3seq_dataset.xml
done
