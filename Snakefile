import os
from snakemake.utils import min_version

min_version("7.2.1")

configfile: "config.json"

module BR:
    snakefile: gitlab("bioroots/bioroots_utilities", path="bioroots_utilities.smk",branch="main")
    config: config

use rule * from BR as other_*

##### Config processing #####
#
GLOBAL_REF_PATH = config["globalResources"]
sample_tab = BR.load_sample()
read_pair_tags = BR.set_read_pair_tags()[0]
paired = BR.set_read_pair_tags()[1] # nahradit if not "is_paired in config:


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


##### Reference processing #####
#
BR.load_ref()
BR.load_organism()
reference_directory = BR.reference_directory()


wildcard_constraints:
     sample = "|".join(sample_tab.sample_name) + "|all_samples",
     lib_name="[^\.\/]+",
     read_pair_tag = "(_R.)?"

##### Target rules #####

rule all:
    input:  BR.remote("qc_reports/final_alignment_report.html")

##### Modules #####

include: "rules/quality_control.smk"
include: "rules/cross_sample_correlation.smk"
include: "rules/chipseq_specific_qc.smk"
include: "rules/sample_report.smk"
