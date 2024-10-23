from snakemake.utils import min_version

min_version("5.18.0")

configfile: "config.json"

GLOBAL_REF_PATH = config["globalResources"]
GLOBAL_TMPD_PATH = config["globalTmpdPath"]

os.makedirs(GLOBAL_TMPD_PATH, exist_ok=True)

##### BioRoot utilities #####
module BR:
    snakefile: github("BioIT-CEITEC/bioroots_utilities", path="bioroots_utilities.smk",branch="master")
    config: config

use rule * from BR as other_*

##### Config processing #####

sample_tab = BR.load_sample()

pair_tag = BR.set_read_pair_tags() # [""] / ["_R1", "_R2"]
pair_dmtex_tag = BR.set_read_pair_dmtex_tags() # ["_R1"] / ["_R1", "_R2"]
paired = BR.set_paired_tags() # "SE" / "PE"

# TODO: fix cross_sample_correlation - now turn off
config["cross_sample_correlation"] = False

# DNA parameter processing
#
if not "lib_ROI" in config:
    config["lib_ROI"] = "wgs"

config = BR.load_organism()

# RNA parameteres processing
#
if not "strandness" in config:
    config["strandness"] = "unstr"

if not "count_over" in config:
    config["count_over"] = "exon"

if not "max_mapped_reads_to_run_biobloom" in config:
    config["max_mapped_reads_to_run_biobloom"] = 100

if not "featureCount" in config:
    config["featureCount"] = False

if not "HTSeqCount" in config:
    config["HTSeqCount"] = False

if not "RSEM" in config:
    config["RSEM"] = False

if not "kallisto" in config:
    config["kallisto"] = False

if not "salmon_align" in config:
    config["salmon_align"] = False

if not "salmon_map" in config:
    config["salmon_map"] = False

## featureCount count_over option
if not "count_over" in config:
    config["count_over"] = "exon"

count_over_list = config['count_over'].split(",")

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

wildcard_constraints:
     sample = "|".join(sample_tab.sample_name) + "|all_samples",
     lib_name="[^\.\/]+",
     read_pair_tag = "(_R.)?",
     read_pair_dmtex_tag = "(_R.)?",
     count_over_list = "exon|gene|transcript|three_prime_UTR|five_prime_UTR"

##### Target rules #####

rule all:
    input:  "qc_reports/final_alignment_report.html"

##### Modules #####

include: "rules/quality_control.smk"
include: "rules/cross_sample_correlation.smk"
include: "rules/chipseq_specific_qc.smk"
include: "rules/sample_report.smk"

##### BioRoot utilities - prepare reference #####
module PR:
    snakefile: github("BioIT-CEITEC/bioroots_utilities", path="prepare_reference.smk",branch="master")
    config: config

use rule * from PR as other_*
