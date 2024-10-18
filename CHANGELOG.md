# phac-nml/snvphylnfc: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 2024/10/18

- Modified the template for input csv file to include a `sample_name` column in addition to `sample` in-line with changes to [IRIDA-Next update] as seen with the [speciesabundance pipeline]

  - `sample_name` special characters will be replaced with `"_"`
  - If no `sample_name` is supplied in the column `sample` will be used
  - To avoid repeat values for `sample_name` all `sample_name` values will be suffixed with the unique `sample` value from the input file

- Fixed linting issues in CI caused by nf-core 3.0.1

[IRIDA-Next update]: https://github.com/phac-nml/irida-next/pull/678
[speciesabundance pipeline]: https://github.com/phac-nml/speciesabundance/pull/24

## [2.1.1] - 2024/08/21

### `Changed`

- Container registry for aborview switched from docker.io to quay.io/biocontainers (python:3.11.6 to python:3.12)

## [2.1.0] - 2024/07/09

### `Added`

- Support for including contextual metadata in the input samplesheet: See [PR 22](https://github.com/phac-nml/snvphylnfc/pull/22)
- ArborView HTML app functionality for viewing dendograms with contextual metadata: See [PR 22](https://github.com/phac-nml/snvphylnfc/pull/22)

## [2.0.2] - 2024/05/21

### `Added`

- Support for compressed (GZIP-formatted) reference files.

## [2.0.1] - 2024/02/23

### `Changed`

- Pinned Nextflow plugins to specific versions (nf-validation@1.1.3 and nf-iridanext@0.2.0)

## [2.0.0] - 2024/02/14

### `Added`

- The initial release of phac-nml/snvphylnfc as a Nextflow pipeline follwing nf-core pipeline standards.

### `Changed`

- Migrated SNVPhyl to a Nextflow pipeline.
- Updated the major SNVPhyl release version from 1 to 2 in order to reflect the migration from a Galaxy-based pipeline to a Nextflow-based pipeline.

### `Deprecated`

### `Fixed`

### `Dependencies`

[2.1.1]: https://github.com/phac-nml/snvphylnfc/releases/tag/2.1.1
[2.1.0]: https://github.com/phac-nml/snvphylnfc/releases/tag/2.1.0
[2.0.2]: https://github.com/phac-nml/snvphylnfc/releases/tag/2.0.2
[2.0.1]: https://github.com/phac-nml/snvphylnfc/releases/tag/2.0.1
[2.0.0]: https://github.com/phac-nml/snvphylnfc/releases/tag/2.0.0
