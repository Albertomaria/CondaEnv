#!/bin/bash
#BSUB -J STAR_index
#BSUB -n 5
#BSUB -R rusage[mem=5]
#BSUB -W 04:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr

source ./.bashrc

STAR --runMode genomeGenerate --genomeSAindexNbases 5  --genomeDir /data/lai/moroa/Drosophila/STAR_index --genomeFastaFiles /data/lai/moroa/Drosophila/dmel_r6.21_FB2018_02/fasta/dmel-all-chromosome-r6.21.fasta --sjdbGTFfile  /data/lai/moroa/Drosophila/dmel_r6.21_FB2018_02/gtf/dmel-all-r6.21.gtf
