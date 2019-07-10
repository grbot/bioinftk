#!/usr/bin/env nextflow

in_files = file(params.in_files)
out_dir = file(params.out_dir)

Channel.fromPath(in_files)
        .set { bams }

process getQualimap{
    tag { "${params.project_name}.${bam}.gQ" }
    publishDir "${out_dir}", mode: 'copy', overwrite: false
    validExitStatus 0,124

    input:
	  file (bam) from bams

    output:
	  file ("${bam}.qualimap") into qualimap_files

    script:
    """
    export DISPLAY=:0.0
    timeout ${params.timeout} qualimap bamqc -bam $bam \
    -outdir ${bam}.qualimap \
    -outfile ${bam}.qualimap.html \
    -outformat html
    """
}


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
