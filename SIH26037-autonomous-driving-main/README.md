# SIH26037 autonomous driving prototype

This project is LIFIONYX's MATLAB/Simulink prototype for adaptive path planning and collision avoidance on unstructured Indian roads. The five simulated scenarios cover an unmarked village road, an unsignalized intersection, a slow-traffic merge, a dense market, and a sudden cattle crossing.

## What the recorded tests show

The [60-case Vehicle Dynamics Blockset benchmark](tests/benchmark/results/BENCHMARK_REPORT.md) contains **60/60 executed, 60/60 valid cases, 58/60 goals reached, two timeouts, and zero scored collision episodes**. Every case has a saved MAT trace; the [case CSV](tests/benchmark/results/SIH26037_60_cases.csv) holds the measured outcomes.

The benchmark also applies five *user-proposed strict performance gates*. **Zero of 60 cases met all five gates.** In the CSV, `status=FAIL` means a valid, executed case missed at least one gate. It does not mean the simulation crashed or that a collision occurred. The predicted TTC and physical jerk gates were missed in all 60 cases; the <100 ms replanning gate was met in six. These limits are not official SIH acceptance criteria.

The [presentation](../ppt/v35.pdf) discusses YOLOX-S and multi-hypothesis prediction as part of the proposed approach. The recorded implementation uses synthetic camera/radar/LiDAR measurements and constant-velocity actor prediction. The [architecture](docs/architecture.md) and [algorithms](docs/algorithms.md) describe the implemented pipeline and its limits.

## Evidence and reproduction

- [Benchmark definitions, commands, and saved-run policy](tests/benchmark/README.md)
- [Earlier five-scenario MATLAB results](outputs/FINAL_RESULTS.md) and [VDB five-scenario results](outputs/VDB_3D_RESULTS.md), which are separate from the 60-case campaign
- [Recorded 3D evidence](outputs/VDB_3D_EVIDENCE.md)

The saved 60-case campaign was recorded with MATLAB R2026b. `runAllTests('resume')` verifies existing MAT logs against the frozen manifest and regenerates benchmark outputs on a matching installation; it does not rerun the 60 cases. A fresh campaign requires separate result storage so the saved evidence is retained.
