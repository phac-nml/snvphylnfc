#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    phac-nml/snvphylnfc
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/phac-nml/snvphylnfc
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE & PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

process MAX_SAMPLES_CHECK {
    tag "max_samples_error"
    publishDir "${params.outdir}/error"

    input:
    val sample_count // number of samples provided to mikrokondo

    output:
    path output_file_path, emit: failure_report
    path "versions.yml", emit: versions

    exec:
    def output_file =  "max_samples_exceeded.error.txt"
    output_file_path = task.workDir.resolve(output_file)
    file_out = file(output_file_path)
    file_out.text = """
    ${sample_count} samples were selected, which exceeds the maximum number of samples: ${params.max_samples}
    Please reduce samples to ${params.max_samples}.
    Pipeline maximum sample count threshold should only occur when running in IRIDA Next,
    please submit an issue if you encounter it elsewhere.

    If running from command-line make sure that --max_samples 0
    """.stripIndent().trim()

    def version_file =  "versions.yml"
    version_file_path = task.workDir.resolve(version_file)
    version_file_out = file(version_file_path)
    version_file_out.text = """
    MAX_SAMPLES : 0.1.0
    """.stripIndent().trim()
}

include { SNVPHYL } from './workflows/snvphylnfc'
include { validateParameters; paramsHelp; paramsSummaryLog; fromSamplesheet } from 'plugin/nf-validation'

// Print help message if needed
if (params.help) {
    def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
    def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
    def String command = "nextflow run ${workflow.manifest.name} --input samplesheet.csv --genome GRCh37 -profile docker"
    log.info logo + paramsHelp(command) + citation + NfcoreTemplate.dashedLine(params.monochrome_logs)
    System.exit(0)
}

// Validate input parameters
if (params.validate_params) {
    validateParameters()
}

WorkflowMain.initialise(workflow, params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MAX_SAMPLES CHECK
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Dont bother checking the number of lines in the samples if max_samples == 0
    as we will not do anything with the limit.
*/

    def number_of_samples = file(params.input).readLines().size() - 1 // Remove 1 for header
    def unlimited_samples = (params.max_samples == 0) ? true : false

//
// WORKFLOW: Run main phac-nml/snvphylnfc analysis pipeline
//

    workflow PHACNML_SNVPHYL {
    if( unlimited_samples || number_of_samples <= params.max_samples){
        SNVPHYL ()
    }else{
        MAX_SAMPLES_CHECK(channel.value(number_of_samples))
        log.info "Parameter --max_samples was set: See outdir/error/max_samples_exceeded.error.txt for more information."

    }}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {
    PHACNML_SNVPHYL ()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
