/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process SMALT_MAP {
    tag "$meta.id"
    label 'process_medium'
    container = "staphb/smalt:0.7.6"

    input:
    tuple val(meta), path(reads)
    path(ref_fai)
    path(ref_sma)
    path(ref_smi)

    output:
    tuple val(meta), path("${meta.id}.bam"), emit: bams
    path("versions.yml"),                    emit: versions

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def smalt_map_command = reads[1] ? "smalt map -f bam -n ${task.cpus} -l pe -i 1000 -j 20 -r 1 -y 0.5 -o ${prefix}.bam \${REFNAME} ${reads[0]} ${reads[1]}": "smalt map -f bam -n ${task.cpus} -r 1 -y 0.5 -o ${prefix}.bam \${REFNAME} ${reads[0]}"
    """
    REFNAME=\$(basename ${ref_sma} .sma)
    ${smalt_map_command}
    smalt version

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        smalt: \$( smalt version | grep "Version:" | sed 's/Version://' )
    END_VERSIONS
    """
}
