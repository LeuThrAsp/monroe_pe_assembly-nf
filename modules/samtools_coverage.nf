process samtools {

  tag "$name"



  input:

  tuple val(name), file(alignment) 


  output:

  tuple val(name), file("${name}_samtoolscoverage.tsv"),      emit: alignment_qc



  shell:

  """

  samtools coverage ${alignment} -o ${name}_samtoolscoverage.tsv

  """

}