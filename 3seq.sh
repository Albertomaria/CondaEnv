#!/bin/bash
#BSUB -J 3seq
#BSUB -n 8
#BSUB -R rusage[mem=8]
#BSUB -W 72:00
#BSUB -o %J.stdout
#BSUB -eo %J.stderr
#BSUB -u albertomaria.moro@gmail.com

source ~/.bashrc
PrMask='/data/lai/moroa/Genomes/Drosophila/flybase_dmel_r6.21/dm6.priming.9.16.bed'

cd /data/lai/moroa/3Seq/fresh_start_all/

java -Xmx4g -Djava.io.tmpdir=htsjdk_tmp -jar $HOME/Script/Sol/ThreeSeqPipeline.jar DefineClusters -minDistinctReads 3 -inDir mapped -trimmed trimmed -untrimmed untrimmed -primingMask $PrMask -outDir gtf -baseNames sample_name_1.txt
