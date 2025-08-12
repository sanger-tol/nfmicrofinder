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

// Function to check GFF content
def checkGffContent(gff) {
    def nonCommentLines = gff.readLines().findAll { !it.startsWith('#') }
    
    if (nonCommentLines.isEmpty()) {
        println "no entry"
        return [false, true]  // [hasContent, isEmpty]
    }
    
    def hasMrna = nonCommentLines.any { line ->
        def fields = line.split('\t')
        fields.size() >= 3 && fields[2] == "mRNA"
    }
    
    return [hasMrna, false]  // [hasContent, isEmpty]
}

workflow MICROFINDER_MAP {
    take:
    reference_tuple     // Channel: [ val(meta), path(file) ]
    scaffold_length_cutoff
    pep_files          // String: path or URL to protein file
    output_prefix      // Channel: val(prefix)

    main:
    ch_versions = Channel.empty()

    //
    // MODULE: CREATES INDEX OF REFERENCE FILE
    //
    MINIPROT_INDEX ( reference_tuple )
    ch_versions = ch_versions.mix( MINIPROT_INDEX.out.versions )

    //
    // Create channel from pep_file and combine with index
    //
    Channel
        .fromPath(pep_files)
        .map { file -> 
            def meta = [
                id: file.baseName,
                type: 'protein',
                org: 'reference'
            ]
            tuple(meta, file)
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

    //
    // Check GFF content using Groovy function
    //
    MINIPROT_ALIGN.out.gff
        .view { meta, gff_file -> 
            println "DEBUG [1]: MINIPROT_ALIGN output:"
            println "  meta: $meta"
            println "  gff_file: $gff_file"
            return tuple(meta, gff_file)
        }
        .map { meta, gff_file ->
            def (has_content, is_empty) = checkGffContent(gff_file)
            println "DEBUG [2]: After checkGffContent:"
            println "  has_content: $has_content"
            println "  is_empty: $is_empty"
            tuple(meta, gff_file, has_content, is_empty)
        }
        .set { checked_gff }

    //
    // Branch based on GFF content
    //
    checked_gff
        .combine(reference_tuple)
        .branch { meta, gff_file, has_content, is_empty, ref_meta, ref_file ->
            empty_gff: is_empty
                return tuple(ref_meta, ref_file)  // Return reference directly if GFF is empty
            has_content: !is_empty
                return tuple(meta, gff_file, ref_meta, ref_file)  // Continue processing if GFF has content
        }
        .set { gff_output }

    // Debug the branch outputs
    gff_output.empty_gff
        .view { meta, ref_file ->
            return tuple(meta, ref_file)
        }
        .set { to_rename }

    // Process to rename empty GFF output
    process RENAME_EMPTY_OUTPUT {
        publishDir "${params.outdir}/microfinder", mode: params.publish_dir_mode
        
        input:
        tuple val(meta), path(ref_file)
        
        output:
        tuple val(meta), path("final.fa"), emit: fa
        
        script:
        """
        cp ${ref_file} final.fa
        """
    }

    // Run rename process for empty GFF case
    RENAME_EMPTY_OUTPUT(to_rename)
        .fa
        .set { final_fasta }

    gff_output.has_content
        .view { meta, gff_file, ref_meta, ref_file ->
            return tuple(meta, gff_file, ref_meta, ref_file)
        }
        .combine(output_prefix)
        .set { to_filter }

    //
    // MODULE: FILTER HITS (only if GFF has content)
    //
    MICROFINDER_FILTER ( 
        to_filter.map { meta, gff_file, ref_meta, ref_file, prefix -> tuple(meta, gff_file) },
        to_filter.map { meta, gff_file, ref_meta, ref_file, prefix -> tuple(ref_meta, ref_file) },
        to_filter.map { meta, gff_file, ref_meta, ref_file, prefix -> prefix },
        scaffold_length_cutoff
    )
    ch_versions = ch_versions.mix( MICROFINDER_FILTER.out.versions )

    //
    // MODULE: REORDER ASSEMBLY (only if GFF has content)
    //
    SORT_FASTA ( 
        MICROFINDER_FILTER.out.tsv,
        output_prefix,
        scaffold_length_cutoff
    )
    ch_versions = ch_versions.mix(SORT_FASTA.out.versions)

    // Rename the output from SORT_FASTA to final.fa
    process RENAME_SORTED_OUTPUT {
        publishDir "${params.outdir}/microfinder", mode: params.publish_dir_mode
        
        input:
        tuple val(meta), path(fa)
        
        output:
        tuple val(meta), path("final.fa"), emit: fa
        
        script:
        """
        cp ${fa} final.fa
        """
    }

    // Run rename process for sorted output
    RENAME_SORTED_OUTPUT(SORT_FASTA.out.fa)
        .fa
        .set { ch_sorted_fasta }

    // Mix sorted fasta with reference fasta (for empty GFF case)
    sorted_fasta = ch_sorted_fasta.mix(final_fasta)
        .view { meta, fa ->
            return tuple(meta, fa)
        }

    emit:
    sorted_fasta = sorted_fasta
    versions = ch_versions.ifEmpty(null)
}


