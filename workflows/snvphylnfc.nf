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
include { INPUT_CHECK          } from '../subworkflows/local/input_check'
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
include { BGZIP_MPILEUP_VCF    } from '../modules/local/bgzipmpileupvcf/main'
include { BCFTOOLS_CALL        } from '../modules/local/bcftoolscall/main'
include { CONSOLIDATE_BCFS     } from '../modules/local/consolidatebcfs/main'
include { CONSOLIDATE_FILTERED_DENSITY } from '../modules/local/consolidatefiltereddensity/main'
include { VCF2SNV_ALIGNMENT    } from '../modules/local/vcf2snvalignment/main'
include { FILTER_STATS         } from '../modules/local/filterstats/main'
include { PHYML                } from '../modules/local/phyml/main'
include { MAKE_SNV             } from '../modules/local/makesnv/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow SNVPHYL {

    ch_versions = Channel.empty()

    // Create a new channel of metadata from a sample sheet
    // NB: `input` corresponds to `params.input` and associated sample sheet schema
    input = Channel.fromSamplesheet("input")
        // Map the inputs so that they conform to the nf-core-expected "reads" format.
        // Either [meta, [fastq_1]] or [meta, [fastq_1, fastq_2]] if fastq_2 exists
        .map { meta, fastq_1, fastq_2 ->
               fastq_2 ? tuple(meta, [ file(fastq_1), file(fastq_2) ]) :
               tuple(meta, [ file(fastq_1) ])}

    INDEXING(
        params.refgenome
    )
    ch_versions = ch_versions.mix(INDEXING.out.versions)

    FIND_REPEATS(
        params.refgenome
    )
    ch_versions = ch_versions.mix(FIND_REPEATS.out.versions)

    SMALT_MAP(
        input, INDEXING.out.ref_fai, INDEXING.out.ref_sma, INDEXING.out.ref_smi
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
        SORT_INDEX_BAMS.out.sorted_bams_and_sampleID, params.refgenome
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
        SORT_INDEX_BAMS.out.sorted_bams_and_sampleID, params.refgenome
    )
    ch_versions = ch_versions.mix(MPILEUP.out.versions)

    BGZIP_MPILEUP_VCF(
        MPILEUP.out.mpileup
    )
    ch_versions = ch_versions.mix(BGZIP_MPILEUP_VCF.out.versions)

    BCFTOOLS_CALL(
        BGZIP_MPILEUP_VCF.out.mpileup_zipped
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
    CONSOLIDATE_FILTERED_DENSITY(
        CONSOLIDATE_BCFS.out.filtered_densities.collect(), FIND_REPEATS.out.repeats_bed_file
    )
    ch_versions = ch_versions.mix(CONSOLIDATE_FILTERED_DENSITY.out.versions)

    //13. consolidate variant calling files process takes 2 input channels as arguments
    VCF2SNV_ALIGNMENT(
        CONSOLIDATE_BCFS.out.consolidated_bcfs.toList(), CONSOLIDATE_FILTERED_DENSITY.out.new_invalid_positions, params.refgenome, CONSOLIDATE_BCFS.out.consolidated_bcf_index.collect()
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


    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )
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
