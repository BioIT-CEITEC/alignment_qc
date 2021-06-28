# AFTER MAPPING QUALITY CONTROL
#
# PER SAMPLE DNA
#
def qc_picard_DNA_input(wildcards):
    input = {}
    input["bam"] = "mapped/{sample}.bam"
    input['ref'] = expand("{ref_dir}/seq/{ref}.fa",ref_dir=reference_directory,ref=config["reference"])[0]
    if "lib_ROI" in config and config["lib_ROI"] != "wgs":
        input['lib_ROI'] = expand("{ref_dir}/intervals/{lib_ROI}/{lib_ROI}.interval_list",ref_dir=reference_directory,lib_ROI=config["lib_ROI"])[0]
    return input

rule qc_picard_DNA:
    input:  unpack(qc_picard_DNA_input)
    output: table = "qc_reports/{sample}/qc_picard_DNA/picard.tsv",
    log:    "logs/{sample}/qc_picard_DNA.log"
    params: per_target = "qc_reports/{sample}/qc_picard_DNA/picard.per_target.tsv",
            wgs_chart = "qc_reports/{sample}/qc_picard_DNA/picard.wgs_chart.pdf",
    threads:    1
    resources:  mem = 20
    conda: "../wrappers/qc_picard_DNA/env.yaml"
    script: "../wrappers/qc_picard_DNA/script.py"

def qc_qualimap_DNA_input(wildcards):
    input = {}
    input["bam"] = "mapped/{sample}.bam"
    if "lib_ROI" in config and config["lib_ROI"] != "wgs":
        input['lib_ROI'] = expand("{ref_dir}/intervals/{lib_ROI}/{lib_ROI}.bed",ref_dir=reference_directory,lib_ROI=config["lib_ROI"])[0]
    return input

rule qc_qualimap_DNA:
    input:  unpack(qc_qualimap_DNA_input)
    output: html = "qc_reports/{sample}/qc_qualimap_DNA/{sample}/qualimapReport.html"
    log:    "logs/{sample}/qc_qualimap_DNA.log"
    threads:    4
    resources:  mem = 16
    conda: "../wrappers/qc_qualimap_DNA/env.yaml"
    script: "../wrappers/qc_qualimap_DNA/script.py"


rule qc_samtools_DNA:
    input:  bam = "mapped/{sample}.bam"
    output: idxstats = "qc_reports/{sample}/qc_samtools_DNA/idxstats.tsv",
            flagstats = "qc_reports/{sample}/qc_samtools_DNA/{sample}.flagstat.tsv"
    log:    "logs/{sample}/qc_samtools_DNA.log"
    threads:    1
    conda: "../wrappers/qc_samtools_DNA/env.yaml"
    script: "../wrappers/qc_samtools_DNA/script.py"


# PER SAMPLE RNA
#
#
#do RNA configu:
    #pair = config["pair"], #PE/SE
    #strandness = config["strandness"],
    #count_over=config["count_over"] #exon/..
#
##### Nefunguje (zatím)
# rule qc_qualimap_RNA:
#     input:  bam = "mapped/{sample}.bam",
#             bai = "mapped/{sample}.bam.bai",
#             gtf = expand("{ref_dir}/annot/{ref}.gtf",ref_dir=reference_directory,ref=config["reference"])[0],
#     output: html = "qc_reports/{sample}/qc_qualimap_RNA/{sample}/qualimapReport.html"
#     log:    "logs/{sample}/qc_qualimap_RNA.log"
#     params: pair = config["pair"],
#             strandness = config["strandness"],
#     threads:    10
#     resources:  mem = 1
#     conda:  "../wrappers/qc_qualimap_RNA/env.yaml"
#     script: "../wrappers/qc_qualimap_RNA/script.py"
#
#
# rule qc_dupradar_RNA:
#     input: bam="mapped/{sample}.bam",
#             gtf=expand("{ref_dir}/annot/{ref}.gtf",ref_dir=reference_directory,ref=config["reference"])[0],
#     output: dupraxpbox = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_duprateExpBoxplot.pdf",
#             exphist = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_expressionHist.pdf",
#             dupraexpden = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_duprateExpDens.pdf",
#             multipergene = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_multimapPerGene.pdf",
#             readdist = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_readDist.pdf",
#             txt = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_duprateExpDensCurve.txt",
#     log:    "logs/{sample}/qc_dupradar_RNA.log"
#     threads:  10
#     params: pair = config["pair"],
#             strandness = config["strandness"],
#     conda:  "../wrappers/qc_dupradar_RNA/env.yaml"
#     script: "../wrappers/qc_dupradar_RNA/script.py"
#
#
# rule qc_biotypes_RNA:
#     input: bam="mapped/{sample}.bam",
#         gtf=expand("{ref_dir}/annot/{ref}.gtf",ref_dir=reference_directory,ref=config["reference"])[0],
#     output: txt="qc_reports/{sample}/qc_biotypes_RNA/{sample}.biotype_counts.txt",
#     log: "logs/{sample}/qc_biotypes_RNA.log"
#     threads: 10
#     params: prefix="qc_reports/{sample}/qc_biotypes_RNA/{sample}.biotype",
#         pair=config["pair"],
#         strandness=config["strandness"],
#         #info = expand("{ref_dir}/info.txt", ref_dir=reference_directory,ref=config["reference"])[0],#DÁVALI JSME TO U DNA???!
#         count_over=config["count_over"],  # [exon, three_prime_utr] what feature to use for the summary? For QuantSeq it might be 3 UTR ("three_prime_utr" is for Ensembl annotation
#     conda: "../wrappers/qc_biotypes_RNA/env.yaml"
#     script: "../wrappers/qc_biotypes_RNA/script.py"

###### rule pro RAW_FASTQ_QC
# rule qc_fastq_screen_RNA:
#     input:  fastq = "cleaned_fastq/{sample}{read_pair_tag}.fastq.gz",
#             fastqscreen_conf = expand("{ref_dir}/other/BOWTIE2/fastq_screen_RNA_indexes/fastq_screen.conf",ref_dir=reference_directory)[0],
#     output: fastqscreen = "qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.png",
#             tmp_image = "qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.txt"
#     log:    "logs/{sample}/qc_fastq_screen_RNA{read_pair_tag}.log"
#     threads:    10
#     resources:  mem = 10
#     conda:  "../wrappers/qc_fastq_screen_RNA/env.yaml"
#     script: "../wrappers/qc_fastq_screen_RNA/script.py"

# rule qc_RSeQC_RNA:
#     input: bam="mapped/{sample}.bam",
#         bed=expand("{ref_dir}/other/Picard_data/{ref}.bed12",ref_dir=reference_directory,ref=config["reference"])[0],
#     output: read_distribution="qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC.read_distribution.txt",
#         infer_experiment="qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC.infer_experiment.txt",
#         inner_distance="qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC.inner_distance.txt"
#     log: "logs/{sample}/qc_RSeQC_RNA.log"
#     params: prefix="qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC"
#     threads: 10
#     resources: mem=10
#     conda: "../wrappers/qc_RSeQC_RNA/env.yaml"
#     script: "../wrappers/qc_RSeQC_RNA/script.py"
#
# rule qc_picard_RNA:
#     input: bam="mapped/{sample}.bam",
#         flat=expand("{ref_dir}/other/Picard_data/{ref}.refFlat",ref_dir=reference_directory,ref=config["reference"])[0],
#     output: picard_out="qc_reports/{sample}/qc_picard_RNA/{sample}.RNA.picard.txt",
#         picard_out_pdf="qc_reports/{sample}/qc_picard_RNA/{sample}.npc.pdf",
#     log: "logs/{sample}/qc_picard_RNA.log"
#     params: strandness=config["strandness"],
#     threads: 8
#     resources: mem=10
#     conda: "../wrappers/qc_picard_RNA/env.yaml"
#     script: "../wrappers/qc_picard_RNA/script.py"
