# AFTER MAPPING QUALITY CONTROL
#
# PER SAMPLE DNA
#
def qc_picard_DNA_input(wildcards):
    input = {}
    input["bam"] = "mapped/{sample}.bam"
    input["ref"] = expand("{ref_dir}/seq/{ref}.fa",ref_dir=reference_directory,ref=config["reference"])[0]
    if "lib_ROI" in config and config["lib_ROI"] != "wgs":
        input['lib_ROI'] = expand("{ref_dir}/intervals/{lib_ROI}/{lib_ROI}.interval_list",ref_dir=reference_directory,lib_ROI=config["lib_ROI"])[0]
    return input

rule qc_picard_DNA:
    input:  unpack(qc_picard_DNA_input)
    output: table = "qc_reports/{sample}/qc_picard_DNA/picard.tsv",
    log:    "logs/{sample}/qc_picard_DNA.log"
    params: per_target = "qc_reports/{sample}/qc_picard_DNA/picard.per_target.tsv",
            wgs_chart = "qc_reports/{sample}/qc_picard_DNA/picard.wgs_chart.pdf",
            lib_ROI = config["lib_ROI"]
    threads: 1
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
    params: lib_ROI = config["lib_ROI"]
    threads: 4
    resources:  mem = 16
    conda: "../wrappers/qc_qualimap_DNA/env.yaml"
    script: "../wrappers/qc_qualimap_DNA/script.py"

rule qc_samtools:
    input:  bam = "mapped/{sample}.bam"
    output: idxstats = "qc_reports/{sample}/qc_samtools/{sample}.idxstats.tsv",
            flagstats = "qc_reports/{sample}/qc_samtools/{sample}.flagstat.tsv"
    log:    "logs/{sample}/qc_samtools.log"
    threads: 1
    conda: "../wrappers/qc_samtools/env.yaml"
    script: "../wrappers/qc_samtools/script.py"


# PER SAMPLE RNA
#
#

rule qc_qualimap_RNA:
    input:  bam = "mapped/{sample}.bam",
            bai = "mapped/{sample}.bam.bai",
            gtf = expand("{ref_dir}/annot/{ref}.gtf",ref_dir=reference_directory,ref=config["reference"])[0],
    output: html = "qc_reports/{sample}/qc_qualimap_RNA/{sample}/qualimapReport.html"
    log:    "logs/{sample}/qc_qualimap_RNA.log"
    params: paired = paired,
            strandness = config["strandness"],
            tmpd = GLOBAL_TMPD_PATH,
    threads: 10
    resources:  mem = 24
    conda:  "../wrappers/qc_qualimap_RNA/env.yaml"
    script: "../wrappers/qc_qualimap_RNA/script.py"

rule qc_dupradar_RNA:
    input:  bam = "mapped/{sample}.bam",
            gtf = expand("{ref_dir}/annot/{ref}.gtf",ref_dir=reference_directory,ref=config["reference"])[0],
    output: dupraxpbox = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_duprateExpBoxplot.pdf",
            exphist = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_expressionHist.pdf",
            dupraexpden = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_duprateExpDens.pdf",
            multipergene = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_multimapPerGene.pdf",
            readdist = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_readDist.pdf",
            txt = "qc_reports/{sample}/qc_dupradar_RNA/{sample}_duprateExpDensCurve.txt"
    log:    "logs/{sample}/qc_dupradar_RNA.log"
    threads: 10
    params: paired = paired,
            strandness = config["strandness"],
            dupraxpbox_pdf = "qc_reports/all_samples/qc_dupradar_RNA/dupraxpbox.pdf",
            exphist_pdf = "qc_reports/all_samples/qc_dupradar_RNA/exphist.pdf",
            dupraexpden_pdf = "qc_reports/all_samples/qc_dupradar_RNA/dupraexpden.pdf",
            multipergene_pdf = "qc_reports/all_samples/qc_dupradar_RNA/multipergene.pdf",
            readdist_pdf = "qc_reports/all_samples/qc_dupradar_RNA/readdist.pdf",
            tmpd = GLOBAL_TMPD_PATH,
    conda:  "../wrappers/qc_dupradar_RNA/env.yaml"
    script: "../wrappers/qc_dupradar_RNA/script.py"

rule qc_biotypes_RNA:
    input:  bam = "mapped/{sample}.bam",
            gtf = expand("{ref_dir}/annot/{ref}.gtf",ref_dir=reference_directory,ref=config["reference"])[0],
    output: txt = "qc_reports/{sample}/qc_biotypes_RNA/{sample}.biotype_counts.txt",
            pdf = "qc_reports/{sample}/qc_biotypes_RNA/{sample}.biotype_counts.pdf",
    log:    "logs/{sample}/qc_biotypes_RNA.log"
    threads: 10
    params: prefix="qc_reports/{sample}/qc_biotypes_RNA/{sample}.biotype",
            paired = paired,
            strandness=config["strandness"],
            count_over=config["count_over"],
            tmpd = GLOBAL_TMPD_PATH,
    conda: "../wrappers/qc_biotypes_RNA/env.yaml"
    script: "../wrappers/qc_biotypes_RNA/script.py"

rule qc_fastq_screen_RNA:
    input:  fastq = "raw_fastq/{sample}{read_pair_tag}.fastq.gz",
            conf = expand("{ref_dir}/other/BOWTIE2/fastq_screen_RNA_indexes/fastq_screen.conf",ref_dir=reference_directory)[0],
    output: fastqscreen = "qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.png",
            fastqscreen_pdf = "qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.pdf",
            tmp_image = "qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.txt"
    log:    "logs/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}.log"
    threads: 10
    resources: mem = 10
    params: prefix = "qc_reports/{sample}/qc_fastq_screen_RNA/fastq_screen.conf",
            organism = config["organism"],
            general_index= expand("{ref_dir}/other/BOWTIE2/fastq_screen_RNA_indexes/{ref}.ncbi.fna",ref_dir=reference_directory,ref=config["reference"])[0],
            rRNA_index= expand("{ref_dir}/other/BOWTIE2/fastq_screen_RNA_indexes/{ref}.ncbi.rRNA.fasta",ref_dir=reference_directory,ref=config["reference"])[0],
            tRNA_index= expand("{ref_dir}/other/BOWTIE2/fastq_screen_RNA_indexes/{ref}.ncbi.tRNA.fasta",ref_dir=reference_directory,ref=config["reference"])[0]
    conda:  "../wrappers/qc_fastq_screen_RNA/env.yaml"
    script: "../wrappers/qc_fastq_screen_RNA/script.py"

rule qc_RSeQC_RNA:
    input:  bam = "mapped/{sample}.bam",
            bed = expand("{ref_dir}/other/Picard_data/{ref}.bed12",ref_dir=reference_directory,ref=config["reference"])[0],
    output: read_distribution = "qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC.read_distribution.txt",
            infer_experiment = "qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC.infer_experiment.txt",
            inner_distance = "qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC.inner_distance.txt"
    log:    "logs/{sample}/qc_RSeQC_RNA.log"
    params: prefix = "qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC",
            paired = paired,
    threads: 10
    resources: mem=10
    conda: "../wrappers/qc_RSeQC_RNA/env.yaml"
    script: "../wrappers/qc_RSeQC_RNA/script.py"

rule qc_picard_RNA:
    input:  bam = "mapped/{sample}.bam",
            flat = expand("{ref_dir}/other/Picard_data/{ref}.refFlat",ref_dir=reference_directory,ref=config["reference"])[0],
    output: picard_out = "qc_reports/{sample}/qc_picard_RNA/{sample}.RNA.picard.txt",
            picard_out_pdf = "qc_reports/{sample}/qc_picard_RNA/{sample}.npc.pdf",
    log:    "logs/{sample}/qc_picard_RNA.log"
    params: strandness = config["strandness"],
    threads: 8
    resources: mem=10
    conda: "../wrappers/qc_picard_RNA/env.yaml"
    script: "../wrappers/qc_picard_RNA/script.py"
