# SIH26037 VDB benchmark

From the repository root on MATLAB R2026b:

```powershell
matlab -batch "runAllTests"
```

This runs the focused benchmark definitions, an unscored VDB smoke, and all 60 synthetic camera/radar/LiDAR cases in one MATLAB process. It writes one MAT log immediately after each case, then the CSVs, report, and 2400 × 1600 image under `tests/benchmark/results/`. A performance-gate failure is reported as `FAIL` and does not abort the suite. Missing/unverifiable measurements are `INVALID`; the final MATLAB command then exits nonzero.

**Recorded campaign:** 60/60 cases executed and valid, 58/60 reached the goal, two timed out, and zero collision episodes were scored. All 60 cases have `status=FAIL` because none met every user-proposed strict gate. This status is a performance-gate result, not an execution result. In particular, the predicted TTC and physical jerk gates were missed by all 60 cases. The [benchmark report](results/BENCHMARK_REPORT.md) separates these outcomes and links the preserved CSV and logs. The gates are not official SIH acceptance criteria.

The existing campaign's results are intentionally protected. To verify those logs without running the plant again:

```powershell
matlab -batch "runAllTests('resume')"
```

Resume accepts only MAT logs matching the frozen case manifest, code fingerprint, MATLAB release, and threshold version, and recomputes each score from its saved VDB traces. A default fresh run refuses to overwrite existing per-run logs. To conduct an independent new campaign, archive the current `results/` files first, then invoke the default command; retain the archived evidence and do not combine rows across campaigns.

The [original campaign CLI log](results/campaign_cli_original.log) is preserved separately from the [later resume log](results/benchmark_cli.log). The CSVs and per-case MAT files preserve the measured values; do not edit their recorded status or thresholds to change the presentation of the results.
