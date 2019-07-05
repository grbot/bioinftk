### Run GATK VariantEval over a list of VCFs. SNP concordance against dbSNP and 1kg SNP sites are reported. INDEL concordance against 1kg INDEL sites are also reported.
The file format of the VCFs should be
* (*.vcf) or (*.vcf.gz) with the corresponding index files e.g. (*.vcf.tbi) or (*.vcf.gz.tbi)
* Each VCF and VCF index should be unique so that Nextflow's fromFilePairs picks up the pairs correctly

1. Run:  
```
nextflow run main.nf
```
