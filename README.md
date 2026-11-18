# DeepSeek Inference Economics

An independent R Shiny research case study by Biyue Yan.

**Research question:** At what scale could DeepSeek's commercial inference become a meaningful funding source for its research-first strategy?

The project connects AI infrastructure benchmark performance to commercial pricing and hypothetical contribution scale. It preserves the original Excel model's 16 September 2026 snapshot rather than substituting generic GPU economics.

Dashboard: https://peppermint.shinyapps.io/deepseek-inference-economics/

## What to explore

Five sections cover research overview, model unit economics, interactive scenarios, contribution scale, and sources/methods. Change billable input-cache reuse, peak traffic share, total-token model mix, and GPU-hour rates. Reset restores the workbook baseline. Download exports the current model results and scenario assumptions.

## Baseline findings

All financial values below are USD per **one million total input + output tokens**.

| Model | API revenue | Owned-like GPU cost | Retail GPU cost | Owned-like contribution | Retail contribution |
|---|---:|---:|---:|---:|---:|
| V4.1 Flash | 0.096603 | 0.005219 | 0.011163 | 0.091384 | 0.085441 |
| V4 Pro 0813 | 0.425587 | 0.009345 | 0.019986 | 0.416242 | 0.405601 |

Baseline assumptions are 50% billable cache reuse for both models, 35/168 peak traffic share, 50/50 total-token model mix, and $1.73/$3.70 owned-like/retail GPU-hour rates. Portfolio contribution is $0.253813/$0.245521 per million total tokens. A hypothetical $500 million annual contribution target requires **1.970/2.036 quadrillion total tokens/year**. These figures do not estimate actual company demand or profitability.

## Methods and sources

Price inputs come from the workbook snapshot of [DeepSeek Models & Pricing](https://api-docs.deepseek.com/quick_start/pricing/). [SemiAnalysis InferenceX](https://inferencex.semianalysis.com/) provides the benchmark provenance recorded in the workbook. Result 442167 is Flash on 4 B200 GPUs with vLLM FP4, concurrency 64, no KV offload. Result 442268 is Pro on 8 B200 GPUs with SGLang FP4, concurrency 160, DRAM/HiCache. Achieved mean interactivity is 87.26/54.82 tokens/s/user.

The official pricing page was checked on 18 November 2026. Rates agree with the workbook, while the live Flash version has moved to V4.1-Flash-1017. The app keeps the historical benchmark snapshot. Direct live benchmark API verification was unavailable in this environment, so configuration provenance is verified against the workbook, not asserted as independently re-downloaded.

Revenue weights cache-hit/miss and peak/off-peak prices by scenario assumptions, then input/output shares from full-run token arrays. GPU cost is `USD/GPU-hour × physical GPUs × 1e6 / (deployment tokens/second × 3600)`. Portfolio results weight each model by total-token share. Required annual tokens are `target / positive contribution per million × 1e6`. See [audit](docs/AUDIT.md), [data dictionary](docs/DATA.md), and [validation](docs/VALIDATION.md).

## Limitations

Technical cache telemetry is not billable API reuse. Full-run arrays and cache telemetry include warmup, whereas cost uses measured-window throughput. Engine, concurrency, offload and achieved interactivity differ between the runs. Production utilization, actual demand, commercial model mix and total R&D cost are unknown. Serving contribution covers only the selected GPU-hour budget and excludes costs outside it. A positive contribution target is not company break-even. The 35/168 uniform-time scenario does not adjust for public holidays.

Only minimum aggregate inputs, derived results and source references are published. Raw third-party traces and the original workbook are excluded pending clarification of data redistribution rights. The InferenceX-app source-code license does not by itself establish a license for all API datasets. No third-party source code is copied. This is not an official DeepSeek, NVIDIA, SemiAnalysis or Huawei project.

## Run locally

Use R 4.5 or later from the project directory:

```r
source('scripts/install.R')
shiny::runApp('.')
```

`dependencies.csv` records exact tested package versions, including transitive runtime dependencies, as a dependency specification. The install script installs current CRAN releases; inspect the version inventory when reproducing this environment. It is not a renv lockfile or a guarantee of future CRAN availability.

```sh
Rscript tests/run_tests.R
Rscript tests/test_server.R
```

Re-extract from your own local workbook with Python 3 and openpyxl:

```sh
python scripts/extract.py /path/to/Deepseek_CaseStudy.xlsx
```

Runtime uses two small CSV files; interactive changes never open or recalculate Excel. GitHub Actions runs the calculation tests on pushes and pull requests.

## Deployment

See [deployment instructions](docs/DEPLOYMENT.md). No keys or deployment credentials belong in this repository.

## Screenshots

Screenshots are provided in `docs/` when browser verification succeeds. Read validation notes for the exact scope of performed checks.

## Authorship

The original research question, public-data collection, Excel model and analysis were developed independently by Biyue Yan. The Shiny implementation and reproducibility tooling were prepared with AI assistance. No affiliation or corporate endorsement is implied. Source code is available for review; no blanket license is granted over third-party data.
