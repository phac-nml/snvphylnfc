/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process INDEXING {
    tag "${refgenome}"
    label 'process_low'
    container = "staphb/smalt:0.7.6"

    input:
    path(refgenome)

    output:
    path('*.fai'),        emit: ref_fai
    path('*.sma'),        emit: ref_sma
    path('*.smi'),        emit: ref_smi
    path("versions.yml"), emit: versions

    script:
    """
    REF_BASENAME=\$(basename ${refgenome} .fasta)
    smalt index -k 13 -s 6 \${REF_BASENAME} ${refgenome}
    samtools faidx ${refgenome}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        smalt: \$( smalt version | grep "Version:" | sed 's/Version://' )
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}