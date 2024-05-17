/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process FIND_REPEATS {
    tag "${refgenome}"
    label 'process_low'
    container = "staphb/snvphyl-tools:1.8.2"

    input:
    path(refgenome)

    output:
    path("invalid_positions.bed"),    emit: repeats_bed_file
    path("versions.yml"),             emit: versions

    script:
    // Decompress reference if necessary:
    def decompress_refgenome = refgenome.toString().endsWith(".gz") ? "gunzip -q -f '$refgenome'" : ""
    def refgenome_path = refgenome.toString().endsWith(".gz") ? refgenome.toString().split('.gz')[0] : refgenome

    """
    $decompress_refgenome

    find-repeats.pl ${refgenome_path} --min-length ${params.min_repeat_length} --min-pid ${params.min_repeat_pid} > invalid_positions.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snvphyl-tools: 1.8.2
        perl: \$(perl --version | grep "This is perl" | sed 's/.*(\\(.*\\))/\\1/' | cut -d " " -f1)
    """
}
