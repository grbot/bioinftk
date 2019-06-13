#!/usr/bin/env nextflow

in_files = file(params.in_files)
out_dir = file(params.out_dir)

Channel.fromPath(in_files)
        .set { bams }

process getBamStats {
    tag { "${params.project_name}.${bam}.gBS" }
    publishDir "${out_dir}", mode: 'copy', overwrite: false
    memory { 4.GB * task.attempt }

    input:
	  file (bam) from bams

    output:
	  set file("${bam}.bamstats.html"), ("${bam}.bamstats.html.data/*") into bamstats

    script:
    """
    java -Xmx${task.memory.toGiga()}g -jar /BAMStats-1.25/BAMStats-1.25.jar -i ${bam} -v html -o "${bam}.bamstats.html"
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
