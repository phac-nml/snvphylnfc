/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process SORT_INDEX_BAMS {
    tag "$meta.id"
    label 'process_low'
    container = "staphb/samtools:1.9"

    input:
    tuple val(meta), path(bams)

    output:
    tuple val(meta), path( "${meta.id}_sorted.bam" ), emit: sorted_bams_and_sampleID
    path( "${meta.id}_sorted.bam" ),                  emit: sorted_bams
    path("versions.yml"),                             emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    samtools sort -O bam -o ${prefix}_sorted.bam ${bams}
    samtools index ${prefix}_sorted.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
