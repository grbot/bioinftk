#/bin/bash

set -x

# Read all BAM files in input directory and run samtools flagstat over it
. $1
in=$in
out=$out
nc=$nc

gnu_parallel_base=$gnu_parallel_base
samtools_base=$samtools_base

ls -1 $in/*.bam | $gnu_parallel_base/parallel --max-procs $nc "$samtools_base/samtools flagstat {} > $out/{/}.flagstat"

