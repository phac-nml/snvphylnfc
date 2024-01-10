/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process GENERATE_LINE_2 {
    label 'process_low'
    container 'docker.io/python:3.9.17'

    input:
    path(consolidated_bcf)

    output:
    path("consolidation_line.txt"), emit: consolidation_line
    //path("versions.yml"),           emit: versions

    shell:
    '''
    #! /bin/bash -l
    for f in *_consolidated.bcf
    do
    fname=\$(basename $f _consolidated.bcf)
    echo "--consolidate_vcf \$fname=$f " | tr -d "\n" >> consolidation_line.txt
    done
    '''
}
