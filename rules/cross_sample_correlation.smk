# AFTER MAPPING QUALITY CONTROL
#
# CROSS SAMPLE VALIDATION
#

rule cross_sample_correlation_viz:
    input:  Rdata_for_viz = "map_qc/cross_sample_correlation/{lib_name}.cross_sample_correlation.Rdata"
    output: html = "map_qc/cross_sample_correlation/{lib_name}.cross_sample_correlation.snps.html",
            tsv = "map_qc/cross_sample_correlation/{lib_name}.cross_sample_correlation.snps.tsv",
    log:    run = "map_qc/cross_sample_correlation/{lib_name}.cross_sample_correlation_viz.log"
    params: output = "map_qc/cross_sample_correlation/{lib_name}.cross_sample_correlation"
    threads: 1
    conda: "../wrappers/cross_sample_correlation_viz/env.yaml"
    script: "../wrappers/cross_sample_correlation_viz/script.py"

rule cross_sample_correlation:
    input:  vcfs = expand("map_qc/cross_sample_correlation/{sample}.snp.vcf",sample = sample_tab.sample_name)
    output: Rdata_for_viz = "map_qc/cross_sample_correlation/{lib_name}.cross_sample_correlation.Rdata",
    log:    run = "map_qc/cross_sample_correlation/{lib_name}.cross_sample_correlation.log"
    params: output = "map_qc/cross_sample_correlation/{lib_name}.cross_sample_correlation"
    threads: 1
    conda: "../wrappers/cross_sample_correlation/env.yaml"
    script: "../wrappers/cross_sample_correlation/script.py"

rule snp_vaf_compute:
    input: bam = "mapped/{sample}.bam",
           ref = expand("{ref_dir}/seq/{ref}.fa",ref_dir=reference_directory, ref = config["reference"])[0],
           snp_bed = expand("{ref_dir}/other/snp/{ref}.snp.bed",ref_dir=reference_directory,ref = config["reference"])[0],
           region_bed = expand("{ref_dir}/intervals/{lib_ROI}/{lib_ROI}.bed",ref_dir=reference_directory,lib_ROI=config["lib_ROI"])[0]
    output: vcf = "map_qc/cross_sample_correlation/{sample}.snp.vcf",
    log:    run = "sample_logs/{sample}/snp_vaf_compute.log"
    params: intersect_bed = "map_qc/cross_sample_correlation/{sample}.snp_tmp_intersect.bed"
    threads: 1
    conda: "../wrappers/snp_vaf_compute/env.yaml"
    script: "../wrappers/snp_vaf_compute/script.py"
