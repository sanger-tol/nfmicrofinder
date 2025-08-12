/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { MICROFINDER_MAP            } from '../subworkflows/local/microfinder_map'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_microfinder_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow MICROFINDER {

    take:
    reference // channel: path(fasta)

    main:

    ch_versions = Channel.empty()

    // Create channels from reference
    reference_tuple = reference
        .map { file -> 
            def meta = [id: file.baseName]
            tuple(meta, file)
        }
        .branch { meta, file ->
            reference: true
                return tuple(meta, file)
            prefix: true
                return meta.id
        }

    // Set output prefix using params or meta id
    output_prefix = reference_tuple.prefix
        .map { id -> params.output_prefix ?: id }

    MICROFINDER_MAP (
        reference_tuple.reference,
        params.scaffold_length_cutoff,
        params.pep_file,
        output_prefix
    )

    // Mix versions from subworkflow
    ch_versions = ch_versions.mix(MICROFINDER_MAP.out.versions)

    emit:
    versions = ch_versions                     // channel: [ versions.yml ]
    sorted_fasta = MICROFINDER_MAP.out.sorted_fasta  // channel: [ sorted fasta file ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
