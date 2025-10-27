process WRITE_METADATA {
    tag "write_metadata"
    label 'process_single'

    input:
    val metadata_headers  // headers to name the metadata columns
    val metadata_rows  // metadata rows (no headers) to be appened, list of lists

    output:
    path("metadata.tsv"), emit: metadata

    exec:
    def merged = [metadata_headers] + metadata_rows
    def transposed = merged.transpose()
    def merged_filtered = transposed.findAll { column ->
            def header = column.head()
            def dataOnly = column.tail()
            def isMetadata = (header ==~ /metadata_([1-9]|1[0-6])/) //Checkif the metadata field was modified, if so keep even if empty
            !isMetadata || dataOnly.any { it != '' } // Keep null values just remove columns with only empty rows
        }
    def merged_cleaned = merged_filtered.transpose()

    task.workDir.resolve("metadata.tsv").withWriter { writer ->
        merged_cleaned.each { writer.writeLine it.join("\t")
    }
    }
}
