/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process FREEBAYES {
    tag "$meta.id"
    label 'process_low'
    container = "staphb/freebayes:1.3.6"

    input:
    tuple val(meta), path(sorted_bams)
    path(refgenome)

    output:
    tuple val(meta), path( "${meta.id}_freebayes.vcf" ), emit: vcf_files
    path("versions.yml"),                                emit: versions

    script:
    // Decompress reference if necessary:
    def decompress_refgenome = refgenome.toString().endsWith(".gz") ? "gunzip -q -f '$refgenome'" : ""
    def refgenome_path = refgenome.toString().endsWith(".gz") ? refgenome.toString().split('.gz')[0] : refgenome

    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    $decompress_refgenome

    freebayes --bam ${sorted_bams} --ploidy 1 --fasta-reference ${refgenome_path} --vcf ${prefix}_freebayes.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        freebayes: \$(echo \$(freebayes --version 2>&1) | sed 's/version:\s*v//g' )
    END_VERSIONS
    """
}
