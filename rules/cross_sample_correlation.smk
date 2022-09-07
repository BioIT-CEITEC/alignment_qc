# AFTER MAPPING QUALITY CONTROL
#
# CROSS SAMPLE VALIDATION
#

rule snp_vaf_compute:
    input:  bam = BR.remote("mapped/{sample}.bam"),
            ref = BR.remote(expand("{ref_dir}/seq/{ref}.fa",ref_dir=reference_directory, ref = config["reference"])),
            snp_bed = BR.remote(expand("{ref_dir}/others/snp/{ref}.snp.bed",ref_dir=reference_directory,ref = config["reference"])),
            lib_ROI = BR.remote(expand("{ref_dir}/DNA_panel/{lib_ROI}/{lib_ROI}.bed",ref_dir=reference_directory,lib_ROI=config["lib_ROI"]))
    output: vcf = BR.remote("qc_reports/all_samples/cross_sample_correlation/{sample}.snp.vcf"),
    log: BR.remote("logs/cross_sample_correlation/{sample}_snp_vaf_compute.log")
    threads: 1
    conda: "../wrappers/snp_vaf_compute/env.yaml"
    script: "../wrappers/snp_vaf_compute/script.py"


rule cross_sample_correlation:
    input: vcfs = BR.remote(expand("qc_reports/all_samples/cross_sample_correlation/{sample}.snp.vcf",sample=sample_tab.sample_name))
    output: Rdata_for_viz = BR.remote("qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation.Rdata"),
    log: BR.remote("logs/cross_sample_correlation/cross_sample_correlation.log")
    threads: 1
    conda: "../wrappers/cross_sample_correlation/env.yaml"
    script: "../wrappers/cross_sample_correlation/script.py"


rule cross_sample_correlation_viz:
    input:  Rdata_for_viz =  BR.remote("qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation.Rdata"),
    output: html = BR.remote("qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation.snps.html"),
            tsv =  BR.remote("qc_reports/all_samples/cross_sample_correlation/cross_sample_correlation.snps.tsv"),
    log:    BR.remote("logs/cross_sample_correlation/cross_sample_correlation_viz.log")
    threads: 1
    conda: "../wrappers/cross_sample_correlation_viz/env.yaml"
    script: "../wrappers/cross_sample_correlation_viz/script.py"


