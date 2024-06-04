# How to run rMATS

> Álvaro Herrero Reiriz, Junio 2024

Important notes:
- The last versions of rMATS are kind of buggy, so I recommend using the version 4.1.2.
    ```bash
    conda install -c bioconda rmats=4.1.2
    ```
- Before running rMATS, it is required to know the strandedness of the RNA-seq data. If the data is stranded, the `--libType` parameter should be set to `fr-firststrand` or `fr-secondstrand`. If the data is unstranded, the `--libType` parameter should be set to `fr-unstranded`. To discover this, run `1-infer_orientation.sh` script.
- It is best to run rMATS directly from FASTQ files.

## 1. Prepare the input files

You will need:
- A GTF file with the gene annotations.
- The same GTF file in BED format.
- FASTQ files with the RNA-seq data.
- A STAR index of the genome, created for the fragment size of the RNA-seq data.

## 2. Detect the strandedness of the RNA-seq data

Fill in the input variables:

- `star_index`: The directory where the STAR index is stored.
- `gtf`: The path to the GTF file.
- `bed`: The path to the BED file of the *gtf*.
- `sample1`: The path to the first FASTQ (R1) file.
- `sample2`: The path to the second FASTQ (R2) file.

Run the script:

```bash
sbatch 1-infer_orientation.sh
```

To interpret the results, according to the documentation:

- For pair-end RNA-seq, there are two different ways to strand reads (such as Illumina ScriptSeq protocol):

```
1++,1–,2+-,2-+
read1 mapped to ‘+’ strand indicates parental gene on ‘+’ strand
read1 mapped to ‘-‘ strand indicates parental gene on ‘-‘ strand
read2 mapped to ‘+’ strand indicates parental gene on ‘-‘ strand
read2 mapped to ‘-‘ strand indicates parental gene on ‘+’ strand
```

```
1+-,1-+,2++,2–
read1 mapped to ‘+’ strand indicates parental gene on ‘-‘ strand
read1 mapped to ‘-‘ strand indicates parental gene on ‘+’ strand
read2 mapped to ‘+’ strand indicates parental gene on ‘+’ strand
read2 mapped to ‘-‘ strand indicates parental gene on ‘-‘ strand
```

- For single-end RNA-seq, there are also two different ways to strand reads:

```
++,–
read mapped to ‘+’ strand indicates parental gene on ‘+’ strand
read mapped to ‘-‘ strand indicates parental gene on ‘-‘ strand
+-,-+
read mapped to ‘+’ strand indicates parental gene on ‘-‘ strand
read mapped to ‘-‘ strand indicates parental gene on ‘+’ strand
```

> if ++/-- is similar to +-/+- --> fr-unstranded  
> if 1++ < 2++, fr-firststrand  
> if 1++ > 2++, fr-secondstrand  

## 3. Run rMATS

First, fill in the input variables:

- `root_dir`: The directory where the output files will be stored.
- `gtf`: The path to the GTF file.
- `star_index`: The path to the STAR index.
- `fastqs_dir`: The directory where the FASTQ files are stored.
- `paired`: The type of sequencing (paired or single).
- `strandedness`: The strandedness of the RNA-seq data.
- `length`: The length of the reads.

Then, create the `directories` array, which will contain as many elements as contrasts you want to make (names are arbitrary, but will be the names of the outputs).

Finally, create the `g1_indices` and `g2_indices` arrays. They should have the same length as the `directories` array, and will contain the indices of the FASTQs (1-based) that will be used in that contrast (FASTQs in g1 pos A vs FASTQs in g2 pos A). Comma separated samples belong to the same contrast.

> Note: the indexes refer to the position where the file lies when running an `ls` command in the `fastqs_dir` directory.

Before running, make sure the FASTQ suffixes (line 40) and the **python** and **rMATS** binaries (line 65) are correctly set to your requirements.

```bash
sbatch 2-run_rmats.sh
```