#!/usr/bin/env nextflow

raw_reads_path = params.raw_reads
out_path = file(params.out)

out_path.mkdir()

read_pair_copy_1 = Channel.fromFilePairs("${raw_reads_path}/*_R[1,2].fastq.gz", type: 'file')
read_pair_copy_2 = Channel.fromFilePairs("${raw_reads_path}/*_R[1,2].fastq.gz", type: 'file')

process getSampleReadCounts {
     tag { "${params.project_name}.gSRC.${sample}" }
     
     publishDir "${out_path}/${sample}", mode: 'copy', overwrite: false

     input:
	   set sample, file(read) from read_pair_copy_1

    output:
	   set sample, file("*read_count.txt") into read_count_pair

    """
    zcat ${read.get(0)} | awk '{s++}END{print s/4}' > ${sample}_R1_read_count.txt
    zcat ${read.get(1)} | awk '{s++}END{print s/4}' > ${sample}_R2_read_count.txt
    """
}

process validateGZip {
     tag { "${params.project_name}.vGZ.${sample}" }

     publishDir "${out_path}/${sample}", mode: 'copy', overwrite: false

     input:
	   set sample, file(read) from read_pair_copy_2

    output:
	   set sample, file("*validated.txt") into read_validate_pair

    """
    if gunzip -t ${read.get(0)} 2> /dev/null; then echo "OK"; else echo "FAILURE"; fi > ${sample}_R1_validated.txt
    if gunzip -t ${read.get(1)} 2> /dev/null; then echo "OK"; else echo "FAILURE"; fi > ${sample}_R2_validated.txt
    """
}

read_count_pair.subscribe { println it }
read_validate_pair.subscribe { println it }

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

