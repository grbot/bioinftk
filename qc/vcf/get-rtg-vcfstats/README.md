### Run RTG over a list of VCFs and get `vcfstats` got both `known` and `novel` sites.
1. A known site is defined by an enty in the dbSNP column (3) of the VCF.
2. For the variable `in_files` set the glob settings of files to include in the report generation
3. Run:  
```
nextflow run main.nf
```
