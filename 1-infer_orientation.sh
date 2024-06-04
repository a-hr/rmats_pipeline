#!/bin/bash

#SBATCH --job-name=get_orientation
#SBATCH --time=03:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8

# ---- INPUTS ----
star_index=/scratch/blazquL/indexes/h_index/index_h124
gtf=/scratch/blazquL/indexes/h_index/gencode.v41.primary_assembly.annotation.gtf
bed=/scratch/blazquL/indexes/h_index/gencode.v41.primary_assembly.annotation.bed
sample1=/scratch/blazquL/alvaro/flecanda/fastqs/A1_S1_R1_001.fastq.gz
sample2=/scratch/blazquL/alvaro/flecanda/fastqs/A1_S1_R2_001.fastq.gz

# ---- set the environment ----
module load Python
conda activate /scratch/blazquL/envs/STAR

# ---- sample the sequences ----
mkdir tmp
mkdir out
zcat $sample1 | head -n 1000000 > tmp/sample1.fq
zcat $sample2 | head -n 1000000 > tmp/sample2.fq

# align to reference genome
STAR --runThreadN 8 --genomeDir $star_index \
--readFilesIn tmp/sample1.fq tmp/sample2.fq \
--outFileNamePrefix out/get_orientation \
--outSAMunmapped Within \
--outFilterType BySJout \
--outSAMattributes NH HI AS NM MD \
--outFilterMultimapNmax 20 \
--outFilterMismatchNmax 999 \
--outFilterMismatchNoverReadLmax 0.04 \
--alignIntronMin 20 \
--alignIntronMax 1000000 \
--alignMatesGapMax 1000000 \
--alignSJoverhangMin 8 \
--alignSJDBoverhangMin 1 \
--sjdbScore 1 \
--outSAMtype BAM SortedByCoordinate

conda deactivate
conda activate /scratch/blazquL/envs/rmats_412

# get orientation based on STAR output
infer_experiment.py -i $(find out/*sortedByCoord.out.bam) -r $bed > orientation.txt

# clear temporal dirs
rm -R tmp/
rm -R out/

#For pair-end RNA-seq, there are two different ways to strand reads (such as Illumina ScriptSeq protocol):

#1++,1–,2+-,2-+
#read1 mapped to ‘+’ strand indicates parental gene on ‘+’ strand
#read1 mapped to ‘-‘ strand indicates parental gene on ‘-‘ strand
#read2 mapped to ‘+’ strand indicates parental gene on ‘-‘ strand
#read2 mapped to ‘-‘ strand indicates parental gene on ‘+’ strand

#1+-,1-+,2++,2–
#read1 mapped to ‘+’ strand indicates parental gene on ‘-‘ strand
#read1 mapped to ‘-‘ strand indicates parental gene on ‘+’ strand
#read2 mapped to ‘+’ strand indicates parental gene on ‘+’ strand
#read2 mapped to ‘-‘ strand indicates parental gene on ‘-‘ strand

#For single-end RNA-seq, there are also two different ways to strand reads:

#++,–
#read mapped to ‘+’ strand indicates parental gene on ‘+’ strand
#read mapped to ‘-‘ strand indicates parental gene on ‘-‘ strand
#+-,-+
#read mapped to ‘+’ strand indicates parental gene on ‘-‘ strand
#read mapped to ‘-‘ strand indicates parental gene on ‘+’ strand

# if ++/-- is similar to +-/+- --> fr-unstranded
# if 1++ < 2++, fr-firststrand
# if 1++ > 2++, fr-secondstrand