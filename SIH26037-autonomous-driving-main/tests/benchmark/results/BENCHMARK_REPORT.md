# SIH26037 recorded 60-case VDB benchmark

The saved campaign ran 12 synthetic camera/radar/LiDAR cases in each of five scenarios using the Vehicle Dynamics Blockset single-track plant. The [case CSV](SIH26037_60_cases.csv), [scenario CSV](SIH26037_5_scenarios.csv), [case manifest](manifest_cases.csv), original [campaign log](campaign_cli_original.log), and `run_XX_CASE.mat` files are the recorded evidence. This summary was checked against the saved CSVs; it is not a new simulation run.

## Execution and driving outcomes

**60/60 cases executed and produced valid measurements. 58/60 reached the goal, two timed out, and zero collision episodes were scored.** The timeouts were village case `A02` and merge case `E01`.

| Scenario | Executed | Valid | Goals reached | Timeouts | Collision episodes |
|---|---:|---:|---:|---:|---:|
| Unmarked village road | 12 | 12 | 11 | 1 | 0 |
| Unsignalized urban intersection | 12 | 12 | 12 | 0 | 0 |
| Arterial slow-traffic merge | 12 | 12 | 11 | 1 | 0 |
| Dense mixed market | 12 | 12 | 12 | 0 | 0 |
| Sudden cattle crossing | 12 | 12 | 12 | 0 | 0 |

## Strict performance gates

**0/60 cases passed all five user-proposed strict gates.** The CSV `status=FAIL` marks a valid, executed case that missed at least one gate. It does not mean the case failed to run. `rawOutcome` records whether the vehicle reached the goal or timed out; `collisionEpisodes` records scored contacts. These gates are not official SIH acceptance criteria.

| Gate | Required | Cases meeting gate |
|---|---:|---:|
| Scored collision episodes | 0 | 60/60 |
| Minimum predicted TTC | > 0.95 s | 0/60 |
| Goal completion | Yes | 58/60 |
| P95 replanning latency | < 100 ms | 6/60 |
| Maximum absolute physical longitudinal jerk | < 0.9 m/s³ | 0/60 |

All 60 recorded P95 replanning values were below 150 ms, but 54 missed the stricter 100 ms gate. The largest recorded P95 was 144.34 ms. Predicted TTC can be zero because the conservative prediction envelopes overlap; zero TTC is not a scored collision. The speed-derived jerk values range from 417.92 to 658.22 m/s³ and show that ride smoothness needs work.

The [benchmark instructions](../README.md) explain how a matching MATLAB R2026b installation can verify the saved MAT logs with `runAllTests('resume')`. The [original campaign log](campaign_cli_original.log) and [later resume log](benchmark_cli.log) are preserved separately. Results from this synthetic benchmark are simulation evidence, not real-road safety certification.
