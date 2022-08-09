process trimmomatic {

  tag "$name"


  input:

  tuple val(name), file(reads)


  output:

  tuple val(name), file("${name}_trimmed{_1,_2}.fastq.gz"),     emit: trimmed_reads


  script:

  """

  java -jar /Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads ${task.cpus} ${reads} -baseout ${name}.fastq.gz SLIDINGWINDOW:${params.windowsize}:${params.qualitytrimscore} MINLEN:${params.minlength} > ${name}.trim.stats.txt

  mv ${name}*1P.fastq.gz ${name}_trimmed_1.fastq.gz

  mv ${name}*2P.fastq.gz ${name}_trimmed_2.fastq.gz

  """

}