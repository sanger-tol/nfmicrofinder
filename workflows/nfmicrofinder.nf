/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { MICROFINDER_MAP            } from '../subworkflows/local/microfinder_map'
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
    main:

    ch_versions = Channel.empty()

    // Create channels from reference
    reference_tuple = reference
        .map { obj ->
            def ref = file(obj)
            def meta = [id: ref.baseName]
            tuple(meta, ref)
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

    // Normalize inputs to channels if needed
    def pep_file_ch = (pep_file instanceof groovyx.gpars.dataflow.DataflowReadChannel) ? pep_file : Channel.value(pep_file)
    def scaffold_length_cutoff_ch = (scaffold_length_cutoff instanceof groovyx.gpars.dataflow.DataflowReadChannel) ? scaffold_length_cutoff : Channel.value(scaffold_length_cutoff)

    MICROFINDER_MAP (
        reference_tuple.reference,
        scaffold_length_cutoff,
        pep_file,
        output_prefix
    )

    // Mix versions from subworkflow
    ch_versions = ch_versions.mix(MICROFINDER_MAP.out.versions)

    softwareVersionsToYAML(ch_versions)
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
