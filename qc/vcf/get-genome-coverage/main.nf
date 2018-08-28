#!/usr/bin/env nextflow
in_path = file(params.in_dir)
out_path = file(params.out_dir)

out_path.mkdir()

chromosomes = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22".split(',')

process getGenomeCoverage {
     tag { "${params.project_name}.${chr}.pGC" }
     
     publishDir "${out_path}", mode: 'copy', overwrite: false

     input:
	 each chr from chromosomes  

    output:
	   file("${chr}.coverage") into chr_file 

    """
    /opt/exp_soft/bedtools2/bin/bedtools coverage -a "/global5/scratch/projects/chipdesign/variant_calling/compare_phasing_ready_redo_with_ref_panel/windows/windows.${chr}.5M.bed" -b "${in_path}/${chr}.pre-vqsr.replaced_missing_with_refref.vcf.gz" -counts > "${chr}.coverage"
    """
}

chr_file.subscribe { println it }

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
