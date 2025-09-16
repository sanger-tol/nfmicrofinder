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
include { RENAME_SORTED_OUTPUT  } from '../../../modules/local/rename_sorted_output/main'
include { RENAME_SORTED_OUTPUT as RENAME_FALLBACK_OUTPUT } from '../../../modules/local/rename_sorted_output/main'

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


    // Create a simple prefix value from the first available item
    output_prefix
        .first()
        .set { prefix_value }


    // Combine GFF with output prefix for MICROFINDER_FILTER  
    MINIPROT_ALIGN.out.gff
        .combine(prefix_value)
        .set { gff_with_prefix }
    
    //
    // MODULE: FILTER HITS
    //
    MICROFINDER_FILTER (
        gff_with_prefix.map { meta, gff_file, prefix -> tuple(meta, gff_file) },
        gff_with_prefix.map { meta, gff_file, prefix -> prefix }
    )
    ch_versions = ch_versions.mix( MICROFINDER_FILTER.out.versions )

    // Check if TSV has content before proceeding with assembly reordering
    MICROFINDER_FILTER.out.tsv
        .map { meta, tsv_file ->
            def file_obj = file(tsv_file)
            def has_content = false
            
            // Check if TSV file exists, has size > 0, and contains data lines
            if (file_obj.exists() && file_obj.size() > 0) {
                // Read file and check for non-empty, non-header lines
                def content_lines = file_obj.readLines().findAll { line -> 
                    !line.trim().isEmpty() && !line.startsWith('#')
                }
                has_content = content_lines.size() > 0
            }
            
            tuple(has_content, meta, tsv_file)
        }
        .combine(reference_tuple)
        .combine(output_prefix)
        .combine(scaffold_length_cutoff)
        .branch { has_content, meta, tsv_file, ref_meta, ref_file, prefix, cutoff ->
            has_content: has_content
                return tuple(meta, tsv_file, ref_meta, ref_file, prefix, cutoff)
            no_content: !has_content
                return tuple(ref_meta, ref_file)
        }
        .set { tsv_branched }

    //
    // MODULE: REORDER ASSEMBLY (only if TSV has content)
    //
    SORT_FASTA (
        tsv_branched.has_content.map { meta, tsv_file, ref_meta, ref_file, prefix, cutoff -> tuple(meta, tsv_file) },
        tsv_branched.has_content.map { meta, tsv_file, ref_meta, ref_file, prefix, cutoff -> ref_file },
        tsv_branched.has_content.map { meta, tsv_file, ref_meta, ref_file, prefix, cutoff -> prefix },
        tsv_branched.has_content.map { meta, tsv_file, ref_meta, ref_file, prefix, cutoff -> cutoff }
    )
    ch_versions = ch_versions.mix(SORT_FASTA.out.versions)

    // Rename the output from SORT_FASTA to final.fa
    RENAME_SORTED_OUTPUT(SORT_FASTA.out.fa)
        .fa
        .set { ch_sorted_fasta }
    ch_versions = ch_versions.mix( RENAME_SORTED_OUTPUT.out.versions )

    // For cases where TSV has no content, rename original reference to final.fa
    RENAME_FALLBACK_OUTPUT(tsv_branched.no_content)
        .fa
        .set { ch_tsv_fallback_fasta }
    ch_versions = ch_versions.mix( RENAME_FALLBACK_OUTPUT.out.versions )

    // Combine sorted fasta with TSV fallback, or use reference if no processing occurred
    sorted_fasta = ch_sorted_fasta.mix(ch_tsv_fallback_fasta).ifEmpty(reference_tuple)

    emit:
    sorted_fasta = sorted_fasta
    versions = ch_versions
}
