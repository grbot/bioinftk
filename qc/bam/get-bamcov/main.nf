#!/usr/bin/env nextflow

in_files = file(params.in_files)
out_dir = file(params.out_dir)

Channel.fromPath(in_files)
        .set { bams }

process getBamCov {
    tag { "${params.project_name}.${bam}.gBC" }
    publishDir "${out_dir}", mode: 'copy', overwrite: false
    memory { 4.GB * task.attempt }

    input:
	  file (bam) from bams

    output:
	  set file("${bam}.bamcov.stats"), ("${bam}.bamcov.hist") into bamcov

    script:
    """
    bamcov ${bam} > ${bam}.bamcov.stats
    bamcov -m ${bam} > ${bam}.bamcov.hist
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
