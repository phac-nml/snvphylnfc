/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process CONSOLIDATE_FILTERED_DENSITY {
    label 'process_low'
    container = 'docker.io/python:3.9.17'

    input:
    path(filtered_densities)
    path(invalid_positions)

    output:
    path('filtered_density_all.txt'),   emit: filtered_densities
    path('new_invalid_positions.bed'),  emit: new_invalid_positions
    path("versions.yml"),               emit: versions

    script:
    """
    find ./ -name '*_filtered_density.txt' -exec cat {} + > filtered_density_all.txt
    catWrapper.py new_invalid_positions.bed filtered_density_all.txt ${invalid_positions}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
