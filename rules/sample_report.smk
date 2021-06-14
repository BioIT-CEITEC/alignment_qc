# REPORTING RULES
#
# all = final whole run report



def single_sample_report_DNA_input(wildcards):
    input = {
        'raw_fastqc': "map_qc/picard/"}
    if config["qc_picard_DNA"]:
        input['picard'] = expand("map_qc/picard/{sample}.picard.tsv",sample=sample_tab.sample_name)
    if config["qc_qualimap_DNA"]:
        input['qualimap'] = expand("map_qc/qualimap/{sample}/qualimapReport.pdf",sample=sample_tab.sample_name)
    if config["qc_samtools_DNA"]:
        input['samtools'] = expand("map_qc/samtools/{sample}.idxstats.tsv",sample=sample_tab.sample_name)
    return input


rule multiqc_report:
    input:  "general_analysis_report.html",
    output: report = "multiqc_report.html",
    log:    run = "multiqc_report.log",
    params:
        multiqc_html = "sample_final_reports/multiqc_report.html",
        multiqc_config = "/home/245829/Rmarkdown_test/wrappers/multiqc_report/multiqc_config.txt", #upravit cestu!
        lib_name = config["library_name"],
        sample_name = sample_tab.sample_name.tolist,
        run_dir = "/mnt/ssd/ssd_1/workspace/katka/Rmarkdown/201111_TP53-20201111/"
    conda:  "../wrappers/multiqc_report/env.yaml"
    script: "../wrappers/multiqc_report/script.py"


rule single_sample_report_DNA:
    input: unpack(single_sample_report_DNA_input)
    output: html = "general_analysis_report.html"
    log: run = "sample_final_reports/final_sample_report.html"
    conda: "../wrappers/single_sample_report_DNA/env.yaml"
    script: "../wrappers/single_sample_report_DNA/test_markdown.Rmd"
