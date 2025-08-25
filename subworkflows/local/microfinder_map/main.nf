#!/usr/bin/env nextflow

//
// Adapted from MicroFinder.v0.2
// by Tom Mathers
//

//
// MODULE IMPORT BLOCK
//

include { MINIPROT_ALIGN        } from '../../../modules/nf-core/miniprot/align/main'
include { MINIPROT_INDEX        } from '../../../modules/nf-core/miniprot/index/main'
include { SORT_FASTA            } from '../../../modules/local/sort_fasta'
include { MICROFINDER_FILTER    } from '../../../modules/local/microfinder_filter'
include { RENAME_EMPTY_OUTPUT   } from '../../../modules/local/rename_empty_output/main'
include { RENAME_SORTED_OUTPUT  } from '../../../modules/local/rename_sorted_output/main'

workflow MICROFINDER_MAP {
    take:
    reference_tuple     // Channel: [ val(meta), path(file) ]
    scaffold_length_cutoff // Channel: val(cutoff)
    pep_files          // Channel: val(path or URL to protein file)
    output_prefix      // Channel: val(prefix)

    main:
    ch_versions = Channel.empty()

    //
    // MODULE: CREATES INDEX OF REFERENCE FILE
    //
    MINIPROT_INDEX ( reference_tuple )
    ch_versions = ch_versions.mix( MINIPROT_INDEX.out.versions )

    //
    // Combine with index
    //
    pep_files
        .map { pf ->
            def f = file(pf)
            def meta = [ id: f.baseName, type: 'protein', org: 'reference' ]
            tuple(meta, f)
        }
        .combine(MINIPROT_INDEX.out.index)
        .multiMap { pep_meta, pep_file, miniprot_meta, miniprot_index ->
            pep_tuple: tuple(pep_meta, pep_file)
            index_file: tuple([id: "Reference"], miniprot_index)
        }
        .set { formatted_input }

    //
    // MODULE: ALIGNS PEP DATA WITH REFERENCE INDEX
    //         EMITS GFF FILE
    //
    MINIPROT_ALIGN (
        formatted_input.pep_tuple,
        formatted_input.index_file
    )
    ch_versions = ch_versions.mix( MINIPROT_ALIGN.out.versions )


    // Branch based on PAF output
    MINIPROT_ALIGN.out.paf
        .map { meta, paf_file ->
            def has_content = file(paf_file).size() > 0
            tuple(has_content, meta, paf_file)
        }
        .combine(reference_tuple)
        .branch { has_content, meta, paf_file, ref_meta, ref_file ->
            empty_gff: !has_content
                return tuple(ref_meta, ref_file)
            has_content: has_content
                return tuple(meta, paf_file, ref_meta, ref_file)
        }
        .set { gff_output }

    // Handle empty GFF case - just rename the original reference
    RENAME_EMPTY_OUTPUT(gff_output.empty_gff)
        .fa
        .set { final_fasta }
    ch_versions = ch_versions.mix( RENAME_EMPTY_OUTPUT.out.versions )

    // Process PAF content
    gff_output.has_content
        .combine(output_prefix)
        .combine(scaffold_length_cutoff)
        .set { to_filter }

    //
    // MODULE: FILTER HITS
    //
    MICROFINDER_FILTER (
        to_filter.map { meta, paf_file, ref_meta, ref_file, prefix, cutoff -> tuple(meta, paf_file) },
        to_filter.map { meta, paf_file, ref_meta, ref_file, prefix, cutoff -> tuple(ref_meta, ref_file) },
        to_filter.map { meta, paf_file, ref_meta, ref_file, prefix, cutoff -> prefix },
        to_filter.map { meta, paf_file, ref_meta, ref_file, prefix, cutoff -> cutoff }
    )
    ch_versions = ch_versions.mix( MICROFINDER_FILTER.out.versions )

    //
    // MODULE: REORDER ASSEMBLY
    //
    SORT_FASTA (
        MICROFINDER_FILTER.out.tsv,
        output_prefix,
        scaffold_length_cutoff
    )
    ch_versions = ch_versions.mix(SORT_FASTA.out.versions)

    // Rename the output from SORT_FASTA to final.fa
    RENAME_SORTED_OUTPUT(SORT_FASTA.out.fa)
        .fa
        .set { ch_sorted_fasta }
    ch_versions = ch_versions.mix( RENAME_SORTED_OUTPUT.out.versions )

    // Mix sorted fasta with reference fasta (for empty GFF case)
    sorted_fasta = ch_sorted_fasta.mix(final_fasta)

    emit:
    sorted_fasta = sorted_fasta
    versions = ch_versions.ifEmpty(null)
}
