# nf-core/nfmicrofinder

[![Open in GitHub Codespaces](https://img.shields.io/badge/Open_In_GitHub_Codespaces-black?labelColor=grey&logo=github)](https://github.com/codespaces/new/sanger-tol/nfmicrofinder)
[![GitHub Actions CI Status](https://github.com/sanger-tol/nfmicrofinder/actions/workflows/nf-test.yml/badge.svg)](https://github.com/sanger-tol/nfmicrofinder/actions/workflows/nf-test.yml)
[![GitHub Actions Linting Status](https://github.com/sanger-tol/nfmicrofinder/actions/workflows/linting.yml/badge.svg)](https://github.com/sanger-tol/nfmicrofinder/actions/workflows/linting.yml)[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)
[![nf-test](https://img.shields.io/badge/unit_tests-nf--test-337ab7.svg)](https://www.nf-test.com)

[![Nextflow](https://img.shields.io/badge/version-%E2%89%A525.10.4-green?style=flat&logo=nextflow&logoColor=white&color=%230DC09D&link=https%3A%2F%2Fnextflow.io)](https://www.nextflow.io/)
[![nf-core template version](https://img.shields.io/badge/nf--core_template-4.1.0-green?style=flat&logo=nfcore&logoColor=white&color=%2324B064&link=https%3A%2F%2Fnf-co.re)](https://github.com/nf-core/tools/releases/tag/4.1.0)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Seqera Platform](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Seqera%20Platform-%234256e7)](https://cloud.seqera.io/launch?pipeline=https://github.com/nf-core/nfmicrofinder)

[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23nfmicrofinder-4A154B?labelColor=000000&logo=slack)](https://nfcore.slack.com/channels/nfmicrofinder)[![Follow on Bluesky](https://img.shields.io/badge/bluesky-%40nf__core-1185fe?labelColor=000000&logo=bluesky)](https://bsky.app/profile/nf-co.re)[![Follow on Mastodon](https://img.shields.io/badge/mastodon-nf__core-6364ff?labelColor=FFFFFF&logo=mastodon)](https://mstdn.science/@nf_core)[![Watch on YouTube](http://img.shields.io/badge/youtube-nf--core-FF0000?labelColor=000000&logo=youtube)](https://www.youtube.com/c/nf-core)

## Introduction

**nf-core/nfmicrofinder** is a bioinformatics pipeline that aids in the curation of bird genome assemblies by identifying putative microchromosome scaffolds and moving them to the start of the genome assembly FASTA file.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies.

## Pipeline Summary

1.  Input validation and parameter checks
2.  Index reference genome using Miniprot
3.  Align protein sequences to genome using Miniprot
4.  Filter alignments based on quality thresholds (identity ≥70%, score ≥60)
5.  Sort FASTA file based on filtered alignments to prioritize microchromosomes
6.  Generate final reordered assembly and pipeline reports

## Quick Start

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/get_started/environment_setup/overview) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/get_started/run-your-first-pipeline) with `-profile test` before running the workflow on actual data.

1.  Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=24.10.5`)

2.  Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility

3.  Download the pipeline and test it on a minimal dataset with a single command:

    ```bash
    nextflow run main.nf -profile test,docker
    ```

    > Note that it is recommend to use the `-profile` parameter to specify the container technology of your choice. See the [nf-core pipeline documentation](https://nf-co.re/usage/running#software-dependencies) for more information.

4.  Start running your own analysis!

    ```bash
    nextflow run main.nf \
        --input genome.fa \
        --pep_file proteins.fa \
        --output_prefix my_analysis \
        --outdir <OUTDIR>
    ```

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_; see [docs](https://nf-co.re/docs/running/run-pipelines#using-parameter-files).

## Documentation

The nfmicrofinder pipeline comes with documentation about the pipeline [usage](docs/usage.md) and [output](docs/output.md).

## Credits

nfmicrofinder was originally written by Yumi Sims and Will Eagle ([@weaglesBio](https://github.com/weaglesBio)).

We thank the following people for their extensive assistance in the development of this pipeline:

- Jim Downie ([@prototaxites](https://github.com/prototaxites))

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](docs/CONTRIBUTING.md).

## Citations

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
