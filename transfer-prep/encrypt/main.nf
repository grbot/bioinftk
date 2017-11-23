#!/usr/bin/env nextflow

out = file(params.out)
out.mkdir()

Channel.fromPath(params.file_list)
        .splitText()
        .map { file(it.trim()) }
        .set { file_list }

process encryptFiles(){
     tag { "${params.project_name}.encF_${data_file}" }

     publishDir "${out}/", mode: 'copy', overwrite: false

     input:
         file(data_file) from file_list 

    output:
         file("*.gpg") into encrypt_list 

    """
    gpg --import ${params.key}
    gpg --yes --trust-model always -r \"${params.key_phrase}\" -o ${data_file}.gpg -e ${data_file}
    """
}

encrypt_list.subscribe { println it }

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

