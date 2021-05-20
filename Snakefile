import os
import pandas as pd
from snakemake.utils import min_version

min_version("5.18.0")

GLOBAL_REF_PATH = "/mnt/ssd/ssd_3/references"

# Folders
#
reference_directory = os.path.join(GLOBAL_REF_PATH,config["organism"],config["reference"])

##### Config processing #####

sample_tab = pd.DataFrame.from_dict(config["samples"],orient="index")
print(sample_tab)

if config["lib_reverse_read_length"] == 0:
    read_pair_tags = [""]
else:
    read_pair_tags = ["_R1","_R2"]

wildcard_constraints:
     sample = "|".join(sample_tab.sample_name),
     lib_name="[^\.\/]+"

##### Target rules #####

rule all:
    input: expand("{lib_name}.final_report.html",lib_name = config["library_name"])


##### Modules #####

include: "rules/quality_control.smk"
include: "rules/cross_sample_correlation.smk"
include: "rules/sample_report.smk"