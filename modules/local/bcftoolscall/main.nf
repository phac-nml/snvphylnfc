/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process BCFTOOLS_CALL {
    tag "${meta.id}"
    label 'process_low'
    container = "staphb/bcftools:1.15"

    input:
    tuple val(meta), path(mpileup_vcf_gz)

    output:
    tuple val(meta), path("${meta.id}_mpileup.bcf"), emit: mpileup_bcf
    path("versions.yml"),                            emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    bcftools index -f ${mpileup_vcf_gz}
    bcftools call --ploidy 1 --threads ${$task.cpus} --output ${prefix}_mpileup.bcf --output-type b --consensus-caller ${mpileup_vcf_gz}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$( bcftools --version |& sed '1!d; s/^.*bcftools //' )
    END_VERSIONS
    """
}
