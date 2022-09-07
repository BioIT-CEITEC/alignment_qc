# AFTER MAPPING QUALITY CONTROL
#
# PER SAMPLE DNA
#

rule qc_picard_DNA_per_target:
    input:  bam = BR.remote("mapped/{sample}.bam"),
            ref = BR.remote(expand("{ref_dir}/seq/{ref}.fa",ref_dir=reference_directory,ref=config["reference"])),
            lib_ROI = BR.remote(expand("{ref_dir}/DNA_panel/{lib_ROI}/{lib_ROI}.interval_list",ref_dir=reference_directory,lib_ROI=config["lib_ROI"]))
    output: table = BR.remote("qc_reports/{sample}/qc_picard_DNA/picard_table.per_target.tsv"),
            metrics = BR.remote("qc_reports/{sample}/qc_picard_DNA/picard.per_target.tsv"),
    log:    BR.remote("logs/{sample}/qc_picard_DNA.log")
    params: lib_ROI = config["lib_ROI"],
    threads: 1
    resources:  mem = 20
    conda: "../wrappers/qc_picard_DNA_per_target/env.yaml"
    script: "../wrappers/qc_picard_DNA_per_target/script.py"


rule qc_picard_DNA_wgs_chart:
    input:  bam = BR.remote("mapped/{sample}.bam"),
            ref = BR.remote(expand("{ref_dir}/seq/{ref}.fa",ref_dir=reference_directory,ref=config["reference"])),
    output: table = BR.remote("qc_reports/{sample}/qc_picard_DNA/picard_table.wgs_chart.tsv"),
            metrics = BR.remote("qc_reports/{sample}/qc_picard_DNA/picard.wgs_chart.pdf"),
    log:    BR.remote("logs/{sample}/qc_picard_DNA.log")
    params: lib_ROI = config["lib_ROI"],
    threads: 1
    resources:  mem = 20
    conda: "../wrappers/qc_picard_DNA_wgs_chart/env.yaml"
    script: "../wrappers/qc_picard_DNA_wgs_chart/script.py"


def qc_qualimap_DNA_input(wildcards):
    input = {}
    input["bam"] = BR.remote("mapped/{sample}.bam")
    if "lib_ROI" in config and config["lib_ROI"] != "wgs":
        input['lib_ROI'] = BR.remote(expand("{ref_dir}/DNA_panel/{lib_ROI}/{lib_ROI}.bed",ref_dir=reference_directory,lib_ROI=config["lib_ROI"]))
    return input

rule qc_qualimap_DNA:
    input:  unpack(qc_qualimap_DNA_input)
    output: html = BR.remote("qc_reports/{sample}/qc_qualimap_DNA/{sample}/qualimapReport.html")
    log:    BR.remote("logs/{sample}/qc_qualimap_DNA.log")
    params: lib_ROI = config["lib_ROI"]
    threads: 4
    resources:  mem = 16
    conda: "../wrappers/qc_qualimap_DNA/env.yaml"
    script: "../wrappers/qc_qualimap_DNA/script.py"

rule qc_samtools:
    input:  bam = BR.remote("mapped/{sample}.bam")
    output: idxstats = BR.remote("qc_reports/{sample}/qc_samtools/{sample}.idxstats.tsv"),
            flagstats = BR.remote("qc_reports/{sample}/qc_samtools/{sample}.flagstat.tsv")
    log:    BR.remote("logs/{sample}/qc_samtools.log")
    threads: 1
    conda: "../wrappers/qc_samtools/env.yaml"
    script: "../wrappers/qc_samtools/script.py"


# PER SAMPLE RNA
#
#

# rule qc_qualimap_RNA:
#     input:  bam = BR.remote("mapped/{sample}.bam"),
#             # bai = BR.remote("mapped/{sample}.bam.bai"),
#             gtf = BR.remote(expand("{ref_dir}/annot/{rel}/{ref}.gtf",ref_dir=reference_directory,rel = config["release"],ref=config["reference"])),
#     output: html = BR.remote("qc_reports/{sample}/qc_qualimap_RNA/{sample}/qualimapReport.html")
#     log:    BR.remote("logs/{sample}/qc_qualimap_RNA.log")
#     params: paired = config["is_paired"],
#             strandness = config["strandness"],
#             tmpd = GLOBAL_TMPD_PATH,
#     threads: 10
#     resources:  mem = 24
#     conda:  "../wrappers/qc_qualimap_RNA/env.yaml"
#     script: "../wrappers/qc_qualimap_RNA/script.py"
#
#
# rule qc_picard_RNA:
#     input:  bam = BR.remote("mapped/{sample}.bam"),
#             flat = BR.remote(expand("{ref_dir}/tool_data/Picard/{ref}.refFlat",ref_dir=reference_directory,ref=config["reference"])),
#     output: picard_out = BR.remote("qc_reports/{sample}/qc_picard_RNA/{sample}.RNA.picard.txt"),
#             picard_out_pdf = BR.remote("qc_reports/{sample}/qc_picard_RNA/{sample}.npc.pdf"),
#     log:    BR.remote("logs/{sample}/qc_picard_RNA.log")
#     params: strandness = config["strandness"],
#     threads: 8
#     resources: mem=10
#     conda: "../wrappers/qc_picard_RNA/env.yaml"
#     script: "../wrappers/qc_picard_RNA/script.py"
#
#
# rule qc_dupradar_RNA:
#     input:  bam = BR.remote("mapped/{sample}.bam"),
#             gtf = BR.remote(expand("{ref_dir}/annot/{rel}/{ref}.gtf",ref_dir=reference_directory,rel = config["release"],ref=config["reference"])),
#     output: dupraxpbox = BR.remote("qc_reports/{sample}/qc_dupradar_RNA/{sample}_duprateExpBoxplot.pdf"),
#             exphist = BR.remote("qc_reports/{sample}/qc_dupradar_RNA/{sample}_expressionHist.pdf"),
#             dupraexpden = BR.remote("qc_reports/{sample}/qc_dupradar_RNA/{sample}_duprateExpDens.pdf"),
#             multipergene = BR.remote("qc_reports/{sample}/qc_dupradar_RNA/{sample}_multimapPerGene.pdf"),
#             readdist = BR.remote("qc_reports/{sample}/qc_dupradar_RNA/{sample}_readDist.pdf"),
#             txt = BR.remote("qc_reports/{sample}/qc_dupradar_RNA/{sample}_duprateExpDensCurve.txt")
#     log:    BR.remote("logs/{sample}/qc_dupradar_RNA.log")
#     threads: 10
#     params: paired = config["is_paired"],
#             strandness = config["strandness"],
#     conda:  "../wrappers/qc_dupradar_RNA/env.yaml"
#     script: "../wrappers/qc_dupradar_RNA/script.py"
#
#
# rule qc_biotypes_RNA:
#     input:  bam = BR.remote("mapped/{sample}.bam"),
#             gtf = BR.remote(expand("{ref_dir}/annot/{rel}/{ref}.gtf",ref_dir=reference_directory,rel = config["release"],ref=config["reference"])),
#     output: txt = BR.remote("qc_reports/{sample}/qc_biotypes_RNA/{sample}.biotype_counts.txt"),
#             pdf = BR.remote("qc_reports/{sample}/qc_biotypes_RNA/{sample}.biotype_counts.pdf"),
#     log:    BR.remote("logs/{sample}/qc_biotypes_RNA.log")
#     threads: 10
#     params: paired = config["is_paired"],
#             strandness=config["strandness"],
#             count_over=config["count_over"],
#     conda: "../wrappers/qc_biotypes_RNA/env.yaml"
#     script: "../wrappers/qc_biotypes_RNA/script.py"


# rule qc_fastq_screen_RNA_new:
#     input:  fastq = "raw_fastq/{sample}{read_pair_tag}.fastq.gz",
#     output: fastqscreen = "qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.png",
#             fastqscreen_pdf = "qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.pdf",
#             tmp_image = "qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.txt"
#     log:    "logs/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}.log"
#     threads: 10
#     resources: mem = 10
#     params: prefix = "qc_reports/{sample}/qc_fastq_screen_RNA/fastq_screen.conf",
#             organism = config["organism"],
#             general_index= expand("{ref_dir}/other/BOWTIE2/fastq_screen_RNA_indexes/{ref}.ncbi.fna",ref_dir=reference_directory,ref=config["reference"])[0],
#             rRNA_index= expand("{ref_dir}/other/BOWTIE2/fastq_screen_RNA_indexes/{ref}.ncbi.rRNA.fasta",ref_dir=reference_directory,ref=config["reference"])[0],
#             tRNA_index= expand("{ref_dir}/other/BOWTIE2/fastq_screen_RNA_indexes/{ref}.ncbi.tRNA.fasta",ref_dir=reference_directory,ref=config["reference"])[0]
#     conda:  "../wrappers/qc_fastq_screen_RNA/env.yaml"
#     script: "../wrappers/qc_fastq_screen_RNA/script.py"


#
# rule qc_fastq_screen_RNA:
#     input:  fastq=BR.remote("raw_fastq/{sample}{read_pair_tag}.fastq.gz"),
#             general_index=BR.remote(expand("{ref_dir}/tool_data/BOWTIE2/fastq_screen_RNA_indexes/{ref}.ncbi.fna.{end}",ref_dir=reference_directory,ref=config["reference"],end = ["1.bt2","2.bt2","3.bt2","4.bt2"])),
#             rRNA_index=BR.remote(expand("{ref_dir}/tool_data/BOWTIE2/fastq_screen_RNA_indexes/{ref}.ncbi.rRNA.fasta.{end}",ref_dir=reference_directory,ref=config["reference"],end = ["1.bt2","2.bt2","3.bt2","4.bt2"])),
#             tRNA_index=BR.remote(expand("{ref_dir}/tool_data/BOWTIE2/fastq_screen_RNA_indexes/{ref}.ncbi.tRNA.fasta.{end}",ref_dir=reference_directory,ref=config["reference"],end = ["1.bt2","2.bt2","3.bt2","4.bt2"])),
#     output: fastqscreen = BR.remote("qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.png"),
#             fastqscreen_pdf = BR.remote("qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.pdf"),
#             tmp_image = BR.remote("qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.txt"),
#             # prefix = BR.remote("qc_reports/{sample}/qc_fastq_screen_RNA/fastq_screen.conf"),
#     log:    BR.remote("logs/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}.log")
#     threads: 10
#     resources: mem = 10
#     params: organism = config["organism"],
#     conda: "../wrappers/qc_fastq_screen_RNA/env.yaml"
#     script: "../wrappers/qc_fastq_screen_RNA/script.py"



# rule qc_RSeQC_RNA:
#     input:  bam = "mapped/{sample}.bam",
#             bed = expand("{ref_dir}/other/Picard_data/{ref}.bed12",ref_dir=reference_directory,ref=config["reference"])[0],
#     output: read_distribution = "qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC.read_distribution.txt",
#             infer_experiment = "qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC.infer_experiment.txt",
#             inner_distance = "qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC.inner_distance.txt"
#     log:    "logs/{sample}/qc_RSeQC_RNA.log"
#     params: prefix = "qc_reports/{sample}/qc_RSeQC_RNA/{sample}.RSeQC",
#             paired = paired,
#     threads: 10
#     resources: mem=10
#     conda: "../wrappers/qc_RSeQC_RNA/env.yaml"
#     script: "../wrappers/qc_RSeQC_RNA/script.py"
#

