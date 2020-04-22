# main.nf #

Nexftlow pipeline checking .fastq.gz files. 1) Check if the file is a valide gzip and 2) Count the number of reads.

The reads needs to be in the format S1_R1.fastq.gz and S1_R2.fastq.gz, where S1 is the sample id. All sample read files needs to be in the same folder. The ouput folder will consist of per folder sample directories containing the results.

To get a summary of the nextflow run output something like this can be run

```bash
echo -e "SampleID\tR1_read_count\tR2_read_count\tR1_gzip_validated\tR2_gzip_validated" > all_batches.checked.tsv; \
for i in `ls -d *`; \
do \
  echo -en $i"\t"; cat $i/*R1_read_count.txt | tr -d '\n'; echo -en "\t"; cat $i/*R2_read_count.txt | tr -d '\n' ; echo -en "\t"; cat $i/*R1_validated.txt | tr -d '\n'; echo -en "\t"; cat $i/*R2_validated.txt; \
done >> all_batches.checked.tsv
cat all_batches.checked.tsv | awk '{if ($2 != $3){print $1" forward and reverse do not match"}}'
```
