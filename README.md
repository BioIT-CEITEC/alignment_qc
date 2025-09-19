# Alignment QC Workflow

This repository contains a Snakemake workflow for comprehensive quality control (QC) of sequencing alignment data, supporting both DNA and RNA-seq experiments, as well as ChIP-seq specific QC.
The workflow is modular, highly configurable, and leverages conda environments for reproducibility.

## Features
- **Modular Design:** Each step is implemented as a separate rule and wrapper, allowing easy customization.
- **Conda Environments:** Each rule uses its own environment for reproducibility.
- **BioRoot Utilities:** Integrates with external modules for sample and reference management.
- **Configurable:** All parameters (paths, organism, alignment options, etc.) are set via `workflow.config.json`.

## Workflow Overview
1. **Per-sample QC for DNA and RNA:**
   - Picard (RnaSeqMetrics Assignment, Gene Coverage)
   - Qualimap (Genomic origin of reads, Gene Coverage Profile)
   - Samtools
   - dupradar
   - featureCount - biotype analysis
   - FastQ Screen (detection of tRNA and rRNA contamination)
   - RSeQC (Read Distribution, Infer experiment)
2. **ChIP-seq specific QC:**
   - Phantom peak quality
   - deduplication
   - blacklist filtering
   - multi-sample summary statistics.
3. **Cross-sample correlation:**:
   - Optional module for SNP-based sample validation and correlation analysis.
4. **Comprehensive reporting:**
   - Generates per-sample and aggregate HTML reports using MultiQC and custom scripts.

## Directory Structure
- `Snakefile`: Main workflow file.
- `workflow.config.json`: Configuration file.
- `rules/`: Snakemake rule files for each workflow step.
- `wrappers/`: Scripts and conda environments for each step.
- `raw_fastq/`: Input directory for processed FastQ files.
- `mapped/`: Input directory for alignment BAM files.
- `qc_reports/`: Output directory for QC results and reports.
- `logs/`: Log files for each step.

## Usage
1. **Configure the workflow:**
   - Edit `workflow.config.json` to specify sample information, reference genome, and parameters.
2. **Run the workflow:**
   ```bash
   snakemake --cores <N>
   ```
   Replace `<N>` with the number of CPU cores to use.
3. **Outputs:**
   - Aligned BAM files, coverage tracks, QC reports, and summary HTML files in the respective output directories.

## Requirements
- [Snakemake >=5.18.0](https://snakemake.readthedocs.io/)
- [Conda](https://docs.conda.io/)
- Python 3

## Customization
- Modify rules or wrapper scripts to adapt to specific project needs.
- Add or remove steps by editing the `rules/` and `wrappers/` directories.

## Contact
For questions or contributions, please contact the BioIT-CEITEC team.
