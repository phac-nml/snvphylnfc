# phac-nml/snvphylnfc: Output

## Introduction

This document describes the output produced by the pipeline.

The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.

- `bcftools`
- `bgzip`
- `cat`
- `consolidate`
- `filter`
- `find`
- `freebayes`
- `indexing`
- `make`
- `mpileup`
- `phyml`
- `pipeline_info`
- `smalt`
- `sort`
- `vcf2snv`
- `verifying`

The IRIDA Next-compliant JSON output file will be named `iridanext.output.json.gz` and will be written to the top-level of the results directory. This file is compressed using GZIP and conforms to the [IRIDA Next JSON output specifications](https://github.com/phac-nml/pipeline-standards).

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- Indexing
- Find repeats
- SMALT map
- Sort index BAMs
- Verifying map quality
- Freebayes
- Filter freebayes
- BGZIP Freebayes VCFs
- Freebayes VCF to BCF
- mpileup
- bcftools call
- Consolidate BCFs
- CAT
- VCF2SNV alignment
- Filter stats
- PhyML
- Make SNV
