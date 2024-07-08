process WRITE_METADATA {
    tag "write_metadata"
    label 'process_single'

    input:
    val metadata_headers  // headers to name the metadata columns
    val metadata_rows  // metadata rows (no headers) to be appened, list of lists

    output:
    path("metadata.tsv"), emit: metadata

    exec:
    task.workDir.resolve("metadata.tsv").withWriter { writer ->
        writer.writeLine("id\t" + metadata_headers.join('\t'))
        metadata_rows.each { row ->
            writer.writeLine(row.join('\t'))
        }
    }
}
