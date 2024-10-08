# AFTER MAPPING QUALITY CONTROL
#
# CROSS SAMPLE VALIDATION
#


rule cross_sample_correlation_viz:
    input:  Rdata_for_viz =  "qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation.Rdata",
    output: html = "qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation.snps.html",
            tsv =  "qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation.snps.tsv",
    log:    "logs/cross_sample_correlation/cross_sample_correlation_viz.log"
    params: output = "qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation"
    threads: 1
    conda: "../wrappers/cross_sample_correlation_viz/env.yaml"
    script: "../wrappers/cross_sample_correlation_viz/script.py"


rule cross_sample_correlation:
    input:  vcfs = expand("qc_reports/all_samples/cross_sample_correlation/{sample}.snp.vcf",sample = sample_tab.sample_name)
    output: Rdata_for_viz =  "qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation.Rdata",
    log:    "logs/cross_sample_correlation/cross_sample_correlation.log"
    params: output = "qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation"
    threads: 1
    conda: "../wrappers/cross_sample_correlation/env.yaml"
    script: "../wrappers/cross_sample_correlation/script.py"


rule snp_vaf_compute:
    input:  bam = "mapped/{sample}.bam",
            ref = config["organism_fasta"],
            snp_bed = config["organism_snp_bed"],
            lib_ROI = config["organism_dna_panel"]
    output: vcf = "qc_reports/all_samples/cross_sample_correlation/{sample}.snp.vcf",
    log:    "logs/cross_sample_correlation/{sample}_snp_vaf_compute.log"
    params: intersect_bed = "qc_reports/all_samples/cross_sample_correlation/{sample}.snp_tmp_intersect.bed"
    threads: 1
    conda: "../wrappers/snp_vaf_compute/env.yaml"
    script: "../wrappers/snp_vaf_compute/script.py"

