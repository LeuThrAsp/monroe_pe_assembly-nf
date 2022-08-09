process pangolin_typing {

  tag "$name"



  publishDir "${params.outdir}/pangolin_reports", mode: 'copy', pattern: "*_lineage_report.csv"



  input:

  tuple val(name), file(assembly)



  output:

  tuple val(name), file("*_lineage_report.csv"),         emit: pangolin_lineages



  shell:

  """

  pangolin ${assembly} --outfile ${name}_lineage_report.csv

  """

}