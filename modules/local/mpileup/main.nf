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
    container "staphb/bcftools:1.14"

    input:
    tuple val(meta), path(sorted_bams)
    path(refgenome)

    output:
    tuple val(meta), path( "${meta.id}_mpileup.vcf.gz" ), emit: mpileup
    path("versions.yml"),                                 emit: versions

    script:
    // Decompress reference if necessary:
    def decompress_refgenome = refgenome.toString().endsWith(".gz") ? "gunzip -q -f '$refgenome'" : ""
    def refgenome_path = refgenome.toString().endsWith(".gz") ? refgenome.toString().split('.gz')[0] : refgenome

    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    $decompress_refgenome

    bcftools mpileup --threads ${task.cpus} --fasta-ref ${refgenome_path} -A -B -C 0 -d 1024 -q 0 -Q 0 --output-type z -I --output ${prefix}_mpileup.vcf.gz ${sorted_bams}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$( bcftools --version |& sed '1!d; s/^.*bcftools //' )
    END_VERSIONS
    """
}
