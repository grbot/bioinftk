#/bin/bash

set -x

# Read all *.vcf.gz files in input directory and run rtg vcfstats flagstat over it
. $1
in=$in
out=$out
nc=$nc

gnu_parallel_base=$gnu_parallel_base
gatk_base=$gatk_base
ref=$ref
kg_SNPs=$kg_SNPs
kg_INDELs=$kg_INDELs
dbSNP=$dbSNP

ls -1 $in/*.vcf.gz | $gnu_parallel_base/parallel --max-procs $nc "java -jar $gatk_base/GenomeAnalysisTK.jar \
-T VariantEval \
-R $ref \
-eval:{/} {} \
-comp:1kg_SNPs $kg_SNPs \
-comp:1kg_INDELs $kg_INDELs \
-D $dbSNP \
-o $out/{/}.variant-eval"
