/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process FILTER_FREEBAYES {
    tag "${meta.id}"
    label 'process_low'
    container "staphb/snvphyl-tools:1.8.2"

    input:
    tuple val(meta), path(freebayes_vcf)

    output:
    tuple val(meta), path( "${meta.id}_freebayes_filtered.vcf" ), emit: filtered_vcf
    path("versions.yml"),                                         emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    filterVcf.pl --noindels ${freebayes_vcf} -o ${prefix}_freebayes_filtered.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snvphyl-tools: 1.8.2
        perl: \$(perl --version | grep "This is perl" | sed 's/.*(\\(.*\\))/\\1/' | cut -d " " -f1)
    END_VERSIONS
    """
}
