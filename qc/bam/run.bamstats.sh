#/bin/bash

set -x

# Read all BAM files in input directory and run samtools flagstat over it
. $1
in=$in
out=$out
nc=$nc

gnu_parallel_base=$gnu_parallel_base
bamstats_base=$bamstats_base

ls -1 $in/*.bam | $gnu_parallel_base/parallel --max-procs $nc "java -jar $bamstats_base/BAMStats-1.25.jar -i {} -o $out/{/}.bamstats -v simple"

