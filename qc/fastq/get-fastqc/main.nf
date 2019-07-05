#!/usr/bin/env nextflow

in_files = params.in_files
out_dir = file(params.out_dir)

println in_files

read_pair = Channel.fromFilePairs("${in_files}", type: 'file')

process runFastQC{
    tag { "${params.project_name}.rFQC.${sample}" }
    cpus { 2 }
    publishDir "${out_dir}/${sample}", mode: 'copy', overwrite: false
    label 'fastqc'

    input:
        set sample, file(in_fastq) from read_pair

    output:
        file("${sample}_fastqc/*.zip") into fastqc_files

    """
    mkdir ${sample}_fastqc
    fastqc --outdir ${sample}_fastqc \
    -t ${task.cpus} \
    ${in_fastq.get(0)} \
    ${in_fastq.get(1)}
    """
}

process runMultiQC{
    tag { "${params.project_name}.rMQC" }
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
