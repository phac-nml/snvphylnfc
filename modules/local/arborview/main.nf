/*
Generates a visualization of a dendogram alongside metadata.
*/


process ARBOR_VIEW {
    label "process_low"
    tag "Inlining Tree Data"
    stageInMode 'copy' // Need to copy in arbor view html

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python%3A3.12' :
        'biocontainers/python:3.12' }"

    input:
    tuple path(tree), path(contextual_data)
    path(arbor_view) // need to make sure this is copied


    output:
    path(output_value),  emit: html
    path "versions.yml", emit: versions


    script:
    output_value = "SNVPhyl_ArborView.html"
    """
    inline_arborview.py -d ${contextual_data} -n ${tree} -o ${output_value} -t ${arbor_view}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ArborView : \$(sed -n 's/.*<meta name="version" content="\\([^"]*\\)".*/\\1/p' ${arbor_view})
    END_VERSIONS
    """

}
