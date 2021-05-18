import os
import pandas as pd
from snakemake.utils import min_version

min_version("5.18.0")

GLOBAL_REF_PATH = "/mnt/ssd/ssd_3/references"

# Folders
#
reference_directory = os.path.join(GLOBAL_REF_PATH,config["organism"],config["reference"])

##### Config processing #####

#sample_tab = pd.DataFrame.from_dict(config["samples"],orient="index")
#print(sample_tab)

#wildcard_constraints:
#     sample = "|".join(sample_tab.sample_name),
#     lib_name="[^\.\/]+"

##### Target rules #####

rule all:
    input:  expand("map_qc/cross_sample_correlation/{lib_name}.cross_sample_correlation.snps.html", lib_name = config["library_name"]),
            expand("map_qc/cross_sample_correlation/{lib_name}.cross_sample_correlation.snps.tsv", lib_name= config["library_name"]),


##### Modules #####

include: "rules/quality_control.smk"
include: "rules/cross_sample_correlation.smk"