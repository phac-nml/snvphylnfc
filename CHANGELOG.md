# phac-nml/snvphylnfc: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.3.0] - 2025-06-09

### `Added`

- Added `software_versions.yml` to the files included within the `iridanext.output.json.gz` file. [PR #34](https://github.com/phac-nml/snvphylnfc/pull/34)

### `Updated`

- Updated `ArborView` to version [0.1.0](https://github.com/phac-nml/ArborView/releases/tag/v0.1.0). [PR #34](https://github.com/phac-nml/snvphylnfc/pull/34)
  - `assets/ArborView.html` replaced with [table.html](https://github.com/phac-nml/ArborView/blob/v0.1.0/html/table.html)
  - `bin/inline_arborview.py` replaced with [fillin_data.py](https://github.com/phac-nml/ArborView/blob/v0.1.0/scripts/fillin_data.py)
  - The `ARBOR_VIEW` process now outputs the version of ArborView (`0.1.0`) to `software_versions.yml`
- Updated nf-core module [custom_dumpsoftwareversions](https://nf-co.re/modules/custom_dumpsoftwareversions/) to latest version (commit `05954dab2ff481bcb999f24455da29a5828af08d`). [PR #34](https://github.com/phac-nml/snvphylnfc/pull/34)
- Updated nf-core module [cat_cat](https://nf-co.re/modules/cat_cat/) to latest version (commit `05954dab2ff481bcb999f24455da29a5828af08d`). [PR #34](https://github.com/phac-nml/snvphylnfc/pull/34)
- Updated nf-core linting and some of the nf-core GitHub actions to the latest versions. [PR #34](https://github.com/phac-nml/snvphylnfc/pull/34)

## [2.2.2] - 2025-04-14

### `Updated`

- Update the `ArborView` version to [0.0.8](https://github.com/phac-nml/ArborView/releases/tag/v0.0.8) (i.e. replace `bin/inline_arborview.py` with `scripts/fillin_data.py` and `assets/ArborView.html` with `html/table.html`) [PR #31](https://github.com/phac-nml/snvphylnfc/pull/31)

## [2.2.1] - 2025/03/20

### Changed

- Increased resources for `VERIFYING_MAP_Q` from `process_single` to `process_high` for processing larger numbers of samples. See [PR #29](https://github.com/phac-nml/snvphylnfc/pull/29).
- Increased resources for `PHYML` from `process_low` to `process_medium` for processing larger numbers of samples. See [PR #29](https://github.com/phac-nml/snvphylnfc/pull/29).
- Increased resources for `SMALT_MAP` from `process_single` to `process_medium` for processing larger numbers of samples faster. See [PR #29](https://github.com/phac-nml/snvphylnfc/pull/29).
- Increased resources for `SORT_INDEX_BAMS` from `process_low` to `process_medium` for processing larger numbers of samples and included command option for using multiple threads. See [PR #29](https://github.com/phac-nml/snvphylnfc/pull/29).
- Updated `nf-core` lint version to `3.2.0`. See [PR #29](https://github.com/phac-nml/snvphylnfc/pull/29).
- Fixed some nf-core linting warnings and moved arborview.nf module to subfolders. See [PR #29](https://github.com/phac-nml/snvphylnfc/pull/29).

## [2.2.0] - 2024/10/21

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

[2.3.0]: https://github.com/phac-nml/snvphylnfc/releases/tag/2.3.0
[2.2.2]: https://github.com/phac-nml/snvphylnfc/releases/tag/2.2.2
[2.2.1]: https://github.com/phac-nml/snvphylnfc/releases/tag/2.2.1
[2.2.0]: https://github.com/phac-nml/snvphylnfc/releases/tag/2.2.0
[2.1.1]: https://github.com/phac-nml/snvphylnfc/releases/tag/2.1.1
[2.1.0]: https://github.com/phac-nml/snvphylnfc/releases/tag/2.1.0
[2.0.2]: https://github.com/phac-nml/snvphylnfc/releases/tag/2.0.2
[2.0.1]: https://github.com/phac-nml/snvphylnfc/releases/tag/2.0.1
[2.0.0]: https://github.com/phac-nml/snvphylnfc/releases/tag/2.0.0
