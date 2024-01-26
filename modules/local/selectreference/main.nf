process SELECT_REFERENCE {
    label 'process_single'

    input:
    val(parameters)
    val(sample_assemblies)

    output:
    val(reference_genome)

    exec:
    refgenome = parameters.refgenome
    reference_sample_name = parameters.reference_sample_name

    // A "--refgenome" parameter was provided:
    if( refgenome != null ) {
        reference_genome = refgenome
        log.info("The '--reference_genome' parameter was provided and ${reference_genome} was selected as the reference.")
    }
    // A "--reference_sample_name" parameter was provided:
    else if (reference_sample_name != null) {

        // Check to see if the sample ID exists:
        if (sample_assemblies.containsKey(reference_sample_name)) {

            // Check if the sample ID maps to an assembly path:
            // Use the value (the assembly path) associated with the key (the sample name).
            if (sample_assemblies[reference_sample_name] != null) {
                reference_genome = sample_assemblies[reference_sample_name]
                log.info("The '--reference_sample_name' parameter was provided and ${reference_genome} was selected as the reference.")
            }
            // The sample ID exists, but has no corresponding assembly path:
            else {
                log.error("Unable to select a reference. The sample ID (${reference_sample_name}) has no associated assembly to use as a reference.")
            }            
        }
        // The sample ID does not exist:
        else {
            log.error("Unable to select a reference. The sample ID (${reference_sample_name}) does not exist.")
        }
    }
    // Neither a "--refgenome" nor a "--reference_sample_name" were provided:
    else {
        log.error("Unable to select a reference. Neither a '--refgenome' nor a '--reference_sample_name' parameter were provided.")
    }
}