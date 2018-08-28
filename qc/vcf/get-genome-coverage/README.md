### Create a BED file with coverage windows
```
 for i in {1..22}; do bedtools makewindows -g b37.$i.genomesizes.txt -w 5000000  > windows.$i.5M.bed; done
```
### Get table with coverage
```
nextflow -log nextflow.log run -w /global5/scratch/gerrit/nextflow-wd/h3achip -c nextflow.config main.nf  -profile pbs -resume
```
