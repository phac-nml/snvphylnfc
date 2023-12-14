/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process BGZIP_MPILEUP_VCF {
    tag "${meta.id}"
    label 'process_low'
    container = "staphb/htslib:1.15"

    input:
    tuple val(meta), path(mpileup_vcf)

    output:
    tuple val(meta), path("${meta.id}_mpileup.vcf.gz"), emit: mpileup_zipped
    path("versions.yml"),                               emit: versions

    script:
    """
    bgzip -f ${mpileup_vcf}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bgzip (htslib): \$( bgzip --version | head --lines 1 | sed 's/bgzip (htslib) //' )
    END_VERSIONS
    """
}