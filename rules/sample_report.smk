# REPORTING RULES
#
# all = final whole run report


def cross_html_input(wildcards):
    snp_list = expand("{ref_dir}/other/snp/{ref}.snp.bed",ref_dir=reference_directory,ref = config["reference"])[0]
    if os.path.isfile(snp_list) and os.stat(snp_list).st_size != 0:
        return "map_qc/cross_sample_correlation/" + wildcards.lib_name + ".cross_sample_correlation.snps.html"
    else:
        return list()

rule merge_reports:
    input:  html = expand("sample_final_reports/{sample}.final_sample_report.html", sample = sample_tab.sample_name),
            cross_html = cross_html_input,
            #ref_info = expand("{ref_dir}/info.txt",ref_dir=reference_directory)[0]
    output: html = "{lib_name}.final_report.html",
    log:    run = "{lib_name}.multiqc_report.log",
    params: multiqc_html = "{lib_name}.multiqc_report.html",
            lib_name = config["library_name"]
    conda: "../wrappers/merge_reports/env.yaml"
    script: "../wrappers/merge_reports/script.py"

def single_sample_report_DNA_input(wildcards):
    input = {
        'raw_fastqc': expand("raw_fastq_qc/{sample}{read_pair_tag}_fastqc.html",zip,sample = sample_tab.sample_name,read_pair_tag = read_pair_tags)[0]}
    if config["qc_picard_DNA"] == "true":
        input['picard'] = "map_qc/picard/{sample}.picard.tsv",
    if config["qc_qualimap_DNA"] == "true":
        input['qualimap'] = "map_qc/qualimap/{sample}/qualimapReport.pdf",
    if config["qc_samtools_DNA"] == "true":
        input['samtools'] = "map_qc/samtools/{sample}.idxstats.tsv",
    return input


rule single_sample_report_DNA:
    input: unpack(single_sample_report_DNA_input)
    output: html = "sample_final_reports/{sample}.final_sample_report.html",
            whole_run_log = "sample_logs/{sample}.fastq2bam_DNA.log",
    log:    run = "sample_logs/{sample}/single_sample_report_DNA.log"
    params: multiqc_html = "sample_final_reports/{sample}.multiqc_report.html",
            lib_name = config["library_name"]
    conda: "../wrappers/single_sample_report_DNA/env.yaml"
    script: "../wrappers/single_sample_report_DNA/script.py"
