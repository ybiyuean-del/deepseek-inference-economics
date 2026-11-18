# Workbook audit

Snapshot: 2026-09-16. File checksum and worksheet dimensions are in `workbook-manifest.json`.

All 17 worksheets were inspected. 105,475 formulas were scanned against saved cached values; no standard cached Excel errors were found. This does not prove every raw-data formula correct or constitute recalculation in native Excel.

## Data flow

1. `B200 Run Inputs` identifies Flash result 442167 and Pro result 442268, configuration, measured-window throughput and GPU rates.
2. `B200 Raw Tokens` supplies full-run input/output arrays. `B200 Cache Telemetry` supplies independent prompt and cache-source volumes.
3. `B200 Run Costs` computes serving costs using physical GPU count (4/8). For these non-disaggregated deployments, prefill and decode counts are not added together.
4. `Sheet 1 — Inputs & Sources` stores API price assumptions and token-composition links. Flash maps to `Summary!E5`; Pro maps to `Summary!B5`. Both agree with the corresponding `B200 Run Costs` cache aggregates.
5. `Unit_Economics` combines workload shares, API pricing, billable cache reuse and peak traffic.
6. `Pricing_Cache` supplies the active scenarios and sensitivity matrices; `API_Portfolio` weights by total-token share.
7. `BreakEven_Scale` divides hypothetical contribution targets by positive contribution. `Dashboard` presents the linked outputs.

## Interpretation and retained assumptions

No material economic relationships or baseline inputs were changed. Technical cache ratios remain contextual and do not set billable cache reuse. GPU-hour cost uses exact deployment throughput instead of rounded per-GPU display values. Workload composition intentionally retains full-array totals even though throughput uses the measured window.

Telemetry source buckets do not exactly equal prompt volume: Flash delta is −3,151.824 tokens; Pro delta is +3,128,909.241 tokens. The app never assumes compute-miss share equals one minus the hit ratio. These telemetry deltas do not drive API revenue.

Reported fundraising, ARR and infrastructure-spending references lack sufficiently precise original article citations in the workbook. They are omitted as factual headline claims. The workbook's $100M, $250M, $500M, $1B and $1.6B figures are retained exclusively as hypothetical annual contribution targets.

The minimum dashboard preserves all five requested sections and exposes only verified economic controls. Output-token workload is retained at the benchmark composition; no independent throughput response to changed cache reuse is invented.
