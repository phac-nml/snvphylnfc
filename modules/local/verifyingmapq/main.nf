/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process VERIFYING_MAP_Q {
    tag ""
    label 'process_single'
    container = "staphb/snvphyl-tools:1.8.2"

    input:
    path(sorted_bams)
    val(bam_line)

    output:
    path("mappingQuality.txt"), emit: mapping_quality
    path("versions.yml"),       emit: versions

    script:
    """
    verify_mapping_quality.pl -c 4 --min-depth 5 --min-map 80 --output mappingQuality.txt ${bam_line} 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snvphyl-tools:
        perl: \$(perl --version | grep "This is perl" | sed 's/.*(\\(.*\\))/\\1/' | cut -d " " -f1)
    END_VERSIONS
    """
}