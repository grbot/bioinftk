### Run `qualimap` over a list of BAMs
1. Run:  
```
nextflow run main.nf
```

#### To note
There is an issue running qulimap in the container. It hangs and does not complete even though the HTML output is there (the PDF out is however corrupted). To get around this the qualimap process is killed after some duration. Nextflow then excepts the error code `124` as valid and output is generated in the output directory. There is a `timeout` variable that can be set in the `nextflow.config` if stats needs to be calculated on larger genomes or genomes with higher depth of coverage.
