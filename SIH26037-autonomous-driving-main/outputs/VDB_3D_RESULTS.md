# Executed Vehicle Dynamics Blockset and 3D results

Source: [executed five-scene CSV](metrics/vdb_synthetic_benchmark.csv). All five canonical sensor-mode scenarios reached the goal without a scored collision. One deterministic seed per scenario was run with the VDB plant.

| Scenario | Result | Collisions | Duration (s) | Min clearance (m) | Mean / p95 planning (ms) | Emergency episodes |
|---|---|---:|---:|---:|---:|---:|
| Village road | goal | 0 | 40.24 | 2.25 | 12.8 / 22.1 | 12 |
| Urban intersection | goal | 0 | 27.90 | 5.66 | 9.8 / 16.4 | 6 |
| Highway merge | goal | 0 | 34.22 | 19.70 | 9.0 / 15.3 | 12 |
| Market road | goal | 0 | 29.10 | 2.98 | 8.4 / 12.7 | 5 |
| Cattle crossing | goal | 0 | 19.56 | 3.91 | 36.3 / 106.4 | 9 |

The minimum TTC estimator reached zero in every scene. This is a conservative prediction-envelope result, not a measured collision; see geometric clearance and collision count above. VDB RMS jerk was 15.6 to 26.0 m/s^3, so longitudinal smoothness still needs improvement.

The VDB single-track block simulates planar longitudinal/lateral/yaw dynamics. The 3D MATLAB recordings are captured from the actual logged vehicle state and actor trajectories. The optional Unreal scene shows a 3D ego vehicle on a generic open surface; it is not a detailed Indian-road scene. No IDD-trained image perception or RoadRunner assets are claimed. No defensible numeric percentage of the SIH problem statement follows from these five deterministic tests.

See [the verified 3D evidence index](VDB_3D_EVIDENCE.md) for 30 screenshots and five video recordings.
[VDB benchmark chart](figures/vdb_3d_benchmark.png) plots the measured CSV values.
