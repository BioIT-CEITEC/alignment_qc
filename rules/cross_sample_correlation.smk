# AFTER MAPPING QUALITY CONTROL
#
# CROSS SAMPLE VALIDATION
#


rule cross_sample_correlation_viz:
    input:  Rdata_for_viz =  fetch_data("qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation.Rdata"),
    output: html = fetch_data("qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation.snps.html"),
            tsv =  fetch_data("qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation.snps.tsv"),
    log:    fetch_data("logs/cross_sample_correlation/cross_sample_correlation_viz.log")
    params: output = fetch_data("qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation")
    threads: 1
    conda: "../wrappers/cross_sample_correlation_viz/env.yaml"
    script: "../wrappers/cross_sample_correlation_viz/script.py"

rule cross_sample_correlation:
    input:  vcfs = fetch_data(expand("qc_reports/all_samples/cross_sample_correlation/{sample}.snp.vcf",sample = sample_tab.sample_name))
    output: Rdata_for_viz =  fetch_data("qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation.Rdata"),
    log:    fetch_data("logs/cross_sample_correlation/cross_sample_correlation.log")
    params: output = fetch_data("qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation")
    threads: 1
    conda: "../wrappers/cross_sample_correlation/env.yaml"
    script: "../wrappers/cross_sample_correlation/script.py"

rule snp_vaf_compute:
    input: bam = fetch_data("mapped/{sample}.bam"),
           ref = fetch_data(expand("{ref_dir}/seq/{ref}.fa",ref_dir=reference_directory, ref = config["reference"])),
           snp_bed = fetch_data(expand("{ref_dir}/other/snp/{ref}.snp.bed",ref_dir=reference_directory,ref = config["reference"])),
           lib_ROI = fetch_data(expand("{ref_dir}/intervals/{lib_ROI}/{lib_ROI}.bed",ref_dir=reference_directory,lib_ROI=config["lib_ROI"]))
    output: vcf = fetch_data("qc_reports/all_samples/cross_sample_correlation/{sample}.snp.vcf"),
    log:    fetch_data("logs/cross_sample_correlation/{sample}_snp_vaf_compute.log")
    params: intersect_bed = fetch_data("qc_reports/all_samples/cross_sample_correlation/{sample}.snp_tmp_intersect.bed")
    threads: 1
    conda: "../wrappers/snp_vaf_compute/env.yaml"
    script: "../wrappers/snp_vaf_compute/script.py"

