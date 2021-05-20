# REPORTING RULES
#
# all = final whole run report
#

def cross_html_input(wildcards):
    snp_list = ''.join(expand("{ref_dir}/other/snp/{ref}.snp.bed",ref_dir=reference_directory,ref = config["reference"])[0],)
    if os.path.isfile(snp_list) and os.stat(snp_list).st_size != 0:
        return expand("map_qc/cross_sample_correlation/{lib_name}.cross_sample_correlation.snps.html",lib_name = config["library_name"])
    else:
        return list()

rule merge_reports:
    input:  html = expand("sample_final_reports/{sample}.final_sample_report.html", sample = sample_tab.sample_name),
            cross_html = cross_html_input,
            ref_info = "genomic_reference_info.txt",
    output: html = "{lib_name}.final_report.html",
    log:    run = "{lib_name}.multiqc_report.log",
    shell: "touch {output}"

rule single_sample_report_DNA:
    input:  raw_fastqc = expand("raw_fastq_qc/{sample}{read_pair_tag}.fastqc.html",zip,sample = sample_tab.sample_name,read_pair_tag = read_pair_tags),
            picard = "map_qc/picard/{sample}.picard.tsv",
            samtools = "map_qc/samtools/{sample}.idxstats.tsv",
            qualimap = "map_qc/qualimap/{sample}/qualimapReport.pdf",
            # contam =  DIR + "/check_contamination/{sample}.contamination_summary.tsv",
    output: html = "sample_final_reports/{sample}.final_sample_report.html",
            whole_run_log = "sample_logs/{sample}.fastq2bam_DNA.log",
    log:    run = "sample_logs/{sample}/single_sample_report_DNA.log"
    shell: "touch {output}"


'''
rule all_primary:
    input:  expand("{lib_name}.final_report.html",lib_name = config["library_name"])

   def cross_html_input(wildcards):
    snp_list = expand("{ref_dir}/other/snp/{ref}.snp.bed",ref_dir=reference_directory,ref = config["reference"])[0],
    if os.path.isfile(snp_list) and os.stat(snp_list).st_size != 0:
        return "map_qc/cross_sample_correlation/{lib_name}.cross_sample_correlation.snps.html"
    else:
        return list()

rule merge_reports:
    input:  html = expand("sample_final_reports/{sample}.final_sample_report.html", sample = sample_tab.sample_name),
            cross_html = cross_html_input,
            ref_info = "genomic_reference_info.txt",
    output: html = "{lib_name}.final_report.html",
    log:    run = "{lib_name}.multiqc_report.log",
    params: multiqc_html = "{lib_name}.multiqc_report.html",
            prefix = "./",
            lib_name = config["library_name"],
            multiqc_config = workflow.basedir + "/../scripts/multiqc_config.txt"
    conda:  "../wrappers/merge_reports/env.yaml"
    script: "../wrappers/merge_reports/script.py"

rule single_sample_report_DNA:
    input:  raw_fastqc = expand("raw_fastq_qc/{sample}{read_pair_tag}.fastqc.html",zip,read_pair_tag = read_pair_tags),
            picard = "map_qc/picard/{sample}.picard.tsv",
            samtools = "map_qc/samtools/{sample}.idxstats.tsv",
            qualimap = "map_qc/qualimap/{sample}/qualimapReport.pdf",
            # contam =  DIR + "/check_contamination/{sample}.contamination_summary.tsv",
    output: html = "sample_final_reports/{sample}.final_sample_report.html",
            whole_run_log = "sample_logs/{sample}.fastq2bam_DNA.log",
    log:    run = "sample_logs/{sample}/single_sample_report_DNA.log"
    params: multiqc_html = "sample_final_reports/{sample}.multiqc_report.html",
            lib_name = config["library_name"],
            multiqc_config = "../scripts/multiqc_config.txt"
    conda:  "../wrappers/single_sample_report_DNA/env.yaml"
    script: "../wrappers/single_sample_report_DNA/script.py"
    
'''