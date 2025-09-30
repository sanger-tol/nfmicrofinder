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

    ch_versions = Channel.empty()

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

    // Only create versions file if there are versions to collect
    ch_versions
        .ifEmpty {
            log.warn "No software versions collected - creating minimal versions file"
            Channel.of("pipeline: nfmicrofinder")
        }
        .set { ch_versions_final }

    softwareVersionsToYAML(ch_versions_final)
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
