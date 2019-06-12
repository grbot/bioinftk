#!/usr/bin/env nextflow

in_files = file(params.in_files)
out_dir = file(params.out_dir)

Channel.fromPath(in_files)
        .set { vcfs }

process getRTGVcfstats {
    tag { "${params.project_name}.${vcf}.gRTGS" }
    publishDir "${out_dir}", mode: 'copy', overwrite: false

    input:
	  file (vcf) from vcfs

    output:
	  file("${vcf}.rtg-vcfstats.known") into vcfstats_known_file
	  file("${vcf}.rtg-vcfstats.novel") into vcfstats_indel_file

    script:
    """
    rtg vcfstats --known ${vcf} > "${vcf}.rtg-vcfstats.known"
    rtg vcfstats --novel ${vcf} > "${vcf}.rtg-vcfstats.novel"
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
