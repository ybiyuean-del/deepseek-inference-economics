# Data dictionary and reuse

`models.csv`: two selected configurations. `gpus` is physical device count. `throughput` is measured deployment total input+output tokens/second. `input_tokens` and `output_tokens` are full returned array totals. Prices ending in `hit`/`miss` are USD per million input tokens; prices ending in `output` are USD per million output tokens. `technical_cache` is full-run HBM+CPU hit volume / prompt volume and is contextual only. Engine, precision, concurrency, date and result IDs are workbook-recorded benchmark metadata.

`baseline.csv`: billable-cache shares, peak traffic share, Flash total-token share and GPU-hour rates. Fractions use 0–1; rates use USD/GPU-hour. Billable cache and commercial traffic/mix are hypothetical.

`excel_expected.csv`: independent expected cached outputs extracted from Excel with exact sheet/cell locators. Costs, revenue and contribution use USD per million total tokens; margins use 0–1. Scale entries use total tokens/year; their index is the USD/year target.

`excel_sensitivity.csv`: 40 cached revenue outputs from the workbook's cache/peak sensitivity grids. `model` is 1=Flash or 2=Pro. Cache and peak values use 0–1. Expected revenue uses USD per million total tokens.

`sources.csv`: original workbook source links and their cells. Links are references, not a claim that every live endpoint was successfully fetched.

Code/data are separated. The raw workbook and raw third-party traces are not distributed publicly. Re-extraction requires a local copy, Python and openpyxl. Check upstream terms before adding any raw traces. References: https://github.com/SemiAnalysisAI/InferenceX-app/blob/main/LICENSE and https://inferencex.semianalysis.com/ .
