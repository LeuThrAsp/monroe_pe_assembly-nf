#!/usr/bin/env nextflow



//Description: Workflow for quality control of raw illumina reads

//Author: Kevin Libuit

//eMail: kevin.libuit@dgs.virginia.gov

nextflow.enable.dsl = 2

//starting parameters


params.reads = ""

params.outdir = ""

params.primerSet = ""

params.primerPath = workflow.projectDir + params.primerSet

params.report = ""

params.pipe = ""

//setup channel to read in and pair the fastq files

Channel

    .fromFilePairs(  "${params.reads}/*{R1,R2,_1,_2}*.{fastq,fq}.gz", size: 2 )

    .ifEmpty { exit 1, "Cannot find any reads matching: ${params.reads}\nNB: Path needs to be enclosed in quotes!\nIf this is single-end data, please specify --singleEnd on the command line." }

    .set { raw_reads }


Channel

  .fromPath(params.primerPath, type:'file')

  .ifEmpty{

    println("A bedfile for primers is required. Set with 'params.primerPath'.")

    exit 1

  }

  .view { "Primer BedFile : $it"}

  .set { primer_bed }


// include the workflow
include { monroe_pe_assembly } from './workflows/monroe_pe_assembly.nf'
include { assembly_results       }        from './modules/assembly_results.nf'

//if you say nothing next to the workflow name (do not name process) then it will be the main workflow
workflow {
    monroe_pe_assembly(raw_reads, primer_bed)

    //MODULE: assembly_results
    ch_cg_pipeline_results = monroe_pe_assembly.out.ch_samtools_cov.collect()
    ch_pangolin_lineage = monroe_pe_assembly.out.ch_pangolin_lineage.collect()
    assembly_results(ch_cg_pipeline_results, ch_pangolin_lineage)
}
