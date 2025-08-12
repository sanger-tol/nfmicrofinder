process RENAME_EMPTY_OUTPUT {
    tag "$meta.id"
    label "process_single"

    conda "conda-forge::coreutils=9.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
    'docker.io/ubuntu:20.04' }"

    publishDir "${params.outdir}/microfinder", mode: params.publish_dir_mode, pattern: "final.fa"

    input:
    tuple val(meta), path(ref_file)

    output:
    tuple val(meta), path("final.fa"), emit: fa
    path "versions.yml", emit: versions

    script:
    def VERSION = "9.1"
    """
    cp ${ref_file} final.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        coreutils: $VERSION
    END_VERSIONS
    """

    stub:
    def VERSION = "9.1"
    """
    touch final.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        coreutils: $VERSION
    END_VERSIONS
    """
} 