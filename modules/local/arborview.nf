process ARBOR_VIEW {
    label "process_single"
    tag "Inlining Tree Data"
    stageInMode 'copy' // Need to copy in arbor view html

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    "https://depot.galaxyproject.org/singularity/python%3A3.12" :
    "biocontainers/python:3.12" }"

    input:
    tuple path(tree), path(metadata)
    path(arbor_view) // need to make sure this is copied

    output:
    path(output_value), emit: html


    script:
    output_value = "SNVPhyl_ArborView.html"
    """
    inline_arborview.py -d ${metadata} -n ${tree} -o ${output_value} -t ${arbor_view}
    """
}
