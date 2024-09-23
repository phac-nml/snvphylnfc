[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A523.04.3-brightgreen.svg)](https://www.nextflow.io/)

# SNVPhyl nf-core Pipeline

This is the [nf-core](https://nf-co.re/)-based pipeline for [SNVPhyl](https://snvphyl.readthedocs.io/en/). The SNVPhyl (Single Nucleotide Variant PHYLogenomics) pipeline identifies Single Nucleotide Variants (SNV) within a collection of microbial genomes and constructs a phylogenetic tree from those SNVs. This pipeline is designed to be integrated into [IRIDA Next](https://github.com/phac-nml/irida-next). However, it may be run as a stand-alone pipeline.

# Input

Input is provided to SNVPhyl in the form of a samplesheet (passed as `--input samplesheet.csv`). This samplesheet is a CSV-formated file, which may be provided as a URI (ex: a file path or web address), and has the following format:

| sample  | sample_name  | fastq_1                    | fastq_2                    | reference_assembly           | metadata_1 | metadata_2 | metadata_3 | metadata_4 | metadata_5 | metadata_6 | metadata_7 | metadata_8 |
| ------- | ------------ | -------------------------- | -------------------------- | ---------------------------- | ---------- | ---------- | ---------- | ---------- | ---------- | ---------- | ---------- | ---------- |
| SAMPLE1 | sample_name1 | /path/to/sample1_fastq1.fq | /path/to/sample1_fastq2.fq | /path/to/sample1_assembly.fa | meta1      | meta2      | meta3      | meta4      | meta5      | meta6      | meta7      | meta8      |
| SAMPLE2 | sample_name2 | /path/to/sample2_fastq1.fq |                            |                              | meta1      | meta2      | meta3      | meta4      | meta5      | meta6      | meta7      | meta8      |

The columns are defined as follows:

- `sample`: Mandatory unique sample identifier. The unique sample identifier to associate with the reads (and optionally the reference assembly).
- `sample_name`: Optional, and overrides `sample` for outputs (filenames and sample names) and reference assembly identification.
- `fastq_1`: A URI (ex: a file path or web address) to either single-end FASTQ-formatted reads or one pair of pair-end FASTQ-formatted reads.
- `fastq_2`: (Optional) If `fastq_1` is paired-end, then this field is a URI to reads that are the other pair of reads associated with `fastq_1`.
- `reference_assembly`: (Optional) A URI to a reference assembly associated with the sample, so that it may be referenced on the command line by the sample identifier for use as the reference for the whole pipeline. However, it may be easier to leave these fields blank and specify the reference using the `--refgenome` parameter.
- `metadata_1...8`: (Optional) Permits up to 8 columns for user-defined contextual metadata associated with each `sample`. Refer to [Metadata](#metadata) for more information.

### When to use `sample` vs `sample_name`

Either can be used to identify the reference assembly with the parameter `--reference_sample_id`.

`sample` is a unique identifier, designed to be used internally or in IRIDA-Next, or when `sample_name` is not provided.

`sample_name`, allows more flexibility in naming output files or sample identification. Unlike `sample`, `sample_name` is not required to contain unique values. `Nextflow` requires unique sample names, and therefore in the instance of repeat `sample_names`, `sample` will be suffixed to any `sample_name`. Non-alphanumeric characters (excluding `_`,`-`,`.`) will be replaced with `"_"`.

The structure of this file is defined in [assets/schema_input.json](assets/schema_input.json). Please see [assets/samplesheet.csv](assets/samplesheet.csv) to see an example of a samplesheet for this pipeline.

# Parameters

## Mandatory

The mandatory parameters are as follows:

- `--input`: a URI to the samplesheet
- `--output`: the directory for pipeline output

Additionally, it is mandatory to have one of either `--refgenome` or `--reference_sample_id` (but not both) to specify the reference. Please see the Reference section for more details.

## Metadata

In order to customize metadata headers, the parameters `--metadata_1_header` through `--metadata_8_header` may be specified. These parameters are used to re-name the headers in the final metadata table from the defaults (e.g., rename `metadata_1` to `country`).

## Optional

The optional parameters are as follows:

### Reference

- `--refgenome`: a URI to the reference genome to use during pipeline analysis
- `--reference_sample_id`: the sample identifier of a sample (`sample` or `sample_name`) in the samplesheet that contains a provided `reference_assembly` to use as a reference genome during pipeline analysis

Please use only one of `--refgenome` or `--reference_sample_id` and not both.

### SNVPhyl Parameters

- `--window_size`: The window size for determining whether a region is high density.
- `--density_threshold`: The minimum number of SNVs within the window size for a region to be considered high density.
- `--min_coverage_depth`: The minimum depth of coverage for a position within the genome to pass the mapping quality check.
- `--min_mapping_percent_cov`: The total percentage of positions within the genome that must have a depth of coverage greater than the minimum depth of coverage specified in order to pass the mapping quality check.
- `--min_mean_mapping_quality`: The minimum mean mapping quality score for all reads in a pileup to be included in the analysis.
- `--snv_abundance_ratio`: The proportion of reads required to support a variant to be included in the analysis.
- `--min_repeat_length`: The minimum length when identifying repeats on the reference genome.
- `--min_repeat_pid`: The minimum percent identity when identifying repeats on the reference genome.
- `--skip_density_filter`: Whether or not to skip filtering low SNV density regions.

Please refer to the [SNVPhyl documentation](https://snvphyl.readthedocs.io/en/latest/) for more detailed information about pipeline parameters.

### Other Parameters

- `-profile`: specifies which profiles to use (ex: `-profile singularity`)
- `-r`: specifies which revision to use (ex: `-r dev`)

# Running

## Test Data

In order to run the pipeline with provided data, please run:

```
nextflow run phac-nml/snvphylnfc -profile singularity --input https://raw.githubusercontent.com/phac-nml/snvphylnfc/dev/assets/samplesheet.csv --refgenome https://raw.githubusercontent.com/phac-nml/snvphylnfc/dev/assets/reference.fasta --outdir results
```

The pipeline output will be written to a directory named `results`. A JSON file for integrating data with IRIDA Next will be written to `results/iridanext.output.json.gz` (please see the Output section for details).

It is also possible to run the pipeline using the test profile as follows:

```
nextflow run phac-nml/snvphylnfc -profile singularity,test --outdir results
```

# Output

## Results

The following output files are generated by the pipeline:

- `make/snvMatrix.tsv`: a pair-wise distance matrix of SNVs that passed all filtering criteria
- `filter/filterStats.txt`: a summary of the number of SNVs filtered within in the SNV Table
- `phyml/phylogeneticTree.newick`: the maximum likelihood phylogeny generated from an alignment of SNVs extracted from the whole genomes of each input file
- `phyml/phylogeneticTreeStats.txt`: statistics for the generated phylogenetic tree
- `arbor/SNVPhyl_ArborView.html`: an HTML file for examining the phylogenetic tree (.newick) dendrogram in the ArborView HTML app, complete with contextual metadata
- `vcf2snv/snvTable.tsv`: a table of all detected variant sites
- `vcf2snv/vcf2core.tsv`: a table of the evaluated core positions in each reference fasta sequence
- `vcf2snv/snvAlignment.phy`: an alignment of SNVs used to generate the phylogenetic tree
- `verifying/mappingQuality.txt`: describes how well the given reads mapped to the reference genome

For more detailed information, please refer to the [SNVPhyl Documentation](https://snvphyl.readthedocs.io/en/latest/user/output/).

## IRIDA Next Integration File

A JSON file for loading the data into IRIDA Next is output by this pipeline. The format of this JSON file is specified in our [Pipeline Standards for the IRIDA Next JSON](https://github.com/phac-nml/pipeline-standards#32-irida-next-json). This JSON file is written directly within the `--outdir` provided to the pipeline with the name `iridanext.output.json.gz` (ex: `[outdir]/iridanext.output.json.gz`).

```
{
    "files": {
        "global": [
            {
                "path": "arbor/SNVPhyl__ArborView.html"
            },
            {
                "path": "make/snvMatrix.tsv"
            },
            {
                "path": "filter/filterStats.txt"
            },
            {
                "path": "phyml/phylogeneticTreeStats.txt"
            },
            {
                "path": "phyml/phylogeneticTree.newick"
            },
            {
                "path": "vcf2snv/snvTable.tsv"
            },
            {
                "path": "vcf2snv/vcf2core.tsv"
            },
            {
                "path": "vcf2snv/snvAlignment.phy"
            },
            {
                "path": "verifying/mappingQuality.txt"
            }
        ],
        "samples": {

        }
    },
    "metadata": {
        "samples": {

        }
    }
}
```

Within the `files` section of this JSON file, all of the output paths are relative to the `--outdir results`. Therefore, `"path": "phyml/phylogeneticTree.newick"` refers to a file located within `results/phyml/phylogeneticTree.newick`.

# Legal

## nf-core

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> The nf-core framework for community-curated bioinformatics pipelines.
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> Nat Biotechnol. 2020 Feb 13. doi: 10.1038/s41587-020-0439-x.
> In addition, references of tools and data used in this pipeline are as follows:

## SNVPhyl NF-Core Pipeline

Copyright 2024 Government of Canada

Licensed under the MIT License (the "License"); you may not use
this work except in compliance with the License. You may obtain a copy of the
License at:

https://opensource.org/license/mit/

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

## Derivative Work

This pipeline includes source code from a [nf-core pipeline for SNVPhyl](https://github.com/DHQP/SNVPhyl_Nextflow) developed by Jill Hagey as a work of the United States Government that was not subject to domestic copyright protection under 17 USC § 105. This work by the United States Government is in the public domain within the United States, and copyright and related rights for the work worldwide are waived through the CC0 1.0 Universal public domain dedication.

The included source code developed by Jill Hagey as a work of the United States Government was distributed under the Apache Software License version 2. A copy of the Apache Software License is [included in this repository](LICENSE-Apachev2.txt).

Any such source files in this project that are included from or derived from the original work by Jill Hagey will include a notice.
