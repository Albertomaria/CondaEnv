#!/bin/bash
#BSUB -J HiSat2
#BSUB -n 8
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -N
#BSUB -u albertomaria.moro@gmail.com

source ./.bashrc
WD='/data/lai/moroa/3Seq'
INDEX='/data/lai/moroa/Drosophila/dmel_r6.21_FB2018_02/gtf/dmel-all-r6.21.gtf'

for DIR in $WD/*
do
IFS='/' read -r -a array <<< "$DIR"
name="${array[5]}"
cd $DIR
if [ -e $DIR/assignment_name.txt ]
then
cp ~/Script/Sol/AssignmentPipeline.jar ./
RNA=$(cat assignment_name.txt )
/opt/common/CentOS_7/java/jdk1.8.0_131/bin/java -Xmx2g \
-jar AssignmentPipeline.jar AssignClusters \
-atlas $name.gtf/$name.gtf \
-seqLengths /data/lai/moroa/RNA-seq/$RNA/isoscm/chrom_sizes.txt \
-assignmentTable $name-assigment.txt \
-isoscmRoot /lila/data/lai/moroa/RNA-seq/$RNA/isoscm/ \
-referenceGtf $INDEX \
-baseNames assignment_name.txt
rm AssignmentPipeline.jar
fi
done

