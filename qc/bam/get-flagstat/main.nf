#!/usr/bin/env nextflow

in_files = file(params.in_files)
out_dir = file(params.out_dir)

Channel.fromPath(in_files)
        .set { bams }

process getSamtoolsFlagstat {
    tag { "${params.project_name}.${bam}.gSF" }
    publishDir "${out_dir}", mode: 'copy', overwrite: false

    input:
	  file (bam) from bams

    output:
	  file("${bam}.flagstat") into samtools_flagstat

    script:
    """
    samtools flagstat ${bam} > "${bam}.flagstat"
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
