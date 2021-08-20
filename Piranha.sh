#!/bin/bash
#BSUB -J Piranha
#BSUB -n 8
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -N
#BSUB -u albertomaria.moro@gmail.com

source ~/.bashrc

WD='/data/lai/moroa/CLIP/pipeline/results/bam/'

for file in $WD/*.bam; do
IFS='/' read -r -a array <<< "$file"
long="${array[9]}"
IFS='.' read -r -a array <<< "$long"
name="${array[0]}"
Piranha -b 30 -s $long > $name.out
done
