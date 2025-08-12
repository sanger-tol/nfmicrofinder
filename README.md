# nf-core/nfmicrofinder

[![GitHub Actions CI Status](https://github.com/nf-core/nfmicrofinder/actions/workflows/ci.yml/badge.svg)](https://github.com/nf-core/nfmicrofinder/actions/workflows/ci.yml)
[![GitHub Actions Linting Status](https://github.com/nf-core/nfmicrofinder/actions/workflows/linting.yml/badge.svg)](https://github.com/nf-core/nfmicrofinder/actions/workflows/linting.yml)[![AWS CI](https://img.shields.io/badge/CI%20tests-full%20size-FF9900?labelColor=000000&logo=Amazon%20AWS)](https://nf-co.re/nfmicrofinder/results)[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.XXXXXXX-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.XXXXXXX)
[![nf-test](https://img.shields.io/badge/unit_tests-nf--test-337ab7.svg)](https://www.nf-test.com)

[![Nextflow](https://img.shields.io/badge/version-%E2%89%A524.04.2-green?style=flat&logo=nextflow&logoColor=white&color=%230DC09D&link=https%3A%2F%2Fnextflow.io)](https://www.nextflow.io/)
[![nf-core template version](https://img.shields.io/badge/nf--core_template-3.3.1-green?style=flat&logo=nfcore&logoColor=white&color=%2324B064&link=https%3A%2F%2Fnf-co.re)](https://github.com/nf-core/tools/releases/tag/3.3.1)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Seqera Platform](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Seqera%20Platform-%234256e7)](https://cloud.seqera.io/launch?pipeline=https://github.com/nf-core/nfmicrofinder)

[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23nfmicrofinder-4A154B?labelColor=000000&logo=slack)](https://nfcore.slack.com/channels/nfmicrofinder)[![Follow on Bluesky](https://img.shields.io/badge/bluesky-%40nf__core-1185fe?labelColor=000000&logo=bluesky)](https://bsky.app/profile/nf-co.re)[![Follow on Mastodon](https://img.shields.io/badge/mastodon-nf__core-6364ff?labelColor=FFFFFF&logo=mastodon)](https://mstdn.science/@nf_core)[![Watch on YouTube](http://img.shields.io/badge/youtube-nf--core-FF0000?labelColor=000000&logo=youtube)](https://www.youtube.com/c/nf-core)

## Introduction

**nf-core/nfmicrofinder** is a bioinformatics pipeline that aids in the curation of bird genome assemblies by identifying putative microchromosome scaffolds and moving them to the start of the genome assembly FASTA file.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies.

## Pipeline Summary

1.  Input validation and parameter checks
2.  Align protein sequences to genome using Miniprot
3.  Filter alignments based on scaffold length
4.  Sort FASTA file based on filtered alignments
5.  Generate pipeline reports and logs

## Quick Start

1.  Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=24.04.2`)

2.  Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility _(please only use [`Conda`](https://conda.io/miniconda.html) as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_

3.  Download the pipeline and test it on a minimal dataset with a single command:

    ```bash
    nextflow run main.nf -profile test,docker
    ```

    > Note that it is recommend to use the `-profile` parameter to specify the container technology of your choice. See the [nf-core pipeline documentation](https://nf-co.re/usage/running#software-dependencies) for more information.

4.  Start running your own analysis!

    ```bash
    nextflow run main.nf --input genome.fa --outdir <OUTDIR>
    ```

## Documentation

The nfmicrofinder pipeline comes with documentation about the pipeline [usage](docs/usage.md) and [output](docs/output.md).

## Credits

nfmicrofinder was originally written by Yumi Sims and Will Eagle ([@weaglesBio](https://github.com/weaglesBio)).

We thank the following people for their extensive assistance in the development of this pipeline:

- Jim Downie ([@prototaxites](https://github.com/prototaxites))

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
