#!/usr/bin/env nextflow

in_files = file(params.in_files)
ref = file(params.ref)
out_dir = file(params.out_dir)

Channel.fromPath(in_files)
        .set { vcfs }

process getBcftoolsStats {
    tag { "${params.project_name}.${vcf}.gBS" }
    publishDir "${out_dir}", mode: 'copy', overwrite: false

    input:
	  file (vcf) from vcfs

    output:
    file ("${vcf}.bcftools-stats") into bcftools_stats_file
    file ("${vcf}.bcftools-stats.pdf") into bcftools_stats_report_file

    script:
    """
    bcftools stats -F "${ref}" "${vcf}" > "${vcf}.bcftools-stats"
    plot-vcfstats -p "${vcf}.bcftools-stats.report" "${vcf}.bcftools-stats"
    mv "${vcf}.bcftools-stats.report/summary.pdf" "${vcf}.bcftools-stats.pdf"
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
