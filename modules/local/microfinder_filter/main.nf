process MICROFINDER_FILTER {
    tag "$meta.id"
    label "process_single"

    conda "conda-forge::coreutils=9.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
    'docker.io/ubuntu:20.04' }"

    input:
    tuple val(meta), path(input_file)
    tuple val(meta), path(input_assembly)
    val (output_prefix)
    val (scaffold_length_cutoff)

    output:
    tuple val(meta), path("*.tsv"), emit: tsv
    path "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args        = task.ext.args ?: ''
    def prefix      = task.ext.prefix ?: "${meta.id}"
    def VERSION = "9.1"
    """
    # Extract scaffold names and counts from PAF file
    awk '\$12 >= 60 && \$10/\$11 >= 0.7' ${input_file} | cut -f6 | sort | uniq -c | sort -k1,1nr | awk '{print \$2 "\\t" \$1}' > ${output_prefix}.MicroFinder.order.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        coreutils: $VERSION
    END_VERSIONS
    """
    stub:
    def args        = task.ext.args ?: ''
    def prefix      = task.ext.prefix ?: "${meta.id}"
    def VERSION     = "9.1"
    """
    touch ${prefix}.MicroFinder.filtered.tsv
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        coreutils: $VERSION
    END_VERSIONS
    """
}
