from snakemake.utils import min_version

min_version("6.15")

module bioroots_utilities:
    snakefile:
            gitlab("bioroots/bioroots_utilities", path="bioroots_utilities.smk",branch="main")

use rule * from bioroots_utilities as other_*


GLOBAL_REF_PATH = bioroots_utilities.global_ref_path()
GLOBAL_TMPD_PATH = "/tmp/"

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

# Reference processing
#
bioroots_utilities.load_ref(global_ref_path, config)
bioroots_utilities.load_organism(global_ref_path, config)

##### Config processing #####
# Folders
#
reference_directory = bioroots_utilities.reference_directory(global_ref_path, config)

# Samples
#
sample_tab = bioroots_utilities.load_sample(config)

read_pair_tags = bioroots_utilities.set_read_pair_tags(config)[0]
paired = bioroots_utilities.set_read_pair_tags(config)[1]


wildcard_constraints:
     sample = "|".join(sample_tab.sample_name) + "|all_samples",
     lib_name="[^\.\/]+",
     read_pair_tag = "(_R.)?"

##### Target rules #####

rule all:
    input:  "qc_reports/final_alignment_report.html"

##### Modules #####

include: "rules/quality_control.smk"
include: "rules/cross_sample_correlation.smk"
include: "rules/chipseq_specific_qc.smk"
include: "rules/sample_report.smk"
