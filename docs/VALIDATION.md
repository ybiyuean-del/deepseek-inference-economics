# Validation

The independent R implementation passed 97 numeric and invalid-input checks, plus zero/negative contribution and zero-revenue checks. Tolerance is 1e-10 relative via R `all.equal` (with absolute handling near zero).

Fixtures include 14 model metrics, seven portfolio metrics, ten annual scale requirements and 40 workbook cache/peak sensitivity results. Additional checks cover cache defaults, exact 35/168 timing, model mix endpoints, workload shares, unit conversions, missing/invalid inputs and zero/negative contribution. Expected results are extracted from saved Excel cache values independently of the R economic functions.

`test_server.R` verifies reactive scenario changes and renders all dashboard outputs. It simulates the client response after reset. It does not by itself prove a real browser reset interaction. The source workbook was not recalculated in native Excel. The complete original raw-data calculation chain has not been independently recomputed; the numerical claim is equivalence to the identified cached outputs.

All 17 sheets were inspected and 105,475 formula caches scanned with no standard cached Excel errors. This scan is separate from the 97 model checks and is not a full mathematical audit.

Initial local browser navigation to loopback timed out. Server-side chart/table rendering succeeded. See the completion message and screenshots for any later online browser verification.
