[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A523.04.3-brightgreen.svg)](https://www.nextflow.io/)

# SNVPhyl nf-core Pipeline

This is an [nf-core](https://nf-co.re/)-based pipeline for the [SNVPhyl](https://snvphyl.readthedocs.io) pipeline. The SNVPhyl (Single Nucleotide Variant PHYLogenomics) pipeline is a pipeline for identifying Single Nucleotide Variants (SNV) within a collection of microbial genomes and constructing a phylogenetic tree.

# Installation

You will need to install [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html#installation) and likely either [Docker](https://docs.docker.com/get-docker/) or [Singularity](https://docs.sylabs.io/guides/latest/user-guide/quick_start.html).

If you are only running the pipeline, you do NOT need to install [nf-core](https://nf-co.re/) (Nextflow is sufficient). Installation of the pipeline only requires downloading the code from GitHub:

```
git clone git@github.com:phac-nml/snvphylnfc.git
```

# Running the Pipeline

Navigate to the top-level directory of the pipeline. The pipeline is run as follows:

```
nextflow run main.nf -profile [PROFILE] --input [SAMPLESHEET.csv] --refgenome [REFERENCE.fasta] --outdir [OUTPUT_DIRECTORY]
```

- [PROFILE] is either `docker` or `singularity`.
- [SAMPLESHEET.csv] is a CSV-formatted samplesheet describing the sequence ID and read locations. See [this example file](https://raw.githubusercontent.com/phac-nml/snvphylnfc/main/assets/samplesheet.csv) to see the formatting.
- [REFERENCE.fasta] is a FASTA-formatted reference sequence.
- [OUTPUT_DIRECTORY] is the directory location to write all of the pipeline output.

As an example, you should be able to run the following command without needing to download any data, as the necessary files will be downloaded automatically:

```
nextflow run main.nf -profile singularity --input https://raw.githubusercontent.com/phac-nml/snvphylnfc/main/assets/samplesheet.csv --refgenome https://raw.githubusercontent.com/phac-nml/snvphylnfc/main/assets/samplesheet.csv --outdir results
```

# Legal

## SNVPhyl NF-Core Pipeline

Copyright 2023 Government of Canada

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
