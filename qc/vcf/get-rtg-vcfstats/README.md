### Run RTG over a list of VCFs and get `vcfstats` got both `known` and `novel` sites.
1. A known site is define by an enty in the dbSNP (column 3) of the VCF.
2. Set the path with glob settings of files to include in the report generation (`in_files`)
3. Run:  
```
nextflow run main.nf
```
