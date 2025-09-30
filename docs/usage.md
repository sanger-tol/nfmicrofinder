# nf-core/sanger-tol/nfmicrofinder: Usage

## :warning: Please read this documentation on the nf-core website: [https://github.com/sanger-tol/nfmicrofinder/](https://github.com/sanger-tol/nfmicrofinder/usage)

> _Documentation of pipeline parameters is generated automatically from the pipeline schema and can no longer be found in markdown files._

**nfmicrofinder** is a bioinformatics pipeline that aids in the curation of bird genome assemblies by identifying putative microchromosome scaffolds using protein alignments and reordering them to the start of the genome assembly FASTA file.

The pipeline uses Miniprot to align a curated set of bird proteins to the genome, filters high-quality alignments, and reorders scaffolds based on the density of protein matches - prioritizing scaffolds with more protein alignments (likely microchromosomes) at the beginning of the assembly.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies.

## Pipeline Summary

1.  Input validation and parameter checks
2.  Align protein sequences to genome using Miniprot
3.  Filter alignments based on scaffold length
4.  Sort FASTA file based on filtered alignments
5.  Generate pipeline reports and logs

## Quick Start

1.  Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=24.10.5`)

2.  Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility _(please only use [`Conda`](https://conda.io/miniconda.html) as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_

Now, you can run the pipeline using:

```bash
nextflow run main.nf \
   -profile <docker/singularity/podman/shifter/charliecloud/conda/institute> \
   --input genome.fa \
   --pep_file proteins.fa \
   --output_prefix my_analysis \
   --scaffold_length_cutoff 5000000 \
   --outdir <OUTDIR>
```

## Core Nextflow arguments

> [!NOTE]
> These options are part of Nextflow and use a _single_ hyphen (pipeline parameters use a double-hyphen)

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments.

Several generic profiles are bundled with the pipeline which instruct the pipeline to use software packaged using different methods (Docker, Singularity, Podman, Shifter, Charliecloud, Apptainer, Conda) - see below.

> [!IMPORTANT]
> We highly recommend the use of Docker or Singularity containers for full pipeline reproducibility, however when this is not possible, Conda is also supported.

The pipeline also dynamically loads configurations from [https://github.com/nf-core/configs](https://github.com/nf-core/configs) when it runs, making multiple config profiles for various institutional clusters available at run time. For more information and to check if your system is supported, please see the [nf-core/configs documentation](https://github.com/nf-core/configs#documentation).

Note that multiple profiles can be loaded, for example: `-profile test,docker` - the order of arguments is important!
They are loaded in sequence, so later profiles can overwrite earlier profiles.

If `-profile` is not specified, a protected profile called 'standard' will be loaded by default, which runs the pipeline locally and expects all software to be installed and available on the `PATH`. This is not generally recommended, since it can lead to different results on different machines dependent on the computer environment.

- `test`
  - A profile with a complete configuration for automated testing
  - Includes links to test data so needs no other parameters
- `docker`
  - A generic configuration profile to be used with [Docker](https://docker.com/)
- `singularity`
  - A generic configuration profile to be used with [Singularity](https://sylabs.io/docs/)
- `podman`
  - A generic configuration profile to be used with [Podman](https://podman.io/)
- `shifter`
  - A generic configuration profile to be used with [Shifter](https://nersc.gitlab.io/development/shifter/how-to-use/)
- `charliecloud`
  - A generic configuration profile to be used with [Charliecloud](https://hpc.github.io/charliecloud/)
- `apptainer`
  - A generic configuration profile to be used with [Apptainer](https://apptainer.org/)
- `conda`
  - A generic configuration profile to be used with [Conda](https://conda.io/docs/). Please only use Conda as a last resort i.e. when it's not possible to run the pipeline with Docker, Singularity, Podman, Shifter, Charliecloud, or Apptainer.
- `wave`
  - A generic configuration profile to enable [Wave](https://seqera.io/wave/) containers. Use together with one of the above (requires Nextflow `24.03.0-edge` or later).

### `-resume`

Specify this when restarting a pipeline. Nextflow will use cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously. For input to be considered the same, not only the names must be identical but the files' contents as well. For more info about this parameter, see [this blog post](https://www.nextflow.io/blog/2019/demystifying-nextflow-resume.html).

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

### `-c`

Specify the path to a specific config file (this is a core Nextflow command). See the [nf-core website documentation](https://nf-co.re/usage/configuration) for more information.

> [!WARNING]
> This option should only be used for tuning process resource specifications, institutional infrastructure settings, and module arguments. This is not a recommended way of providing custom parameters for a pipeline.

#### profile

It's common to have a shared configuration file that you use for all pipeline runs, such as one for your research institute. See the [nf-core website documentation](https://nf-co.re/usage/configuration#adding-a-shared-profile) for more information on how to create and use one.

## Job Resources

### Automatic resubmission

Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the pipeline steps, if the job exits with any of the error codes specified [here](https://github.com/nf-core/rnaseq/blob/4c27ef5610c87db00c3c5a3eed10b1d161abf575/conf/base.config#L18) it will automatically be resubmitted with higher resources (2 x original, then 3 x original). If it still fails after the third attempt then the pipeline execution is stopped.

### Custom resource requests

To change the resource requests, please see the [max resources](https://nf-co.re/docs/usage/configuration#max-resources) and [tuning workflow resources](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources) section of the nf-core website.

## AWS iGenomes

The pipeline has support for AWS iGenomes, which provides a centrally maintained repository of reference genomes. This has been configured pipeline so that if you are using a reference genome that is available in AWS iGenomes you can run the pipeline and only specify the genome ID, and not have to provide the paths to the reference genome and all of the index files.

To run the pipeline with a genome use the `input` parameter. For example:

```bash
nextflow run main.nf -profile docker --input bGalGal4.fa
```

## Other command line flags

### `--outdir`

The output directory where the results will be saved.

### `--output_prefix`

Prefix for output files. If not specified, uses the input filename basename.

**Example:**

```bash
--output_prefix bAytFul3  # Creates bAytFul3.MicroFinder.ordered.fa
```

### `--pep_file`

Path to protein FASTA file used for alignment (e.g. UniProt or predicted proteins).

**Default:** MicroFinder protein set v0.1 for bird microchromosome detection
**Supported formats:** .fa, .faa, .fasta (with optional .gz compression)

### `--scaffold_length_cutoff`

Minimum scaffold length to consider for filtering and sorting (in bases).

**Default:** 5000000 (5 Mbp)
**Purpose:** Scaffolds shorter than this may be deprioritized in the final assembly ordering

### `--email`

Set this parameter to your e-mail address to get a summary e-mail with details of the run sent to you when the workflow exits. If set in your user config file (`~/.nextflow/config`) then you don't need to specify this on the command line for every run.

**NB:** You need to have e-mail sending set up on your system for this to work.

### `-name`

Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic.

This is used in the MultiQC report (if not default) and in the summary HTML and summary email.

**NB:** Single hyphen (core Nextflow option).

### `-help` / `-h`

Use to show the help message.

### `-version`

Use to show the pipeline version.

**NB:** Single hyphen (core Nextflow option).

### `-validate_params`

It is recommended to specify this by default in your `nextflow.config`, as it will catch any typos in parameter names that you may otherwise not notice. It also ensures that all required parameters are specified.
This validation can be disabled by setting the parameter to `false` if you have a need to do so.

### Running in the background

Nextflow handles job submissions and supervises the running jobs. The Nextflow process must run until the pipeline is finished.

The Nextflow `-bg` flag launches Nextflow in the background, detached from your terminal so that the workflow does not stop if you log out of your session. The logs are saved to a file.

Alternatively, you can use `screen` / `tmux` or similar tool to create a detached session which you can log back into at a later time.
Some HPC setups also allow you to run nextflow within a cluster job submitted your job scheduler (from where it submits more jobs).

### Nextflow memory requirements

In some cases, the Nextflow Java virtual machines can start to request a large amount of memory.
We recommend adding the following line to your environment to limit this (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```
