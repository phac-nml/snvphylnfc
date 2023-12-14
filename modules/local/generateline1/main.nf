/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process GENERATE_LINE_1 {
    label 'process_low'
    container 'docker.io/python:3.9.17'

    input:
    path(sorted_bams)

    output:
    path("bam_line.txt"), emit: bam_lines_file
    //path("versions.yml"), emit: versions

    shell:
    '''
    #! /bin/bash -l
    count=0 
    for f in *_sorted.bam
    do
    ((count++))
    echo "--bam bam\$count=./$f " | tr -d "\n" >> bam_line.txt
    done
    '''
}