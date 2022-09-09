# AFTER MAPPING QUALITY CONTROL
#
# CHIP-SEQ SPECIFIC CONTROLS
#

# def bam_input(wildcards):
#     if wildcards.dups == "no_dups":
#         return "mapped/{sample}.no_dups.bam"
#     else:
#         return "mapped/{sample}.bam"


# TODO: add multiqc config file, generating table with phantompeakqual statistics

# rule phantom_peak_qual:
#     # input:  bam = bam_input,
#     input:  bam = BR.remote("mapped/{sample}.{dups}.bam")
#     output: plot= BR.remote("qc_reports/{sample}/phantompeakqual/{sample}.{dups}.cross-correlation.pdf"),
#             stat= BR.remote("qc_reports/{sample}/phantompeakqual/{sample}.{dups}.phantom_peak_calling_stats.tsv"),
#     log:    BR.remote("logs/{sample}/phantom_peak_qual.{dups}.log"),
#     threads: 2
#     params: bam = BR.remote("qc_reports/{sample}/phantompeakqual/{sample}.{dups}.bam"),
#             bai = BR.remote("qc_reports/{sample}/phantompeakqual/{sample}.{dups}.bam.bai"),
#             tmpd = GLOBAL_TMPD_PATH,
#     conda:  "../wrappers/phantom_peak_qual/env.yaml"
#     script:  "../wrappers/phantom_peak_qual/script.py"
#
#







def filter_bam_input(wc):
    inputs = {'bam': BR.remote("mapped/{sample}.bam")}
    bed = BR.remote(expand("{ref_dir}/DNA_panel/ChIP-seq/blacklist.v2.bed",ref_dir = reference_directory))
    if os.path.isfile(bed):
        inputs['bed'] = bed
    return inputs

rule filter_bam:
    input:  unpack(filter_bam_input)
    output: bam = BR.remote("mapped/{sample}.keep_dups.bam"),
            bam_fail = BR.remote("mapped/{sample}.failed.bam"),
    log:    BR.remote("logs/{sample}/filter_bam.log")
    threads:5
    params: qc_cutof = config['bam_quality_cutof'],
            tmpd = GLOBAL_TMPD_PATH,
    conda:  "../wrappers/filter_bam/env.yaml"
    script:  "../wrappers/filter_bam/script.py"


# #TODO: add stats and create table with counts so it can be merged over samples in main report
# rule check_contamination_blacklist:
#     input:  bam = BR.remote("mapped/{sample}.bam"),
#             lst = BR.remote(expand("{ref_dir}/DNA_panel/ChIP-seq/blacklist.v2.bed",ref_dir=reference_directory)),
#     output: bam_ok = BR.remote("mapped/{sample}.no_contam.bam"),
#             bam_fail = BR.remote("mapped/{sample}.contam.bam"),
#     log:    BR.remote("logs/{sample}/check_contamination_blacklist.log"),
#     threads: 5
#     conda:  "../wrappers/check_contamination_blacklist/env.yaml"
#     script:  "../wrappers/check_contamination_blacklist/script.py"
#
    
# def dedup_bam_input(wildcards):
#     bed = reference_directory+"/intervals/ChIP-seq/blacklist.v2.bed"
#     if os.path.isfile(bed):
#         return "mapped/{sample}.no_contam.bam"
#     else:
#         return "mapped/{sample}.bam"

# rule dedup_bam:
#     # input:  bam = dedup_bam_input,
#     input:  bam = BR.remote("mapped/{sample}.keep_dups.bam")
#     output: bam = BR.remote("mapped/{sample}.no_dups.bam"),
#     log:    BR.remote("logs/{sample}/dedup_bam.log")
#     threads: 5,
#     params: tmpd= GLOBAL_TMPD_PATH,
#     conda:  "../wrappers/dedup_bam/env.yaml"
#     script: "../wrappers/dedup_bam/script.py"
#

rule qc_samtools_extra:
    input:  bam = BR.remote("mapped/AK1852fuze.keep_dups.bam")
    output: idxstats = BR.remote("qc_reports/AK1852fuze/qc_samtools/AK1852fuze.keep_dups.idxstats.tsv"),
            flagstats = BR.remote("qc_reports/AK1852fuze/qc_samtools/AK1852fuze.keep_dups.flagstat.tsv")
    log:    BR.remote("logs/AK1852fuze/qc_samtools_extra.keep_dups.log")
    threads:    1
    conda: "../wrappers/qc_samtools/env.yaml"
    script: "../wrappers/qc_samtools/script.py"


# rule inspect_bam_coverage:
#     input:  bam = BR.remote("mapped/{sample}.{dups}.bam"),
#     output: bw =  BR.remote("mapped/{sample}.{dups}.bam.bigWig"),
#     log:    BR.remote("logs/{sample}/inspect_bam_coverage.{dups}.log"),
#     threads: 5
#     params: effective_GS = config["effective_genome_size"],
#             frag_len = config["fragment_length"],
#             tmpd = GLOBAL_TMPD_PATH,
#     conda:  "../wrappers/inspect_bam_coverage/env.yaml"
#     script:  "../wrappers/inspect_bam_coverage/script.py"


# def multi_bam_summary_inputs(wildcards):
#     if wildcards.dups == "no_dups":
#         return ["mapped/"+x+".no_dups.bam" for x in sample_tab.sample_name]
#     else:
#         return ["mapped/"+x+".bam" for x in sample_tab.sample_name]
#
# rule multi_bam_summary:
#     # input:  bam = multi_bam_summary_inputs,
#     input:  bam = BR.remote(expand("mapped/{sample}.{{dups}}.bam", sample=sample_tab.sample_name))
#     output: plot = BR.remote("qc_reports/all_samples/deeptools/correlation_heatmap.{dups}.pdf"),
#             table= BR.remote("qc_reports/all_samples/deeptools/correlation_heatmap.{dups}.tsv"),
#             finger = BR.remote("qc_reports/all_samples/deeptools/fingerprint.{dups}.pdf"),
#             counts = BR.remote("qc_reports/all_samples/deeptools/fingerprint.{dups}.raw_counts"),
#             quality= BR.remote("qc_reports/all_samples/deeptools/fingerprint.{dups}.quality_metrics"),
#             matrix= BR.remote("qc_reports/all_samples/deeptools/multi_bam_summary.{dups}.npz"),
#     log:    BR.remote("logs/all_samples/multi_bam_summary.{dups}.log"),
#     threads: 20
#     params: corr_method = config["summary_correlation_method"],
#     conda:  "../wrappers/multi_bam_summary/env.yaml"
#     script: "../wrappers/multi_bam_summary/script.py"
