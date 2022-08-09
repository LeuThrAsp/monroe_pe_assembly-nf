process ivar {

  tag "$name"



  publishDir "${params.outdir}/alignments", mode: 'copy',pattern:"*.sorted.bam"

  publishDir "${params.outdir}/SC2_reads", mode: 'copy',pattern:"*_SC2*.fastq.gz"

  publishDir "${params.outdir}/assemblies", mode: 'copy', pattern: "*_consensus.fasta"





  input:

  tuple val(name), file(reads), file(primer_bed)



  output:

  tuple val(name), file("${name}_consensus.fasta"),      emit: assembled_genomes

  tuple val(name), file("${name}.sorted.bam"),           emit: alignment_file

  tuple val(name), file("${name}_SC2*.fastq.gz"),        emit: sc2_reads



  shell:

    """

    ln -s /reference/nCoV-2019.reference.fasta ./nCoV-2019.reference.fasta

    minimap2 -K 20M -x sr -a ./nCoV-2019.reference.fasta !{reads[0]} !{reads[1]} | samtools view -u -h -F 4 - | samtools sort > SC2.bam

    samtools index SC2.bam

    samtools flagstat SC2.bam

    samtools sort -n SC2.bam > SC2_sorted.bam

    samtools fastq -f2 -F4 -1 ${name}_SC2_R1.fastq.gz -2 ${name}_SC2_R2.fastq.gz SC2_sorted.bam -s singletons.fastq.gz



    ivar trim -i SC2.bam -b !{primer_bed} -p ivar -e



    samtools sort  ivar.bam > ${name}.sorted.bam

    samtools index ${name}.sorted.bam

    samtools flagstat ${name}.sorted.bam



    samtools mpileup -f ./nCoV-2019.reference.fasta -d 1000000 -A -B -Q 0 ${name}.sorted.bam | ivar consensus -p ivar -m ${params.ivar_mindepth} -t ${params.ivar_minfreq} -n N

    echo '>${name}' > ${name}_consensus.fasta



    seqtk seq -U -l 50 ivar.fa | tail -n +2 >> ${name}_consensus.fasta

    """

}