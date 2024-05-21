/*
This source file is adapted from a nf-core pipeline for SNVPhyl developed by
Jill Hagey as a work of the United States Government, which was distributed as
a work within the public domain under the Apache Software License version 2.

This source file has been adapted to work within our pipeline.

Please refer to the README for more information.
*/
def VERSION = '1.8.2' // Version information not provided by tool on CLI

process VCF2SNV_ALIGNMENT {
    label 'process_high'
    container = "staphb/snvphyl-tools:1.8.2"

    input:
    val(bcf_metas)   // list of metas
    path(bcf_paths)  // list of paths
    path(new_invalid_positions)
    path(refgenome)
    path(consolidated_bcf_index)

    output:
    path('snvAlignment.phy'), emit: snvAlignment
    path('vcf2core.tsv'),     emit: vcf2core
    path('snvTable.tsv'),     emit: snvTable
    path("versions.yml"),     emit: versions

    script:
    // Decompress reference if necessary:
    def decompress_refgenome = refgenome.toString().endsWith(".gz") ? "gunzip -q -f '$refgenome'" : ""
    def refgenome_path = refgenome.toString().endsWith(".gz") ? refgenome.toString().split('.gz')[0] : refgenome

    def bcf_line = ""
    bcf_paths.eachWithIndex { path, i -> bcf_line += "--consolidate_vcf ${bcf_metas[i].id}=${path} " }

    """
    $decompress_refgenome

    vcf2snv_alignment.pl --reference reference --invalid-pos ${new_invalid_positions} --format fasta --format phylip --numcpus ${task.cpus} --output-base snvalign --fasta ${refgenome_path} ${bcf_line}
    mv snvalign-positions.tsv snvTable.tsv
    mv snvalign-stats.csv vcf2core.tsv
    if [[ -f snvalign.phy ]]; then
        mv snvalign.phy snvAlignment.phy
        sed -i "s/'//g" snvAlignment.phy
    else
        touch snvAlignment.phy
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        snvphyl-tools: 1.8.2
        perl: \$(perl --version | grep "This is perl" | sed 's/.*(\\(.*\\))/\\1/' | cut -d " " -f1)
    END_VERSIONS
    """
}
