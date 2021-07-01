#!/usr/bin/env nextflow

in_files = file(params.in_files)
out_dir = file(params.out_dir)
ref = file(params.ref)
nt = params.nt

Channel.fromPath(in_files)
        .set { fastas }

process getQuast{
    tag { "${params.project_name}.${fasta}.gQ" }
    cpus { "${nt}" }
    publishDir "${out_dir}/${fasta}", mode: 'copy', overwrite: false
   
    input:
	  file (fasta) from fastas

    output:
	  file ("*") into quast_files

    script:
    """
    quast -r ${ref} \
    -o ${fasta.simpleName}.quast \
    --eukaryote \
    --conserved-genes-finding \
    -t ${task.cpus} \
    ${fasta}
    """
}

process runMultiQC{
    tag { "${params.project_name}.rMQC" }
    publishDir "${out_dir}/", mode: 'copy', overwrite: false

    input:
        file('*') from quast_files.collect()
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
