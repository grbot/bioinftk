#!/usr/bin/env nextflow
in_path = file(params.in_dir)
out_path = file(params.out_dir)

out_path.mkdir()

// chromosomes = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,MT,X,Y".split(',')
chromosomes = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,X".split(',')

process getPerChromosomesCounts {
     tag { "${params.project_name}.${chr}.pCC" }
     
     publishDir "${out_path}", mode: 'copy', overwrite: false

     input:
	 each chr from chromosomes  

    output:
	   file("${chr}.count") into chr_file 

    """
    zcat "${in_path}/${chr}.pre-vqsr.replaced_missing_with_refref.vcf.gz" | grep -v "^#" | wc -l > "${chr}.count"
    """
}

chr_file.subscribe { println it }

workflow.onComplete {

    println ( workflow.success ? """
        Pipeline execution summary
        ---------------------------
        Completed at: ${workflow.complete}
        Duration    : ${workflow.duration}
        Success     : ${workflow.success}
        workDir     : ${workflow.workDir}
        exit status : ${workflow.exitStatus}
        """ : """
        Failed: ${workflow.errorReport}
        exit status : ${workflow.exitStatus}
        """
    )
}
