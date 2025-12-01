/*
This source file includes source from a nf-core pipeline for SNVPhyl developed
by Jill Hagey as a work of the United States Government, which was distributed
as a work within the public domain under the Apache Software License version 2.

The work by Jill Hagey has been adapted such that we utilize the modules and
module calls in the original source work, but make changes such the pipeline
functions according to our desired specifications and outcomes.

Please refer to the README for more information.
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMS SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { paramsSummaryLog; paramsSummaryMap; fromSamplesheet  } from 'plugin/nf-validation'

def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
def summary_params = paramsSummaryMap(workflow)

// Print parameter summary log to screen
log.info logo + paramsSummaryLog(workflow) + citation

WorkflowSnvphylnfc.initialise(params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { INDEXING             } from '../modules/local/indexing/main'
include { FIND_REPEATS         } from '../modules/local/findrepeats/main'
include { SMALT_MAP            } from '../modules/local/smaltmap/main'
include { SORT_INDEX_BAMS      } from '../modules/local/sortindexbams/main'
include { VERIFYING_MAP_Q      } from '../modules/local/verifyingmapq/main'
include { FREEBAYES            } from '../modules/local/freebayes/main'
include { FILTER_FREEBAYES     } from '../modules/local/filterfreebayes/main'
include { BGZIP_FREEBAYES_VCF  } from '../modules/local/bgzipfreebayesvcf/main'
include { FREEBAYES_VCF_TO_BCF } from '../modules/local/freebayesvcftobcf/main'
include { MPILEUP              } from '../modules/local/mpileup/main'
include { BCFTOOLS_CALL        } from '../modules/local/bcftoolscall/main'
include { CONSOLIDATE_BCFS     } from '../modules/local/consolidatebcfs/main'
include { VCF2SNV_ALIGNMENT    } from '../modules/local/vcf2snvalignment/main'
include { FILTER_STATS         } from '../modules/local/filterstats/main'
include { PHYML                } from '../modules/local/phyml/main'
include { MAKE_SNV             } from '../modules/local/makesnv/main'
include { WRITE_METADATA      } from '../modules/local/writemetadata/main'
include { ARBOR_VIEW           } from '../modules/local/arborview/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'
include { CAT_CAT                     } from '../modules/nf-core/cat/cat/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow SNVPHYL {

    ch_versions = Channel.empty()

    // Track processed IDs
    def processedIDs = [] as Set

    // Create a new channel of metadata from a sample sheet
    // NB: `input` corresponds to `params.input` and associated sample sheet schema
    input = Channel.fromSamplesheet("input")
        // Map the inputs so that they conform to the nf-core-expected "reads" format.
        // Either [meta, [fastq_1], reference_assembly]
        // or [meta, [fastq_1, fastq_2], reference_assembly] if fastq_2 exists
        // and remove non-alphanumeric characters in sample_names (meta.id), whilst also correcting for duplicate sample_names (meta.id)
        .map { meta, fastq_1, fastq_2, reference_assembly ->
            if (!meta.id) {
                meta.id = meta.irida_id
            } else {
                // Non-alphanumeric characters (excluding _,-,.) will be replaced with "_"
                meta.id = meta.id.replaceAll(/[^A-Za-z0-9_.\-]/, '_')
            }
            // Ensure ID is unique by appending meta.irida_id if needed
            while (processedIDs.contains(meta.id)) {
                meta.id = "${meta.id}_${meta.irida_id}"
            }
            // Add the ID to the set of processed IDs
            processedIDs << meta.id

            fastq_2 ? tuple(meta, [ file(fastq_1), file(fastq_2) ], reference_assembly) :
            tuple(meta, [ file(fastq_1) ], file(reference_assembly))}


    // Channel of read tuples (meta, [fastq_1, fastq_2*]):
    reads = input.map { meta, reads, reference_assembly -> tuple(meta, reads) }

    // Channel of sample tuples (meta, assembly):
    sample_assemblies = input.map { meta, reads, reference_assembly -> tuple(meta, reference_assembly ? reference_assembly : null) }

    // Check to see if a single reference genome was selected
    def lines = file(params.input).readLines()
    def num_rows = lines.size()
    def headers = lines[0].split(',')
    def num_columns = headers.size()
    def refIndex = headers.findIndexOf { it == 'reference_assembly' }
    def number_of_references = 0
    def reference_to_use = null

    for (int i = 1; i < num_rows; i++) {
        def parts = lines[i].split(',', -1)  // -1 preserves trailing empty strings
        ref = parts.size() > refIndex ? parts[refIndex] : null
        if (!(ref.isEmpty())) {
            ++number_of_references
            reference_to_use = ref
        }

        if (number_of_references > 1) {
            reference_to_use = null
            break
        }
    }
    // If more than one reference genome is assigned then look to other options.
    if (reference_to_use.isEmpty()) {
        reference_genome = select_reference(params.refgenome, params.reference_sample_id, sample_assemblies)
    }
    else {
        reference_genome = reference_to_use
    }

    INDEXING(
        reference_genome
    )
    ch_versions = ch_versions.mix(INDEXING.out.versions)

    FIND_REPEATS(
        reference_genome
    )
    ch_versions = ch_versions.mix(FIND_REPEATS.out.versions)

    SMALT_MAP(
        reads, INDEXING.out.ref_fai, INDEXING.out.ref_sma, INDEXING.out.ref_smi
    )
    ch_versions = ch_versions.mix(SMALT_MAP.out.versions)

    SORT_INDEX_BAMS(
        SMALT_MAP.out.bams
    )
    ch_versions = ch_versions.mix(SORT_INDEX_BAMS.out.versions)

    VERIFYING_MAP_Q(
        SORT_INDEX_BAMS.out.sorted_bams.collect()
    )
    ch_versions = ch_versions.mix(VERIFYING_MAP_Q.out.versions)

    FREEBAYES(
        SORT_INDEX_BAMS.out.sorted_bams_and_sampleID, reference_genome
    )
    ch_versions = ch_versions.mix(FREEBAYES.out.versions)

    FILTER_FREEBAYES(
        FREEBAYES.out.vcf_files
    )
    ch_versions = ch_versions.mix(FILTER_FREEBAYES.out.versions)

    // TODO: Is there a better way of doing this? In the last step?
    BGZIP_FREEBAYES_VCF(
        FILTER_FREEBAYES.out.filtered_vcf
    )
    ch_versions = ch_versions.mix(BGZIP_FREEBAYES_VCF.out.versions)

    FREEBAYES_VCF_TO_BCF(
        BGZIP_FREEBAYES_VCF.out.filtered_zipped_vcf
    )
    ch_versions = ch_versions.mix(FREEBAYES_VCF_TO_BCF.out.versions)

    MPILEUP(
        SORT_INDEX_BAMS.out.sorted_bams_and_sampleID, reference_genome
    )
    ch_versions = ch_versions.mix(MPILEUP.out.versions)

    BCFTOOLS_CALL(
        MPILEUP.out.mpileup
    )
    ch_versions = ch_versions.mix(BCFTOOLS_CALL.out.versions)

    //Joining channels of multiple outputs
    combined_ch = BCFTOOLS_CALL.out.mpileup_bcf.join(FREEBAYES_VCF_TO_BCF.out.filtered_bcf)

    //11. consolidate variant calling files process takes 2 input channels as arguments
    CONSOLIDATE_BCFS(
        combined_ch
    )
    ch_versions = ch_versions.mix(CONSOLIDATE_BCFS.out.versions)

    // Concat filtered densities to make new invalid_postions
    invalid_positions = CONSOLIDATE_BCFS.out.filtered_densities
        .concat(FIND_REPEATS.out.repeats_bed_file)
        .collect().map{it -> [[id: 'cat_invalid_positions'], it]}

    CAT_CAT(invalid_positions)

    invalid_positions_file = CAT_CAT.out.file_out.map{meta, filepath -> filepath}
    consolidated_bcfs = CONSOLIDATE_BCFS.out.consolidated_bcfs.toSortedList{a, b -> a[0].id <=> b[0].id}

    // consolidated_bcfs is a list of [meta, filepath] tuples
    // the first .collect{} iterates once, because there is only one item (one list) in the channel
    // the second .collect{} transforms each item in the list with the operation
    consolidated_bcfs_metas = consolidated_bcfs.collect{ it.collect { it[0] } }
    consolidated_bcfs_paths = consolidated_bcfs.collect{ it.collect { it[1] } }

    //13. consolidate variant calling files
    VCF2SNV_ALIGNMENT(
        consolidated_bcfs_metas, consolidated_bcfs_paths, invalid_positions_file, reference_genome,
        CONSOLIDATE_BCFS.out.consolidated_bcf_index.collect()
    )
    ch_versions = ch_versions.mix(VCF2SNV_ALIGNMENT.out.versions)

    //14. Filter Stats
    FILTER_STATS(
        VCF2SNV_ALIGNMENT.out.snvTable
    )
    ch_versions = ch_versions.mix(FILTER_STATS.out.versions)

    //15. Using phyml to build tree process takes 1 input channel as an argument
    PHYML(
        VCF2SNV_ALIGNMENT.out.snvAlignment
    )
    ch_versions = ch_versions.mix(PHYML.out.versions)

    //16. Make SNVMatix.tsv
    MAKE_SNV(
        VCF2SNV_ALIGNMENT.out.snvAlignment
    )
    ch_versions = ch_versions.mix(MAKE_SNV.out.versions)

    // 17. Generate the metadata.tsv file and process it with the ArborView HTML app
    SAMPLE_HEADER = "id"
    metadata_headers = Channel.of(
        tuple(
            SAMPLE_HEADER,
            params.metadata_1_header, params.metadata_2_header,
            params.metadata_3_header, params.metadata_4_header,
            params.metadata_5_header, params.metadata_6_header,
            params.metadata_7_header, params.metadata_8_header,
            params.metadata_9_header, params.metadata_10_header,
            params.metadata_11_header, params.metadata_12_header,
            params.metadata_13_header, params.metadata_14_header,
            params.metadata_15_header, params.metadata_16_header)
        )

    metadata_rows = input.map { meta, reads, reference_assembly ->
        tuple(meta.id, meta.metadata_1, meta.metadata_2,
        meta.metadata_3, meta.metadata_4, meta.metadata_5,
        meta.metadata_6, meta.metadata_7, meta.metadata_8,
        meta.metadata_9, meta.metadata_10, meta.metadata_11, meta.metadata_12,
        meta.metadata_13, meta.metadata_14, meta.metadata_15, meta.metadata_16)}.toList()
    metadata = WRITE_METADATA(metadata_headers, metadata_rows)

    tree_data = PHYML.out.phylogeneticTree.merge(metadata)
    tree_html = file("$projectDir/assets/ArborView.html")

    ARBOR_VIEW(tree_data, tree_html)
    ch_versions = ch_versions.mix(ARBOR_VIEW.out.versions)

    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SELECT REFERENCE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def select_reference(refgenome, reference_sample_id, sample_assemblies) {
    def single_ref = null
    reference_genome_count = sample_assemblies.map { meta, reference_assembly -> reference_assembly }.count() // Used later to check that not more than one reference genome has been selected in the samplesheet
    single_reference = reference_genome_count.subscribe { count_val ->
        if (count_val == 1) {
            single_ref = true
        }
    }

    if(refgenome) {
        reference_genome = Channel.value(file(refgenome))
        log.debug "Selecting reference genome ${reference_genome} from '--refgenome'."
    }
    else if ( single_ref ) {
        reference_genome = sample_assemblies.map { it[1] }.first()
        log.debug "Selecting reference genome ${reference_genome} from single reference genome"
    }
    else if (reference_sample_id) {
        // Check each meta category (meta.id, meta.id_alt, meta.irida_id) for a match to params.reference_sample_id
        reference_genome = sample_assemblies.filter { (it[0].id == reference_sample_id || it[0].irida_id == reference_sample_id || it[0].id_alt == reference_sample_id) && it[1] != null}
                                            .ifEmpty { error("The provided reference sample ID (${reference_sample_id}) is either missing or has no associated reference assembly.") }
                                            .map { it[1] }
                                            .first()
        log.debug "Selecting reference genome ${reference_genome} from '--reference_sample_id'."
    }
    else {
        error("Unable to select a reference. Neither '--refgenome' nor '--reference_sample_id' were provided.")
    }

    return reference_genome
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log)
    }
    NfcoreTemplate.dump_parameters(workflow, params)
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
