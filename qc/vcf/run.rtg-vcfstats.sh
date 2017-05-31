#/bin/bash

set -x

# Read all *.vcf.gz files in input directory and run rtg vcfstats flagstat over it
. $1
in=$in
out=$out
nc=$nc

gnu_parallel_base=$gnu_parallel_base
rtg_base=$rtg_base

ls -1 $in/*.vcf.gz | $gnu_parallel_base/parallel --max-procs $nc "$rtg_base/rtg vcfstats {} > $out/{/}.rtg-vcfstats"

