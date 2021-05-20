# AFTER MAPPING QUALITY CONTROL
#
# PER SAMPLE
#


rule qc_picard_DNA:
    input:  bam = expand("mapped/{sample}.bam",sample = sample_tab.sample_name),
            ref = expand("{ref_dir}/seq/{ref}.fa",ref_dir=reference_directory, ref = config["reference"])[0],
            ilist = expand("{ref_dir}/intervals/{library_scope}/{library_scope}.interval_list",ref_dir=reference_directory,library_scope=config["library_scope"])[0],
    output: table = "map_qc/picard/{sample}.picard.tsv",
    log:    run = "sample_logs/{sample}/qc_picard_DNA.log"
    shell: "touch {output}"


rule qc_qualimap_DNA:
    input:  bam = "mapped/{sample}.bam",
            bed = expand("{ref_dir}/intervals/{library_scope}/{library_scope}.bed",ref_dir=reference_directory,library_scope=config["library_scope"])[0]
    output: pdf = "map_qc/qualimap/{sample}/qualimapReport.pdf"
    log:    run = "sample_logs/{sample}/qc_qualimap_DNA.log"
    shell: "touch {output}"


rule qc_samtools_DNA:
    input:  bam = "mapped/{sample}.bam"
    output: idxstats = "map_qc/samtools/{sample}.idxstats.tsv",
            flagstats = "map_qc/samtools/{sample}.flagstat.tsv"
    log:    run = "sample_logs/{sample}/qc_samtools_DNA.log"
    shell: "touch {output}"


'''
rule qc_picard_DNA:
    input:  bam = expand("mapped/{sample}.bam",sample = sample_tab.sample_name),
            ref = expand("{ref_dir}/seq/{ref}.fa",ref_dir=reference_directory, ref = config["reference"])[0],
            ilist = expand("{ref_dir}/intervals/{library_scope}/{library_scope}.interval_list",ref_dir=reference_directory,library_scope=config["library_scope"])[0],
    output: table = "map_qc/picard/{sample}.picard.tsv",
    params: per_target = "map_qc/picard/{sample}.picard.per_target.tsv",
            wgs_chart = "map_qc/picard/{sample}.picard.wgs_chart.pdf",
    log:    run = "sample_logs/{sample}/qc_picard_DNA.log"
    threads:    1
    resources:  mem = 20
    conda:  "../wrappers/qc_picard_DNA/env.yaml"
    script: "../wrappers/qc_picard_DNA/script.py"


rule qc_qualimap_DNA:
    input:  bam = "mapped/{sample}.bam",
            bed = expand("{ref_dir}/intervals/{library_scope}/{library_scope}.bed",ref_dir=reference_directory,library_scope=config["library_scope"])[0]
    output: pdf = "map_qc/qualimap/{sample}/qualimapReport.pdf"
    log:    run = "sample_logs/{sample}/qc_qualimap_DNA.log"
    params: prefix = "map_qc/qualimap/{sample}",
            html = "map_qc/qualimap/{sample}/qualimapReport.html"
    threads:    4
    resources:  mem = 16
    conda:  "../wrappers/qc_qualimap_DNA/env.yaml"
    script: "../wrappers/qc_qualimap_DNA/script.py"


rule qc_samtools_DNA:
    input:  bam = "mapped/{sample}.bam"
    output: idxstats = "map_qc/samtools/{sample}.idxstats.tsv",
            flagstats = "map_qc/samtools/{sample}.flagstat.tsv"
    log:    run = "sample_logs/{sample}/qc_samtools_DNA.log"
    threads: 1
    conda:  "../wrappers/qc_samtools_DNA/env.yaml"
    script: "../wrappers/qc_samtools_DNA/script.py"

'''