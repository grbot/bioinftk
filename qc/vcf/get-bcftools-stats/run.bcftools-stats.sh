#/bin/bash

set -x

# Read all BAM files in input directory and run samtools flagstat over it
. $1
in=$in
out=$out
nc=$nc

gnu_parallel_base=$gnu_parallel_base
bcftools_base=$bcftools_base
ref=$ref

ls -1 $in/*.vcf.gz | $gnu_parallel_base/parallel --max-procs $nc "$bcftools_base/bcftools stats -F $ref {} > $out/{/}.bcftools-stats; $bcftools_base/plot-vcfstats -p $out/{/}.bcftools-stats  $out/{/}.bcftools-stats"

# Remove some intermediate files
rm $out/*.bcftools-stats-counts_by_af.indels.dat
rm $out/*.bcftools-stats-counts_by_af.snps.dat
rm $out/*.bcftools-stats-depth.0.dat
rm $out/*.bcftools-stats-depth.0.pdf
rm $out/*.bcftools-stats-depth.0.png
rm $out/*.bcftools-stats-indels.0.dat
rm $out/*.bcftools-stats-indels.0.pdf
rm $out/*.bcftools-stats-indels.0.png
rm $out/*.bcftools-stats-plot.py
rm $out/*.bcftools-stats-plot-vcfstats.log
rm $out/*.bcftools-stats-substitutions.0.pdf
rm $out/*.bcftools-stats-substitutions.0.png
rm $out/*.bcftools-stats-summary.aux
rm $out/*.bcftools-stats-summary.log
rm $out/*.bcftools-stats-summary.tex
rm $out/*.bcftools-stats-tstv_by_af.0.dat
rm $out/*.bcftools-stats-tstv_by_qual.0.dat
rm $out/*.bcftools-stats-tstv_by_qual.0.pdf
rm $out/*.bcftools-stats-tstv_by_qual.0.png
