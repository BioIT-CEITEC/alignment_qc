# REPORTING RULES
#
# all = final whole run report

# if config["qc_qualimap_DNA"]:
#     input['qualimap'] = expand("map_qc/qualimap/{sample}/qualimapReport.pdf",sample=sample_tab.sample_name)
# if config["qc_samtools_DNA"]:
#     input['samtools'] = expand("map_qc/samtools/{sample}.idxstats.tsv",sample=sample_tab.sample_name)
# return input
#
#
# rule final_report:
#     input: unpack(final_report_input)
#     output: html="general_analysis_report.html"
#     log: run="sample_final_reports/final_sample_report.html"
#     conda: "../wrappers/single_sample_report_DNA/env.yaml"
#     script: "../wrappers/single_sample_report_DNA/test_markdown.Rmd"




def multiqc_report_input(wildcards):
    input = {}
    if wildcards.sample != "all_samples":
        input['raw_fastq_report'] = expand("qc_reports/"+wildcards.sample+"/fastqc/fastqc{read_pair_tags}.html",read_pair_tags=read_pair_tags)
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
        multiqc_config = "../wrappers/multiqc_report/multiqc_config.txt", #upravit cestu!
    conda: "../wrappers/multiqc_report/env.yaml"
    script: "../wrappers/multiqc_report/script.py"

def per_sample_alignment_report_input(wildcards):
    input = {}
    input['multiqc'] = "qc_reports/{sample}/multiqc.html"
    input['raw_fastq_report'] = expand("qc_reports/"+wildcards.sample+"/fastqc/fastqc{read_pair_tags}.html",read_pair_tags = read_pair_tags)
    if config["qc_qualimap_DNA"]:
        input['qc_qualimap_DNA'] = "qc_reports/{sample}/qc_qualimap_DNA/qualimapReport.html"
    return input

rule per_sample_alignment_report:
    input: unpack(per_sample_alignment_report_input)
    output:
        sample_report = "qc_reports/{sample}/final_alignment_report.html",
    log: "logs/{sample}/per_sample_alignment_report.log"
    params:
        multiqc_html_single = "sample_final_reports/{sample}.multiqc_report.html",
        multiqc_html_all= ".multiqc_report.html",#snakemake.params.lib_name + snakemake.params.multiqc_html_final,
        multiqc_config = "/home/245829/Rmarkdown_test/wrappers/multiqc_report/multiqc_config.txt", #upravit cestu!
        lib_name = config["library_name"],
        run_dir = "/mnt/ssd/ssd_1/workspace/katka/Rmarkdown/201111_TP53-20201111/"
    conda: "../wrappers/per_sample_alignment_report/env.yaml"
    script: "../wrappers/per_sample_alignment_report/script.Rmd"

def final_alignment_report_input(wildcards):
    input = {}
    input['all_sample_multiqc'] = "qc_reports/all_samples/multiqc.html"
    input['per_sample_reports'] = expand("qc_reports/{sample}/final_alignment_report.html",sample=sample_tab.sample_name)
    if config["cross_sample_correlation"]:
        input['cross_sample_correlation'] = "qc_reports/cross_sample_correlation/cross_sample_correlation.html"
    return input

rule final_alignment_report:
    input: unpack(final_alignment_report_input)
    output: html="qc_reports/alignment_final_report.html"
    log: "logs/final_alignment_report.log"
    conda: "../wrappers/final_alignment_report/env.yaml"
    script: "../wrappers/final_alignment_report/script.Rmd"

# rule merge_reports:
#     input:  html = set(expand(DIR + "/sample_final_reports/{sample}.final_report.html",sample = cfg[SAMPLE].tolist())),
#             biotype = set(expand(DIR + "/postQC/{sample}/Biotype/{sample}.biotype_counts.txt",sample = cfg[SAMPLE].tolist())),
#     output: html = "alignment_final_report.html",
#     log:    run = DIR + "/"+LIB_NAME+".multiqc_report.log",
#     params: cfg = cfg,
#             multiqc_html = DIR + "/"+LIB_NAME+".multiqc_report.html",
#             dupraxpbox_all_pdf = DIR + "/postQC/"+LIB_NAME+".duprateExpBoxplot_all.pdf",
#             exphist_all_pdf = DIR + "/postQC/"+LIB_NAME+".expressionHist_all.pdf",
#             dupraexpden_all_pdf = DIR + "/postQC/"+LIB_NAME+".duprateExpDens_all.pdf",
#             multipergene_all_pdf = DIR + "/postQC/"+LIB_NAME+".multimapPerGene_all.pdf",
#             readdist_all_pdf = DIR + "/postQC/"+LIB_NAME+".readDist_all.pdf",
#             # biotype_all_txt = DIR + "/postQC/"+LIB_NAME+".biotype_all.txt",
#             biotype_all_pdf = DIR + "/postQC/"+LIB_NAME+".biotype_all.pdf",
#             fastq_screen_all_pdf = DIR + "/postQC/"+LIB_NAME+".fastqscreen_all.pdf",
#             prefix = DIR + "/",
#             lib_name = LIB_NAME,
#             multiqc_config = workflow.basedir + "/../scripts/multiqc_config.txt"
#     conda:  "../wraps/fastq2bam_RNA/merge_reports/env.yaml"
#     script: "../wraps/fastq2bam_RNA/merge_reports/script.py"