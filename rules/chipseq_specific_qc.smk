# AFTER MAPPING QUALITY CONTROL
#
# CHIP-SEQ SPECIFIC CONTROLS
#

# def bam_input(wildcards):
#     if wildcards.dups == "no_dups":
#         return "mapped/{sample}.no_dups.bam"
#     else:
#         return "mapped/{sample}.bam"

#TODO: add multiqc config file, generating table with phantompeakqual statistics
rule phantom_peak_qual:
    # input:  bam = bam_input,
    input:  bam = "mapped/{sample}.{dups}.bam"
    output: plot= "qc_reports/{sample}/phantompeakqual/{sample}.{dups}.cross-correlation.pdf",
            stat= "qc_reports/{sample}/phantompeakqual/{sample}.{dups}.phantom_peak_calling_stats.tsv",
    log:    "logs/{sample}/phantom_peak_qual.{dups}.log",
    threads: 2
    params: bam = "qc_reports/{sample}/phantompeakqual/{sample}.{dups}.bam",
            bai = "qc_reports/{sample}/phantompeakqual/{sample}.{dups}.bam.bai",
            tmpd = GLOBAL_TMPD_PATH,
    conda:  "../wrappers/phantom_peak_qual/env.yaml"
    script:  "../wrappers/phantom_peak_qual/script.py"


rule inspect_bam_coverage:
    input:  bam = "mapped/{sample}.{dups}.bam",
    output: bw =  "mapped/{sample}.{dups}.bam.bigWig",
    log:    "logs/{sample}/inspect_bam_coverage.{dups}.log",
    threads: 5
    params: effective_GS = config["effective_genome_size"],
            frag_len = config["fragment_length"],
            tmpd = GLOBAL_TMPD_PATH,
    conda:  "../wrappers/inspect_bam_coverage/env.yaml"
    script:  "../wrappers/inspect_bam_coverage/script.py"


# def multi_bam_summary_inputs(wildcards):
#     if wildcards.dups == "no_dups":
#         return ["mapped/"+x+".no_dups.bam" for x in sample_tab.sample_name]
#     else:
#         return ["mapped/"+x+".bam" for x in sample_tab.sample_name]

rule multi_bam_summary:
    # input:  bam = multi_bam_summary_inputs,
    input:  bam = expand("mapped/{sample}.{{dups}}.bam", sample=sample_tab.sample_name)
    output: plot = "qc_reports/all_samples/deeptools/correlation_heatmap.{dups}.pdf",
            table= "qc_reports/all_samples/deeptools/correlation_heatmap.{dups}.tsv",
            finger = "qc_reports/all_samples/deeptools/fingerprint.{dups}.pdf",
            counts = "qc_reports/all_samples/deeptools/fingerprint.{dups}.raw_counts",
            quality= "qc_reports/all_samples/deeptools/fingerprint.{dups}.quality_metrics",
    log:    "logs/all_samples/multi_bam_summary.{dups}.log",
    threads: 20
    params: matrix = "qc_reports/all_samples/deeptools/multi_bam_summary.{dups}.npz",
            corr_method = config["summary_correlation_method"],
    conda:  "../wrappers/multi_bam_summary/env.yaml"
    script: "../wrappers/multi_bam_summary/script.py"
    

rule qc_samtools_extra:
    input:  bam = "mapped/{sample}.{extra}.bam"
    output: idxstats = "qc_reports/{sample}/qc_samtools/{sample}.{extra}.idxstats.tsv",
            flagstats = "qc_reports/{sample}/qc_samtools/{sample}.{extra}.flagstat.tsv"
    log:    "logs/{sample}/qc_samtools_extra.{extra}.log"
    threads:    1
    conda: "../wrappers/qc_samtools/env.yaml"
    script: "../wrappers/qc_samtools/script.py"


# def dedup_bam_input(wildcards):
#     bed = reference_directory+"/intervals/ChIP-seq/blacklist.v2.bed"
#     if os.path.isfile(bed):
#         return "mapped/{sample}.no_contam.bam"
#     else:
#         return "mapped/{sample}.bam"

rule dedup_bam:
    # input:  bam = dedup_bam_input,
    input:  bam = "mapped/{sample}.keep_dups.bam"
    output: bam = "mapped/{sample}.no_dups.bam",
    log:    "logs/{sample}/dedup_bam.log"
    threads: 5,
    params: tmpd= GLOBAL_TMPD_PATH,
    conda:  "../wrappers/dedup_bam/env.yaml"
    script: "../wrappers/dedup_bam/script.py"


# #TODO: add stats and create table with counts so it can be merged over samples in main report
# rule check_contamination_blacklist:
#     input:  bam = "mapped/{sample}.bam",
#             lst = lambda wildcards:  expand("{ref_dir}/intervals/ChIP-seq/blacklist.v2.bed", ref_dir=reference_directory),
#     output: bam_ok = "mapped/{sample}.no_contam.bam",
#             bam_fail = "mapped/{sample}.contam.bam",
#     log:    "logs/{sample}/check_contamination_blacklist.log",
#     threads: 5
#     conda:  "../wrappers/check_contamination_blacklist/env.yaml"
#     script:  "../wrappers/check_contamination_blacklist/script.py"
    
    
def filter_bam_input(wc):
    inputs = {'bam': "mapped/{sample}.bam"}
    bed = reference_directory+"/intervals/ChIP-seq/blacklist.v2.bed"
    if os.path.isfile(bed):
        inputs['bed'] = bed
    return inputs

rule filter_bam:
    input:  unpack(filter_bam_input)
    output: bam = "mapped/{sample}.keep_dups.bam",
            bam_fail = "mapped/{sample}.failed.bam",
    log:    "logs/{sample}/filter_bam.log"
    threads:5
    params: qc_cutof = config['bam_quality_cutof'],
            tmpd = GLOBAL_TMPD_PATH,
    conda:  "../wrappers/filter_bam/env.yaml"
    script:  "../wrappers/filter_bam/script.py"
    
