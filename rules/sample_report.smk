# REPORTING RULES
#


def multiqc_report_input(wildcards):
    input = {}
    if wildcards.sample != "all_samples":
        sample_list = wildcards.sample
    else:
        sample_list = sample_tab.sample_name
        input['per_sample_reports'] = BR.remote(expand("qc_reports/{sample}/single_sample_alignment_report.html",sample=sample_tab.sample_name))


    if config["is_paired"]:
        input['raw_fastq_R1_report'] = BR.remote(expand("qc_reports/{sample}/raw_fastqc/R1_fastqc.zip",sample=sample_list))
        input['raw_fastq_R2_report'] = BR.remote(expand("qc_reports/{sample}/raw_fastqc/R2_fastqc.zip",sample=sample_list))
    # input['cleaned_fastq_R1_report'] = BR.remote("qc_reports/{sample}/cleaned_fastqc/R1_fastqc.zip")
    # input['cleaned_fastq_R2_report'] = BR.remote("qc_reports/{sample}/cleaned_fastqc/R2_fastqc.zip")
    else:
        input['raw_fastq_SE_report'] = BR.remote(expand("qc_reports/{sample}/raw_fastqc/SE_fastqc.zip",sample=sample_list))
    # input['cleaned_fastq_SE_report'] = BR.remote("qc_reports/{sample}/cleaned_fastqc/SE_fastqc.zip")
    if config["qc_qualimap_DNA"]:
        input['qc_qualimap_DNA'] = BR.remote(expand("qc_reports/{sample}/qc_qualimap_DNA/{sample}/qualimapReport.html",sample=sample_list))
    if config["qc_samtools"]:
        input['qc_samtools'] = BR.remote(expand("qc_reports/{sample}/qc_samtools/{sample}.idxstats.tsv",sample=sample_list))
    if config["qc_picard_DNA"]:
        if config["lib_ROI"] != "wgs":
            input['qc_picard_DNA'] = BR.remote(expand("qc_reports/{sample}/qc_picard_DNA/picard_table.per_target.tsv",sample=sample_list))
            input['qc_picard_DNA_metrics'] = BR.remote(expand("qc_reports/{sample}/qc_picard_DNA/picard.per_target.tsv",sample=sample_list))
        else:
            input['qc_picard_DNA'] = BR.remote(expand("qc_reports/{sample}/qc_picard_DNA/picard_table.wgs_chart.tsv", sample=sample_list))
            input['qc_picard_DNA_metrics'] = BR.remote(expand("qc_reports/{sample}/qc_picard_DNA/picard.wgs_chart.pdf",sample=sample_list))
    if config["qc_qualimap_RNA"]:
        input['qc_qualimap_RNA'] = BR.remote(expand("qc_reports/{sample}/qc_qualimap_RNA/{sample}/qualimapReport.html",sample=sample_list))
    if config["qc_picard_RNA"]:
        input['qc_picard_RNA'] = BR.remote(expand("qc_reports/{sample}/qc_picard_RNA/{sample}.npc.pdf",sample=sample_list))
    if config["feature_count"]:
        input['feature_count'] = BR.remote(expand("qc_reports/{sample}/feature_count/{sample}.feature_count.tsv",sample=sample_list))
    if config["qc_fastq_screen_RNA"]:
        input['qc_fastq_screen_RNA'] = BR.remote(expand("qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.png",sample=sample_list,read_pair_tag=read_pair_tags))
    if config["biobloom"]:
        input['biobloom'] = BR.remote(expand("qc_reports/{sample}/biobloom/{sample}.biobloom_summary.tsv",sample=sample_list))
    if config["RSEM"]:
        input['RSEM'] = BR.remote(expand("qc_reports/{sample}/RSEM/{sample}.genes.results",sample=sample_list))
    if config["salmon_align"]:
        input["salmon_align"] = BR.remote(expand("qc_reports/{sample}/salmon/{sample}_aln/{sample}.salmon_aln.sf",sample=sample_list))
        input["salmon_align_tab"] = BR.remote(expand("qc_reports/{sample}/salmon/{sample}_aln/{sample}_aln.tsv",sample=sample_list))
    if config["salmon_map"]:
        input["salmon_map"] = BR.remote(expand("qc_reports/{sample}/salmon/{sample}_map/{sample}.salmon_map.sf",sample=sample_list))
        input["salmon_map_tab"] = BR.remote(expand("qc_reports/{sample}/salmon/{sample}_map/{sample}_map.tsv",sample=sample_list))
    if config["kallisto"]:
        input['kallisto_h5'] = BR.remote(expand("qc_reports/{sample}/kallisto/{sample}.kallisto.h5",sample=sample_list))
        input['kallisto_tsv'] = BR.remote(expand("qc_reports/{sample}/kallisto/{sample}.kallisto.tsv",sample=sample_list))
    if config["qc_RSeQC_RNA"]:
        input['qc_RSeQC_RNA'] = BR.remote(expand("qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC.read_distribution.txt",sample=sample_list))
    if config["qc_biotypes_RNA"]:
        input['qc_biotypes_RNA'] = BR.remote(expand("qc_reports/{sample}/qc_biotypes_RNA/{sample}.biotype_counts.txt",sample=sample_list))
        #if it's DNA or RNA
    if config["qc_qualimap_DNA"]:
        input['trim'] = BR.remote(expand("qc_reports/{sample}/trim_galore/trim_stats{read_pair_tag}.log",sample=sample_tab.sample_name,read_pair_tag=read_pair_tags))
    else:
        input['trim'] = BR.remote(expand("qc_reports/{sample}/trimmomatic/trim_stats.log",sample=sample_tab.sample_name))

    input["multiqc_config"] = BR.remote("wrappers/multiqc_report/multiqc_config.txt")
    return input


rule multiqc_report:
    input:  unpack(multiqc_report_input)
    output: html=BR.remote("qc_reports/{sample}/multiqc.html")
    log:    BR.remote("logs/{sample}/multiqc.log")
    params: paired = config["is_paired"],
            path = BR.remote(config["task_name"])
    conda: "../wrappers/multiqc_report/env.yaml"
    script: "../wrappers/multiqc_report/script.py"


def merge_single_sample_reports_input(wildcards):
    input = {}
    if config["qc_biotypes_RNA"]:
        input['biotype'] = BR.remote(expand("qc_reports/{sample}/qc_biotypes_RNA/{sample}.biotype_counts.txt",sample=sample_tab.sample_name))
    if config["qc_fastq_screen_RNA"]:
        input['fastq_screen'] = BR.remote(expand("qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.pdf",sample=sample_tab.sample_name,read_pair_tag=read_pair_tags))
    if config["qc_dupradar_RNA"]:
        input['dupraxpbox'] = BR.remote(expand("qc_reports/{sample}/qc_dupradar_RNA/{sample}_duprateExpBoxplot.pdf",sample=sample_tab.sample_name))
        input['exphist'] = BR.remote(expand("qc_reports/{sample}/qc_dupradar_RNA/{sample}_expressionHist.pdf",sample=sample_tab.sample_name))
        input['dupraexpden'] = BR.remote(expand("qc_reports/{sample}/qc_dupradar_RNA/{sample}_duprateExpDens.pdf",sample=sample_tab.sample_name))
        input['multipergene'] = BR.remote(expand("qc_reports/{sample}/qc_dupradar_RNA/{sample}_multimapPerGene.pdf",sample=sample_tab.sample_name))
        input['readdist'] = BR.remote(expand("qc_reports/{sample}/qc_dupradar_RNA/{sample}_readDist.pdf",sample=sample_tab.sample_name))
    if config["chip_extra_qc"]:
        input['phantompeak'] = BR.remote(expand("qc_reports/{sample}/phantompeakqual/{sample}.{dups}.cross-correlation.pdf", sample=sample_tab.sample_name, dups=['no_dups']))
        input['phantompeak_dups'] = BR.remote(expand("qc_reports/{sample}/phantompeakqual/{sample}.{dups}.cross-correlation.pdf", sample=sample_tab.sample_name, dups=['keep_dups']))
    return input

rule merge_single_sample_reports:
    input:  unpack(merge_single_sample_reports_input)
    output: biotype_pdf = BR.remote("qc_reports/all_samples/qc_biotype_RNA/biotype.pdf"),
            fastq_screen_pdf = BR.remote("qc_reports/all_samples/fastq_screen/fastq_screen.pdf"),
            dupraxpbox_pdf = BR.remote("qc_reports/all_samples/qc_dupradar_RNA/dupraxpbox.pdf"),
            exphist_pdf = BR.remote("qc_reports/all_samples/qc_dupradar_RNA/exphist.pdf"),
            dupraexpden_pdf = BR.remote("qc_reports/all_samples/qc_dupradar_RNA/dupraexpden.pdf"),
            multipergene_pdf = BR.remote("qc_reports/all_samples/qc_dupradar_RNA/multipergene.pdf"),
            readdist_pdf = BR.remote("qc_reports/all_samples/qc_dupradar_RNA/readdist.pdf"),
            phantompeak_pdf=BR.remote("qc_reports/all_samples/phantompeakqual/cross-correlation.no_dups.pdf"),
            phantompeak_dups_pdf=BR.remote("qc_reports/all_samples/phantompeakqual/cross-correlation.keep_dups.pdf"),
    log:    BR.remote("logs/all_samples/merge_single_sample_reports.log")
    conda: "../wrappers/merge_single_sample_reports/env.yaml"
    script: "../wrappers/merge_single_sample_reports/script.py"


def per_sample_alignment_report_input(wildcards):
    input = {}
    input['multiqc'] = BR.remote("qc_reports/{sample}/multiqc.html")
    if config["is_paired"]:
        input['raw_fastq_R1_report'] = BR.remote("qc_reports/{sample}/raw_fastqc/R1_fastqc.html")
        input['raw_fastq_R2_report'] = BR.remote("qc_reports/{sample}/raw_fastqc/R2_fastqc.html")
        # input['cleaned_fastq_R1_report'] = "qc_reports/{sample}/cleaned_fastqc/R1_fastqc.html"
        # input['cleaned_fastq_R2_report'] = "qc_reports/{sample}/cleaned_fastqc/R2_fastqc.html"
    else:
        input['raw_fastq_SE_report'] = BR.remote("qc_reports/{sample}/raw_fastqc/SE_fastqc.html")
        # input['cleaned_fastq_SE_report'] = "qc_reports/{sample}/cleaned_fastqc/SE_fastqc.html"
    if config["qc_qualimap_DNA"]:
        input['qc_qualimap_DNA'] = BR.remote("qc_reports/{sample}/qc_qualimap_DNA/{sample}/qualimapReport.html")
    if config["qc_picard_RNA"]:
        input['qc_picard_RNA'] = BR.remote("qc_reports/{sample}/qc_picard_RNA/{sample}.npc.pdf")
    if config["qc_qualimap_RNA"]:
        input['qc_qualimap_RNA'] = BR.remote("qc_reports/{sample}/qc_qualimap_RNA/{sample}/qualimapReport.html")
    if config["feature_count"]:
        input['feature_count'] = BR.remote("qc_reports/{sample}/feature_count/{sample}.feature_count.tsv")
    if config["qc_fastq_screen_RNA"]:
        input['qc_fastq_screen_RNA'] = BR.remote(expand("qc_reports/{{sample}}/qc_fastq_screen_RNA/{{sample}}{read_pair_tag}_screen.png",read_pair_tag=read_pair_tags))
    if config["biobloom"]:
        input['biobloom'] = BR.remote("qc_reports/{sample}/biobloom/{sample}.biobloom_summary.tsv")
    if config["qc_biotypes_RNA"]:
        input['qc_biotypes_RNA'] = BR.remote("qc_reports/{sample}/qc_biotypes_RNA/{sample}.biotype_counts.pdf")
    if config["RSEM"]:
        input['RSEM'] = BR.remote("qc_reports/{sample}/RSEM/{sample}.genes.results")
    if config["salmon_align"]:
        input["salmon_align"] = BR.remote("qc_reports/{sample}/salmon/{sample}_aln/{sample}.salmon_aln.sf")
        input["salmon_align_tab"] = BR.remote("qc_reports/{sample}/salmon/{sample}_aln/{sample}_aln.tsv")
    if config["salmon_map"]:
        input["salmon_map"] = BR.remote("qc_reports/{sample}/salmon/{sample}_map/{sample}.salmon_map.sf")
        input["salmon_map_tab"] = BR.remote("qc_reports/{sample}/salmon/{sample}_map/{sample}_map.tsv")
    if config["kallisto"]:
        input['kallisto_h5'] = BR.remote("qc_reports/{sample}/kallisto/{sample}.kallisto.h5")
        input['kallisto_tsv'] = BR.remote("qc_reports/{sample}/kallisto/{sample}.kallisto.tsv")
    if config["qc_RSeQC_RNA"]:
        input['qc_RSeQC_RNA'] = BR.remote("qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC.read_distribution.txt")
    if config["chip_extra_qc"]:
        input['samtools_contam'] = BR.remote("qc_reports/{sample}/qc_samtools/{sample}.keep_dups.flagstat.tsv")
        input['samtools_dups'] = BR.remote("qc_reports/{sample}/qc_samtools/{sample}.no_dups.flagstat.tsv")
        input['keep_dups_bam_cov'] = BR.remote("mapped/{sample}.keep_dups.bam.bigWig")
        input['no_dups_bam_cov'] = BR.remote("mapped/{sample}.no_dups.bam.bigWig")
        input['phantompeak'] = BR.remote("qc_reports/{sample}/phantompeakqual/{sample}.no_dups.cross-correlation.pdf")
        input['phantompeak_dups'] = BR.remote("qc_reports/{sample}/phantompeakqual/{sample}.keep_dups.cross-correlation.pdf")
    return input

rule per_sample_alignment_report:
    input:  unpack(per_sample_alignment_report_input)
    output: sample_report = BR.remote("qc_reports/{sample}/single_sample_alignment_report.html"),
    params: sample_name = "{sample}",
            config = "config.json",
            paired = config["is_paired"],
    conda: "../wrappers/per_sample_alignment_report/env.yaml"
    script: "../wrappers/per_sample_alignment_report/script.Rmd"


def final_alignment_report_input(wildcards):
    input = {}
    input['all_sample_multiqc'] = BR.remote("qc_reports/all_samples/multiqc.html")
    input['per_sample_reports'] = BR.remote(expand("qc_reports/{sample}/single_sample_alignment_report.html",sample=sample_tab.sample_name))
    if config["cross_sample_correlation"]:
        input['cross_sample_correlation'] = BR.remote("qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation.snps.html")
    if config["qc_biotypes_RNA"]:
        input['qc_biotypes_RNA'] = BR.remote("qc_reports/all_samples/qc_biotype_RNA/biotype.pdf")
    if config["qc_fastq_screen_RNA"]:
        input['qc_fastq_screen_RNA'] = BR.remote("qc_reports/all_samples/fastq_screen/fastq_screen.pdf")
    if config["qc_dupradar_RNA"]:
        input['dupraxpbox'] = BR.remote("qc_reports/all_samples/qc_dupradar_RNA/dupraxpbox.pdf")
        input['exphist'] = BR.remote("qc_reports/all_samples/qc_dupradar_RNA/exphist.pdf")
        input['dupraexpden'] = BR.remote("qc_reports/all_samples/qc_dupradar_RNA/dupraexpden.pdf")
        input['multipergene'] = BR.remote("qc_reports/all_samples/qc_dupradar_RNA/multipergene.pdf")
        input['readdist'] = BR.remote("qc_reports/all_samples/qc_dupradar_RNA/readdist.pdf")
    if config["chip_extra_qc"]:
        input['phantompeak'] = BR.remote("qc_reports/all_samples/phantompeakqual/cross-correlation.no_dups.pdf")
        input['phantompeak_dups'] = BR.remote("qc_reports/all_samples/phantompeakqual/cross-correlation.keep_dups.pdf")
        input['corr_heatmap'] = BR.remote("qc_reports/all_samples/deeptools/correlation_heatmap.no_dups.pdf")
        input['corr_heatmap_dups'] = BR.remote("qc_reports/all_samples/deeptools/correlation_heatmap.keep_dups.pdf")
        input["fingerprint"] = BR.remote("qc_reports/all_samples/deeptools/fingerprint.no_dups.pdf")
        input["fingerprint_dups"] = BR.remote("qc_reports/all_samples/deeptools/fingerprint.keep_dups.pdf")
    return input

rule final_alignment_report:
    input:  unpack(final_alignment_report_input)
    output: html = BR.remote("qc_reports/final_alignment_report.html")
    params: sample_name = sample_tab.sample_name,
            config = "config.json"
    conda: "../wrappers/final_alignment_report/env.yaml"
    script: "../wrappers/final_alignment_report/script.Rmd"
