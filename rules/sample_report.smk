# REPORTING RULES
#


def multiqc_report_input(wildcards):
    input = {}
    if wildcards.sample != "all_samples":
        input['raw_fastq_report'] = expand("qc_reports/"+wildcards.sample+"/raw_fastqc/fastqc{read_pair_tags}.html",read_pair_tags=read_pair_tags)
        if config["qc_qualimap_DNA"]:
            input['qc_qualimap_DNA'] = "qc_reports/{sample}/qc_qualimap_DNA/{sample}/qualimapReport.html"
        if config["qc_samtools"]:
            input['qc_samtools'] = "qc_reports/{sample}/qc_samtools/idxstats.tsv"
        if config["qc_picard_DNA"]:
            input['qc_picard_DNA'] = "qc_reports/{sample}/qc_picard_DNA/picard.tsv"
        if config["qc_qualimap_DNA"]:
            input['qc_qualimap_DNA'] = "qc_reports/{sample}/qc_qualimap_DNA/{sample}/qualimapReport.html"
        if config["qc_picard_RNA"]:
            input['qc_picard_RNA'] = "qc_reports/{sample}/qc_picard_RNA/{sample}.npc.pdf"
        if config["feature_count"]:
            input['feature_count'] = "feature_count/{sample}.featureCounts.tsv"
        if config["qc_fastq_screen_RNA"]:
            input['qc_fastq_screen_RNA'] = "qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.png"
        # if config["biobloom"]:
        #     input['biobloom'] = "cleaned_fastq/{sample}.biobloom_summary.tsv"
        if config["qc_qualimap_RNA"]:
            input['qc_qualimap_RNA'] = "qc_reports/{sample}/qc_qualimap_RNA/{sample}/qualimapReport.html"
        if config["qc_RSeQC_RNA"]:
            input['qc_RSeQC_RNA'] = "qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC.read_distribution.txt"
        if config["qc_biotypes_RNA"]:
            input['qc_biotypes_RNA'] = "qc_reports/{sample}/qc_biotypes_RNA/{sample}.biotype_counts.txt"
    else:
        input['per_sample_reports'] = expand("qc_reports/{sample}/single_sample_alignment_report.html",sample=sample_tab.sample_name)
    return input

rule multiqc_report:
    input: unpack(multiqc_report_input)
    output: html="qc_reports/{sample}/multiqc.html"
    log: "logs/{sample}/multiqc.log"
    params:
        multiqc_config = workflow.basedir+"/wrappers/multiqc_report/multiqc_config.txt",
        multiqc_path = "qc_reports/{sample}/"
    conda: "../wrappers/multiqc_report/env.yaml"
    script: "../wrappers/multiqc_report/script.py"

def per_sample_alignment_report_input(wildcards):
    input = {}
    input['multiqc'] = "qc_reports/{sample}/multiqc.html"
    input['raw_fastq_R1_report'] = "qc_reports/" + wildcards.sample + "/raw_fastqc/fastqc_R1.html"
    input['raw_fastq_R2_report'] = "qc_reports/" + wildcards.sample + "/raw_fastqc/fastqc_R2.html"
    if config["qc_qualimap_DNA"]:
        input['qc_qualimap_DNA'] = "qc_reports/{sample}/qc_qualimap_DNA/{sample}/qualimapReport.html"
    if config["qc_picard_RNA"]:
        input['qc_picard_RNA'] = "qc_reports/{sample}/qc_picard_RNA/{sample}.npc.pdf"
    if config["feature_count"]:
        input['feature_count'] = "feature_count/{sample}.featureCounts.tsv"
    if config["qc_fastq_screen_RNA"]:
        input['qc_fastq_screen_RNA'] = "qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.png"
    # if config["biobloom"]:
    #     input['biobloom'] = "cleaned_fastq/{sample}.biobloom_summary.tsv"
    if config["qc_biotypes_RNA"]:
        input['qc_biotypes_RNA'] = "qc_reports/{sample}/qc_biotypes_RNA/{sample}.biotype_counts.txt"
    return input

rule per_sample_alignment_report:
    input: unpack(per_sample_alignment_report_input)
    output: sample_report = "qc_reports/{sample}/single_sample_alignment_report.html",
    params: sample_name = "{sample}",
            config = "./config.json"
    conda: "../wrappers/per_sample_alignment_report/env.yaml"
    script: "../wrappers/per_sample_alignment_report/script.Rmd"

def final_alignment_report_input(wildcards):
    input = {}
    input['all_sample_multiqc'] = "qc_reports/all_samples/multiqc.html"
    input['per_sample_reports'] = expand("qc_reports/{sample}/single_sample_alignment_report.html",sample=sample_tab.sample_name)
    if config["cross_sample_correlation"]:
        input['cross_sample_correlation'] = "qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation.snps.html"
    if config["qc_fastq_screen_RNA"]:
        input['qc_fastq_screen_RNA'] = "qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.png"
    if config["qc_dupradar_RNA"]:
        input['dupraxpbox'] = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_duprateExpBoxplot.pdf"
        input['exphist'] = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_expressionHist.pdf"
        input['dupraexpden'] = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_duprateExpDens.pdf"
        input['multipergene'] = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_multimapPerGene.pdf"
        input['readdist'] = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_readDist.pdf"
    return input

rule final_alignment_report:
    input: unpack(final_alignment_report_input)
    output: html="qc_reports/final_alignment_report.html"
    params:
        sample_name = sample_tab.sample_name,
        config="./config.json"
    conda: "../wrappers/final_alignment_report/env.yaml"
    script: "../wrappers/final_alignment_report/script.Rmd"
