/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
process PHYML {
    label 'process_low'
    //container = "staphb/phyml:3.3.20220408"
    container = "https://depot.galaxyproject.org/singularity/phyml:3.3.20211231--hee9e358_0"

    input:
    path(snvAlignment_phy)

    output:
    path('phylogeneticTree.newick'),   emit: phylogeneticTree
    path('phylogeneticTreeStats.txt'), emit: phylogeneticTreeStats
    path("versions.yml"),              emit: versions

    script:
    """
    phyml -i ${snvAlignment_phy} --datatype nt --model GTR -v 0.0 --ts/tv e --nclasses 4 --alpha e --bootstrap -4 --quiet
    mv snvAlignment.phy_phyml_stats.txt phylogeneticTreeStats.txt
    mv snvAlignment.phy_phyml_tree.txt phylogeneticTree.newick

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        phyml: \$( phyml --version | grep -P -o '[0-9]+.[0-9]+.[0-9]+' )
    END_VERSIONS
    """
}
