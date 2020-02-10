#!/usr/bin/env nextflow

in_files = params.in_files
out_dir = file(params.out_dir)

Channel.fromFilePairs(in_files)
        { file ->
          b = file.baseName
          m = b =~ /(.*)\.vcf.*/
          return m[0][1]
        }.set{vcfs}

process getGATKVariantEval {
    tag { "${params.project_name}.${vcf[0]}.gGVE" }
    memory { 232.GB * task.attempt }
    publishDir "${out_dir}", mode: 'copy', overwrite: false
    
    input:
	  set val (file_name), file (vcf) from vcfs

    output:
	  file("${vcf[0]}.varianteval") into varianteval_file

    script:
    mem = task.memory.toGiga() - 16
    """
    gatk --java-options "-Xmx${mem}g" \
    VariantEval \
    -R $params.ref \
    -eval:${vcf[0].simpleName} ${vcf[0]} \
    -comp:1kg_SNPs $params.kg_snps \
    -comp:1kg_INDELs $params.kg_indels \
    -D $params.dbsnp \
    -O ${vcf[0]}.varianteval
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
