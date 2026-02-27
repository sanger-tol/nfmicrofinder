/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { MICROFINDER_MAP        } from '../subworkflows/local/microfinder_map'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_nfmicrofinder_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow NFMICROFINDER {

    take:
    reference // channel: path(fasta)
    pep_file // channel: val(pep_file_path)
    scaffold_length_cutoff // channel: val(cutoff)
    output_prefix_ch // channel: val(prefix)
    main:

    ch_versions = channel.empty()

    // Create channels from reference
    reference_tuple = reference
        .map { obj ->
            def ref = file(obj)
            def meta = [id: ref.baseName]
            tuple(meta, ref)
        }

    MICROFINDER_MAP (
        reference_tuple,
        scaffold_length_cutoff,
        pep_file,
        output_prefix_ch
    )

    // Mix versions from subworkflow
    ch_versions = ch_versions.mix(MICROFINDER_MAP.out.versions)
    //
    // Collate and save software versions
    //
    def topic_versions = Channel.topic("versions")
        .distinct()
        .branch { entry ->
            versions_file: entry instanceof Path
            versions_tuple: true
        }

    def topic_versions_string = topic_versions.versions_tuple
        .map { process, tool, version ->
            [ process[process.lastIndexOf(':')+1..-1], "  ${tool}: ${version}" ]
        }
        .groupTuple(by:0)
        .map { process, tool_versions ->
            tool_versions.unique().sort()
            "${process}:\n${tool_versions.join('\n')}"
        }

    softwareVersionsToYAML(ch_versions.mix(topic_versions.versions_file))
        .mix(topic_versions_string)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name:  'nfmicrofinder_software_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { _ch_collated_versions }


    emit:
    versions = ch_versions                     // channel: [ versions.yml ]
    sorted_fasta = MICROFINDER_MAP.out.sorted_fasta  // channel: [ sorted fasta file ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
