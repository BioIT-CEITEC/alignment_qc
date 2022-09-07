from snakemake.utils import min_version

min_version("7.2.1")

configfile: "config.json"



module BR:
    snakefile: gitlab("bioroots/bioroots_utilities",path="bioroots_utilities.smk",branch="kube_dirs")
    config: config

use rule * from BR as other_ *

# GLOBAL_REF_PATH = "/mnt/references/"
GLOBAL_TMPD_PATH = "./tmp/"

os.makedirs(GLOBAL_TMPD_PATH, exist_ok=True)


# DNA parameteres processing
#
if not "lib_ROI" in config:
    config["lib_ROI"] = "wgs"

# RNA parameteres processing
#
if not "strandness" in config:
    config["strandness"] = "unstr"

if not "count_over" in config:
    config["count_over"] = "exon"

if not "max_mapped_reads_to_run_biobloom" in config:
    config["max_mapped_reads_to_run_biobloom"] = 100

if not "feature_count" in config:
    config["feature_count"] = False

if not "RSEM" in config:
    config["RSEM"] = False

# ChIP-seq parameters processing
#
if not "effective_genome_size" in config:
    config["effective_genome_size"] = "unk"

if not "fragment_length" in config:
    config["fragment_length"] = "unk"

if not "summary_correlation_method" in config:
    config["summary_correlation_method"] = "spearman"

if not "bam_quality_cutof" in config:
    config['bam_quality_cutof'] = 20

##### Config processing #####
#

sample_tab = BR.load_sample()
read_pair_tags = BR.set_read_pair_tags()

# ##### Reference processing #####
# #

BR.load_organism()
BR.load_release()

reference_directory = BR.reference_directory()

wildcard_constraints:
    sample="|".join(sample_tab.sample_name) + "|all_samples",
    lib_name="[^\.\/]+",
    read_pair_tag="(_R.)?",


##### Target rules #####

#BR.remote(expand("qc_reports/{sample}/qc_qualimap_RNA/{sample}/qualimapReport.html",sample=sample_tab.sample_name)),

rule all:
    input: BR.remote("qc_reports/final_alignment_report.html")
    # input:  BR.remote(expand("qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.png",sample=sample_tab.sample_name,read_pair_tag=read_pair_tags)),
    #         BR.remote(expand("qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.pdf",sample=sample_tab.sample_name,read_pair_tag=read_pair_tags)),
    #         BR.remote(expand("qc_reports/{sample}/qc_fastq_screen_RNA/{sample}{read_pair_tag}_screen.txt",sample=sample_tab.sample_name,read_pair_tag=read_pair_tags)),
    #         BR.remote(expand("qc_reports/{sample}/qc_fastq_screen_RNA/fastq_screen{read_pair_tag}.conf",sample=sample_tab.sample_name,read_pair_tag=read_pair_tags)),
    output: BR.remote("completed.txt")
    shell: "touch {output}"

##### Modules #####

include: "rules/quality_control.smk"
include: "rules/cross_sample_correlation.smk"
# include: "rules/chipseq_specific_qc.smk"
include: "rules/sample_report.smk"
