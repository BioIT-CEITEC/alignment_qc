# AFTER MAPPING QUALITY CONTROL
#
# CHIP-SEQ SPECIFIC CONTROLS
#

#TODO: add multiqc config file, generating table with phantompeakqual statistics
rule phantom_peak_qual:
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


def inspect_bam_coverage_inputs(wcs):
    inputs = {'bam': "mapped/{sample}.{dups}.bam"}
    # DEMON: This is a hack to force the workflow create mapped/{sample}.no_dups.spike.bam and mapped/{sample}.keep_dups.spike.bam files 
    # because there isn't config parameter spikein from alignment_chip workflow. These files are not needed in this workflow.
    if os.path.isfile(f"mapped/{wcs.sample}.spike.bam"):
      inputs['sbam'] = "mapped/{sample}.{dups}.spike.bam"
    return inputs

rule inspect_bam_coverage:
    # input:  bam = "mapped/{sample}.{dups}.bam",
    input:  unpack(inspect_bam_coverage_inputs),
    output: bw =  "mapped/{sample}.{dups}.bam.bigWig",
    log:    "logs/{sample}/inspect_bam_coverage.{dups}.log",
    threads: 5
    params: tmpd = GLOBAL_TMPD_PATH,
    conda:  "../wrappers/inspect_bam_coverage/env.yaml"
    script:  "../wrappers/inspect_bam_coverage/script.py"


rule multi_bam_summary:
    input:  bam = expand("mapped/{sample}.{{dups}}.bam", sample=sample_tab.sample_name),
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
    input:  bam = "mapped/{sample}.{dups}.bam"
    output: idxstats = "qc_reports/{sample}/qc_samtools/{sample}.{dups}.idxstats.tsv",
            flagstats = "qc_reports/{sample}/qc_samtools/{sample}.{dups}.flagstat.tsv",
            stats = "qc_reports/{sample}/qc_samtools/{sample}.{dups}.stats.txt",
    log:    "logs/{sample}/qc_samtools_extra.{dups}.log",
    threads:    1
    conda: "../wrappers/qc_samtools/env.yaml"
    script: "../wrappers/qc_samtools/script.py"


rule dedup_bam:
    input:  bam = "mapped/{sample}.keep_dups{extra}.bam"
    output: bam = "mapped/{sample}.no_dups{extra}.bam",
    log:    "logs/{sample}/dedup_bam{extra}.log"
    threads: 5,
    params: tmpd= GLOBAL_TMPD_PATH,
    conda:  "../wrappers/dedup_bam/env.yaml"
    script: "../wrappers/dedup_bam/script.py"
    
    
def filter_bam_input(wc):
    inputs = {'bam': "mapped/{sample}{extra}.bam"}
    bed = config["reference_dir"] + "/others/ChIP-seq/blacklist.v2.bed"
    if config['bam_remove_blacklisted'] and os.path.isfile(bed):
        inputs['bed'] = bed
        print("## INFO: Using ChIP-seq blacklist: "+bed)
    else:
        print("## INFO: Not using ChIP-seq blacklist!")
    return inputs

rule filter_bam:
    input:  unpack(filter_bam_input)
    output: bam = "mapped/{sample}.keep_dups{extra}.bam",
            bam_fail = "mapped/{sample}{extra}.filt_out.bam",
    log:    "logs/{sample}/filter_bam{extra}.log"
    threads:5
    params: prefix = "qc_reports/{sample}/qc_samtools/{sample}{extra}",
            tmpd = GLOBAL_TMPD_PATH,
    conda:  "../wrappers/filter_bam/env.yaml"
    script:  "../wrappers/filter_bam/script.py"
    
