#!/usr/bin/env nextflow

in_files = params.in_files
out_dir = file(params.out_dir)
reference = file(params.reference)
reference_index = file(params.reference_index)
reference_dict = file(params.reference_dict)

Channel.fromFilePairs(in_files)
        { file ->
          b = file.baseName
          m = b =~ /(.*)\.vcf.*/
          return m[0][1]
        }.set{vcfs}

process getGATKValidateVariants {
    tag { "${params.project_name}.${vcf}.gGVV" }
    publishDir "${out_dir}", mode: 'copy', overwrite: false
    memory { 4.GB }
    input:
      set val (file_name), file (vcf) from vcfs
      file (ref) from reference
      file (index) from reference_index
      file (dict) from reference_dict

    output:
	  file("${vcf[0]}.validatevariants") into validatevariants_file

    script:
    add_parameter = "" // set default
    if ( params.type == "vcf" )
      add_parameter = ""
    else if ( params.type == "gvcf" )
      add_parameter = "--validate-GVCF"
    """
    gatk --java-options "-Xmx${task.memory.toGiga()}g" \
    ValidateVariants \
    -R $ref \
    $add_parameter \
    -V ${vcf[0]} \
    > ${vcf[0]}.validatevariants 2>&1
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
