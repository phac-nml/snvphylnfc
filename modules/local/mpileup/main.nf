/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process MPILEUP {
    tag "${meta.id}"
    label 'process_low'
    container = "staphb/bcftools:1.14"

    input:
    tuple val(meta), path(sorted_bams)
    path(refgenome)

    output:
    tuple val(meta), path( "${meta.id}_mpileup.vcf" ), emit: mpileup
    path("versions.yml"),                              emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    bcftools mpileup --threads 4 --fasta-ref ${refgenome} -A -B -C 0 -d 1024 -q 0 -Q 0 --output-type v -I --output ${prefix}_mpileup.vcf ${sorted_bams}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$( bcftools --version |& sed '1!d; s/^.*bcftools //' )
    END_VERSIONS
    """
}