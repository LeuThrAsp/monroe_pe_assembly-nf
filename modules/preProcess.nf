process preProcess {

  tag "$name"
  
  input:

  tuple val(name), file(reads)



  output:

  tuple val(name), file(reads),      emit: reads

  script:

  if(params.name_split_on!=""){

    name = name.split(params.name_split_on)[0]

    """

    mv ${reads[0]} ${name}_R1.fastq.gz

    mv ${reads[1]} ${name}_R2.fastq.gz

    """

  }else{

  """

  """

  }

}