# REPORTING RULES
#
# all = final whole run report




def single_sample_report_DNA_input(wildcards):
    input = {
        'raw_fastqc': expand("raw_fastq_qc/raw_fastq_qc/{sample}{read_pair_tag}.fastqc.html",zip,sample=sample_tab.sample_name,read_pair_tag=read_pair_tags)}
    if config["qc_picard_DNA"]:
        input['picard'] = expand("alignment_qc/map_qc/picard/{sample}.picard.tsv",sample=sample_tab.sample_name)
    if config["qc_samtools_DNA"]:
        input['samtools'] = expand("alignment_qc/map_qc/samtools/{sample}.idxstats.tsv",sample=sample_tab.sample_name)
    if config["qc_qualimap_DNA"]:
        input['qualimap'] = expand("alignment_qc/map_qc/qualimap/{sample}/qualimapReport.pdf",sample=sample_tab.sample_name)
    return input

rule single_sample_report_DNA:
    input: unpack(single_sample_report_DNA_input)
    output:
        whole_run_log= "sample_logs/{sample}.fastq2bam.log",
    log: run = "sample_logs/{sample}/single_sample_report_DNA.log"
    params:
        multiqc_html_single = "sample_final_reports/{sample}.multiqc_report.html",
        multiqc_html_all= ".multiqc_report.html",#snakemake.params.lib_name + snakemake.params.multiqc_html_final,
        multiqc_config = "/home/245829/Rmarkdown_test/wrappers/multiqc_report/multiqc_config.txt", #upravit cestu!
        lib_name = config["library_name"],
        run_dir = "/mnt/ssd/ssd_1/workspace/katka/Rmarkdown/201111_TP53-20201111/"
    conda: "../wrappers/single_sample_report_DNA/env.yaml"
    script: "../wrappers/single_sample_report_DNA/script.py"

