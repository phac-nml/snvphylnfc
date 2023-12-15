/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process CONSOLIDATE_BCFS {
    tag "${meta.id}"
    label 'process_single'
    container = "staphb/snvphyl-tools:1.8.2"

    input:
    tuple val(meta), path(mpileup_bcf), path(freebayes_filtered_bcf), path(freebayes_filtered_csi)

    output:
    path( "${meta.id}_consolidated.bcf" ),     emit: consolidated_bcfs
    path( "${meta.id}_consolidated.vcf" ),     emit: consolidated_vcfs
    path( "${meta.id}_consolidated.bcf.csi" ), emit: consolidated_bcf_index
    path( "${meta.id}_filtered_density.txt" ), emit: filtered_densities
    path("versions.yml"),                      emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    consolidate_vcfs.pl --coverage-cutoff 5 --min-mean-mapping 30 --snv-abundance-ratio 0.75 --vcfsplit ${freebayes_filtered_bcf} --mpileup ${mpileup_bcf} --filtered-density-out ${prefix}_filtered_density.txt --window-size ${params.window_size} --density-threshold ${params.density_threshold} -o ${prefix}_consolidated.bcf > ${prefix}_consolidated.vcf
    bcftools index -f ${prefix}_consolidated.bcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snvphyl-tools:
        bcftools: \$( bcftools --version |& sed '1!d; s/^.*bcftools //' )
    END_VERSIONS
    """
}