process CCTYPER {
    tag "$meta.id"
    label 'process_low'
    conda "russel88::cctyper=1.8.0-py38_0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://jimmyliu1326/cctyper:1.8.0' :
        'jimmyliu1326/cctyper:1.8.0' }"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("${prefix}/crisprs_all.tab"), emit: crisprs_all, optional: true
    tuple val(meta), path("${prefix}/*.gff"), emit: gff, optional: true
    tuple val(meta), path("${prefix}/genes.tab"), emit: genes, optional: true
    tuple val(meta), path("${prefix}/crisprs_near_cas.tab"), emit: crisprs_near_cas, optional: true
    tuple val(meta), path("${prefix}/hmmer.tab"), emit: hmmer, optional: true
    tuple val(meta), path("${prefix}/arguments.tab"), emit: arguments, optional: true
    tuple val(meta), path("${prefix}/cas_operons_putative.tab"), emit: cas_operons, optional: true
    tuple val(meta), path("${prefix}/plots.svg"), emit: plot_svg, optional: true
    tuple val(meta), path("${prefix}/plots.png"), emit: plot_png, optional: true
    tuple val(meta), path("${prefix}/spacers/*.fa"), emit: spacer_fa, optional: true
    path "versions.yml"                       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args     = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    cctyper \
        -t ${task.cpus} \
        ${args} \
        ${fasta} \
        ${prefix}

    cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            cctyper: \$(cctyper -h | grep version | sed 's/CRISPRCasTyper version //g')
    END_VERSIONS
    """
}
