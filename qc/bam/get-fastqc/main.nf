#!/usr/bin/env nextflow

in_files = file(params.in_files)
out_dir = file(params.out_dir)

Channel.fromPath(in_files)
        .set { bams }

process getFastqc {
    tag { "${params.project_name}.${bam}.gF" }
    publishDir "${out_dir}/${bam}", mode: 'copy', overwrite: false
    label 'fastqc'
    cpus { 1 }

    input:
	  file (bam) from bams

    output:
	  file("${bam}.fastqc") into fastqc_files

    script:
    """
    mkdir ${bam}.fastqc
    fastqc -t ${task.cpus} -f bam $bam --outdir ${bam}.fastqc
    """
}

process runMultiQC{
    tag { "${params.projectName}.rMQC" }
    publishDir "${out_dir}", mode: 'copy', overwrite: false
    label 'multiqc'

    input:
        file('*') from fastqc_files.collect()

    output:
        file('multiqc_report.html')

    """
    multiqc .
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
