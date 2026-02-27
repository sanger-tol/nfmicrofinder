process SORT_FASTA {
    tag "$meta.id"
    label "process_single"

    container 'quay.io/sanger-tol/mfruby:1.0.0-c1'

    publishDir "${params.outdir}/microfinder", mode: params.publish_dir_mode, pattern: "*.fa"

    input:
    tuple val(meta), path(input_tsv)
    path(input_assembly)
    val (output_prefix)
    val (scaffold_length_cutoff)

    output:
    tuple val(meta), path("*.fa"), emit: fa
    path "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args        = task.ext.args ?: ''
    def prefix      = task.ext.prefix ?: "${meta.id}"
    def VERSION     = "2.2.3"
    """
    sort_fasta.rb -f ${input_assembly} -o ${input_tsv} -l ${scaffold_length_cutoff} > ${output_prefix}.MicroFinder.ordered.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ruby: \$(ruby --version | cut -d' ' -f2)
    END_VERSIONS
    """

    stub:
    def args        = task.ext.args ?: ''
    def prefix      = task.ext.prefix ?: "${meta.id}"
    def VERSION     = "2.2.3"
    """
    touch ${output_prefix}.MicroFinder.ordered.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ruby: $VERSION
    END_VERSIONS
    """
}
