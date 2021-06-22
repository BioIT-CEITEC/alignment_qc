# REPORTING RULES
#


def multiqc_report_input(wildcards):
    input = {}
    if wildcards.sample != "all_samples":
        input['raw_fastq_report'] = expand("qc_reports/"+wildcards.sample+"/raw_fastqc/fastqc{read_pair_tags}.html",read_pair_tags=read_pair_tags)
        if config["qc_qualimap_DNA"]:
            input['qc_qualimap_DNA'] = "qc_reports/{sample}/qc_qualimap_DNA/qualimapReport.html"
        if config["qc_samtools_DNA"]:
            input['qc_samtools_DNA'] = "qc_reports/{sample}/qc_samtools_DNA/idxstats.tsv"
        if config["qc_picard_DNA"]:
            input['qc_picard_DNA'] = "qc_reports/{sample}/qc_picard_DNA/picard.tsv"
    else:
        input['per_sample_reports'] = expand("qc_reports/{sample}/final_alignment_report.html",sample=sample_tab.sample_name)
    return input

rule multiqc_report:
    input: unpack(multiqc_report_input)
    output: html="qc_reports/{sample}/multiqc.html"
    log: "logs/{sample}/multiqc.log"
    params:
        multiqc_config = workflow.basedir+"/../wrappers/multiqc_report/multiqc_config.txt",
        multiqc_path = "qc_reports/{sample}/"
    conda: "../wrappers/multiqc_report/env.yaml"
    script: "../wrappers/multiqc_report/script.py"

def per_sample_alignment_report_input(wildcards):
    input = {}
    input['multiqc'] = "qc_reports/{sample}/multiqc.html"
    input['raw_fastq_R1_report'] = "qc_reports/" + wildcards.sample + "/raw_fastqc/fastqc_R1.html"
    input['raw_fastq_R2_report'] = "qc_reports/" + wildcards.sample + "/raw_fastqc/fastqc_R2.html"
    if config["qc_qualimap_DNA"]:
        input['qc_qualimap_DNA'] = "qc_reports/{sample}/qc_qualimap_DNA/qualimapReport.html"
    return input

rule per_sample_alignment_report:
    input: unpack(per_sample_alignment_report_input)
    output: sample_report = "qc_reports/{sample}/final_alignment_report.html",
    log:  "logs/{sample}/per_sample_alignment_report.log"
    params: sample_name = "{sample}",
            config = config
    conda: "../wrappers/per_sample_alignment_report/env.yaml"
    script: "../wrappers/per_sample_alignment_report/script.Rmd"

def final_alignment_report_input(wildcards):
    input = {}
    input['all_sample_multiqc'] = "qc_reports/all_samples/multiqc.html"
    input['per_sample_reports'] = expand("qc_reports/{sample}/final_alignment_report.html",sample=sample_tab.sample_name)
    if config["cross_sample_correlation"]:
        input['cross_sample_correlation'] = "qc_reports/cross_sample_correlation/cross_sample_correlation.snps.html"
    return input

rule final_alignment_report:
    input: unpack(final_alignment_report_input)
    output: html="qc_reports/alignment_final_report.html"
    log: "logs/final_alignment_report.log"
    params:
        sample_name = sample_tab.sample_name,
        config = config
    conda: "../wrappers/final_alignment_report/env.yaml"
    script: "../wrappers/final_alignment_report/script.Rmd"
