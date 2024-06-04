#!/bin/bash

#SBATCH --job-name=rmats
#SBATCH --array=0-4%5
#SBATCH -c 5
#SBATCH --mem=40G
#SBATCH --output=./logs/rmats_%j.out

# ---- set the environment ----
module load Python
conda activate /scratch/blazqul/envs/rmats_412/

# ---- INPUTS ----

root_dir=/scratch/blazqul/alvaro/flecanda/rmats
gtf=/scratch/blazqul/indexes/h_index/gencode.v41.primary_assembly.annotation.gtf
star_index=/scratch/blazqul/indexes/h_index/index_h124
fastqs_dir=/scratch/blazqul/alvaro/flecanda/fastqs

paired=paired
strandedness=fr-firststrand
length=125

directories=(mut_WT mut-sgRBM10_mut mut-sgSETD2_mut WT-sgRBM10_WT WT-sgSETD2_WT)
g1_indices=(4,5,6 10,11,12 16,17,18 7,8,9 13,14,15)  # study group
g2_indices=(1,2,3 4,5,6 4,5,6 1,2,3 1,2,3)  # control group

g1=${g1_indices[$i]}
g2=${g2_indices[$i]}

echo "$(date +"%T") - Starting contrast ${directories[$i]}"

# ---- create the output directories ----
mkdir -p $root_dir
cd $root_dir
i=$SLURM_ARRAY_TASK_ID


#! remember to replace the suffix of the fastq files
all_fastqs=$(ls $fastqs_dir/*_R1_001.fastq.gz | sed 's/_R1_001.fastq.gz//' | xargs -I {} echo $(realpath {})_R1_001.fastq.gz:$(realpath {})_R2_001.fastq.gz | paste -sd ",")

mkdir -p rmats_${directories[$i]}
cd rmats_${directories[$i]}

mkdir -p rmats_output rmats_tmp

curr_dir=$root_dir/rmats_${directories[$i]}

# ---- create s1 and s2 files ----
s1=$(echo $all_fastqs | cut -d "," -f $g1)
s2=$(echo $all_fastqs | cut -d "," -f $g2)

echo ""
echo "Files for contrast:"
echo -e "\t-s1: $s1"
echo -e "\t-s2: $s2"

echo $s1 > s1.txt
echo $s2 > s2.txt

# ---- run rmats ----
echo "$(date +"%T") - Running rMATS"

#! remember to replace the path to the python and rmats binaries
/scratch/blazqul/envs/rmats_412/bin/python \
    /scratch/blazqul/envs/rmats_412/bin/rmats.py \
    --s1 s1.txt \
    --s2 s2.txt \
    --bi $star_index \
    --gtf $gtf \
    --od $curr_dir/rmats_output \
    --tmp $curr_dir/rmats_tmp \
    -t $paired \
    --libType $strandedness \
    --readLength $length \
    --variable-read-length \
    --nthread 5 \
    --cstat 0.05 \
    --task both \
    --novelSS

echo "$(date +"%T") - Finished contrast"