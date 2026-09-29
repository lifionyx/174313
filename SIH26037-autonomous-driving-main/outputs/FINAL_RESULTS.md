# SIH26037 final executed results

This page reports the earlier five-scenario MATLAB bicycle-model benchmark. The later [60-case VDB campaign](../tests/benchmark/results/BENCHMARK_REPORT.md) is a separate experiment: 60/60 cases executed and were valid, 58 reached the goal, two timed out, and zero collision episodes were scored. Its `FAIL` labels mean the valid cases missed user-proposed strict performance gates; they do not indicate that 60 simulations failed to run.

The later Vehicle Dynamics Blockset five-scene benchmark, 3D recordings, and Unreal camera preview are reported separately in [VDB 3D results](VDB_3D_RESULTS.md) and [verified VDB evidence](VDB_3D_EVIDENCE.md). The table below is the earlier MATLAB bicycle-model benchmark.

All values below come from the benchmark CSV and logged MAT runs.

## Validation

- MATLAB subsystem checks: 9 PASS lines, 0 failure markers in [test log](logs/test_suite.txt).
- Simulink smoke: 1 pass / 0 fail in [CLI log](logs/simulink_smoke.txt).
- Code Analyzer: parsed MATLAB source in [CLI log](logs/code_parse.txt).
- Five-scene benchmark and evidence generation: [CLI log](logs/canonical_benchmark.txt).
- Environment audit: [CLI log](logs/environment_audit.txt).
- Canonical sensor scenarios: 5/5 goals reached; 0 collisions.
- Extra seed runs: 10/10 goals reached; 0 collisions.
- Truth-mode scenarios: 5/5 goals reached; 0 collisions.

## Canonical sensor-fusion benchmark

| Scenario | Terminal status | Collisions | Duration (s) | Mean / p95 replanning (ms) | Min clearance (m) | Min TTC (s) | Emergency episodes |
|---|---|---:|---:|---:|---:|---:|---:|
| Village road | goal | 0 | 44.2 | 8.8 / 14.1 | 2.23 | 0.00 | 15 |
| Urban intersection | goal | 0 | 24.3 | 8.3 / 13.4 | 5.23 | 0.00 | 4 |
| Highway merge | goal | 0 | 28.1 | 8.8 / 13.7 | 19.70 | 0.00 | 9 |
| Dense market | goal | 0 | 24.8 | 11.7 / 21.7 | 3.66 | 0.00 | 4 |
| Cattle crossing | goal | 0 | 26.7 | 9.4 / 19.7 | 3.20 | 0.00 | 10 |

Minimum TTC is a prediction-envelope estimate. Zero can reflect uncertainty or a transient track overlap without an actual collision; collision counts and geometric clearance are scored from scenario truth.

## Generated evidence

- Screenshots: 57 actual PNG files, including eight event frames per scene.
- Figures: 8 actual PNG files from logged data.
- Videos: 6 actual MP4 files, including five individual scenes and the combined demo.
- Simulink: [model diagram](screenshots/simulink/full_model.png) and [integrated subsystem](screenshots/simulink/closed_loop_subsystem.png).
- Browse every artifact in [EVIDENCE_INDEX.md](EVIDENCE_INDEX.md).

## Remaining external blockers

Standalone RoadRunner was not found, so no RoadRunner scene screenshots are claimed. The IDD details file and dataset were absent, so no IDD-trained perception is claimed. The executed Simulink model uses truth-mode village integration; synthetic-fusion execution is validated by the MATLAB runner.

No scriptable desktop recorder was found on PATH; desktop screen capture was optional. The MATLAB-native videos above are the primary visual evidence.

- [Preserved resolved export failure](logs/canonical_benchmark_initial_failure.txt).
- [Preserved resolved export failure](logs/canonical_benchmark_second_failure.txt).
- [Preserved resolved export failure](logs/evidence_smoke.txt).
