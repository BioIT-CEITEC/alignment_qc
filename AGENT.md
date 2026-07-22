# AGENT.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Snakemake workflow** for comprehensive quality control (QC) of sequencing alignment data, supporting DNA, RNA-seq, and ChIP-seq experiments. The workflow integrates with external `bioroots_utilities` and `prepare_reference` modules from the BioIT-CEITEC organization.

## Running the Workflow

```bash
# Basic execution
snakemake --cores <N>

# View available targets
snakemake --list-targets

# Dry run to check workflow
snakemake --cores 1 --dryrun
```

## Architecture

### Main Components

- **[Snakefile](Snakefile)**: Entry point that loads config, imports external modules (bioroots_utilities, prepare_reference), and includes rule files
- **[workflow.config.json](workflow.config.json)**: GUI-oriented configuration defining inputs/outputs, parameters, and conditional parameter visibility
- **[config.json](config.json)**: Runtime configuration (sample tables, organism paths, reference files) - generated or provided externally
- **[rules/](rules/)**: Snakemake rule definitions split by functionality
- **[wrappers/](wrappers/)**: Individual conda environments (`env.yaml`) and implementation scripts (Python/R) for each workflow step

### Rule Files

| File | Purpose |
|------|---------|
| [quality_control.smk](rules/quality_control.smk) | Per-sample QC for DNA (Picard, Qualimap, Samtools) and RNA (dupradar, biotypes, FastQ Screen, RSeQC, Picard) |
| [chipseq_specific_qc.smk](rules/chipseq_specific_qc.smk) | ChIP-seq controls: phantom peak quality, deduplication, blacklist filtering, multi-sample correlation |
| [cross_sample_correlation.smk](rules/cross_sample_correlation.smk) | SNP-based sample validation and correlation analysis |
| [sample_report.smk](rules/sample_report.smk) | MultiQC reports, per-sample HTML reports, final aggregated report |

### External Dependencies

The workflow imports two external Snakemake modules via GitHub:
- `BioIT-CEITEC/bioroots_utilities` (branch: master) - Sample loading, organism setup, read pair tagging
- `BioIT-CEITEC/prepare_reference` (branch: master) - Reference preparation utilities

### Key Configuration Concepts

1. **Sample Management**: Samples are loaded via `BR.load_sample()` from an external module; sample names are constrained in wildcards
2. **Organism Setup**: `BR.load_organism()` populates organism-specific paths (FASTA, GTF, BED intervals)
3. **Read Pair Tags**: `pair_tag` / `pair_dmtex_tag` handle SE vs PE reads (`[""]` vs `["_R1", "_R2"]`)
4. **Conditional Rules**: Many rules are gated by config flags (`qc_picard_DNA`, `qc_dupradar_RNA`, `chip_extra_qc`, etc.)
5. **ChIP-seq Modes**: When `chip_extra_qc=true`, BAMs are processed through filter→dedup→phantom peak→multi-sample summary

### Output Structure

```
qc_reports/
├── {sample}/
│   ├── multiqc.html
│   ├── single_sample_alignment_report.html
│   └── <tool-specific>/
├── all_samples/
│   ├── multiqc.html
│   ├── qc_biotype_RNA/biotype.pdf
│   ├── fastq_screen/fastq_screen.pdf
│   ├── qc_dupradar_RNA/*.pdf
│   ├── phantompeakqual/*.pdf
│   ├── deeptools/correlation_heatmap.*.pdf
│   └── deeptools/fingerprint.*.pdf
└── final_alignment_report.html
```

### Development Patterns

**Adding a new QC step:**
1. Create wrapper directory with `env.yaml` and `script.py`
2. Add rule to appropriate `.smk` file with proper input/output/log patterns
3. Add config flag to [workflow.config.json](workflow.config.json) if conditional
4. Update reporting rules if output should appear in final report

**Wrapper script pattern:**
```python
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)
# Log version info
# Build command using snakemake.input/output/params/threads/resources
# Execute via shell(command)
```

**Input functions**: Complex rules use `unpack()` with input factory functions for conditional file requirements (e.g., blacklist BED only exists for some references).

### Common Config Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `lib_ROI` | string | "wgs" | Library region of interest (wgs, rna, target) |
| `strandness` | string | "unstr" | RNA strandness (unstr, fr-firststrand, fr-secondstrand) |
| `bam_quality_cutof` | int | 20 | Minimum MAPQ for ChIP-seq filtering |
| `bam_remove_blacklisted` | bool | true | Remove ChIP-seq blacklist regions |
| `chip_extra_qc` | bool | false | Enable ChIP-seq specific QC steps |
| `qc_dupradar_RNA` | bool | true | Enable dupradar duplication rate analysis |
| `count_over` | string | "exon" | Feature type for counting (exon, gene, transcript) |

### Known Limitations

- Cross-sample correlation is currently disabled in Snakefile line 28 (`config["cross_sample_correlation"] = False`)
- Some rules have TODOs (e.g., MultiQC config for phantom peak stats)
- The workflow expects certain reference files to exist at paths defined in `config.json` (organism_gtf, organism_fasta, organism_ncbi_fs_conf, etc.)
