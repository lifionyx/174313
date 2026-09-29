# LIFIONYX | SIH26037 Autonomous Driving

**Smart India Hackathon 2026 · Team 174313**

We built a MATLAB/Simulink prototype that plans a safe path for a car on unstructured Indian roads. It handles road users such as pedestrians, two-wheelers, auto-rickshaws, pushcarts, trucks, and cattle in five simulated scenarios.

## See the project in two minutes

1. Read our [six-slide presentation](ppt/v35.pdf).
2. Watch the [combined demo video](SIH26037-autonomous-driving-main/outputs/videos/SIH26037_FINAL_DEMO.mp4).
3. Open the [Simulink model image](SIH26037-autonomous-driving-main/outputs/screenshots/simulink/vdb_closed_loop_full_model.png) and [five-scenario results](SIH26037-autonomous-driving-main/outputs/VDB_3D_RESULTS.md).
4. Read the [60-case benchmark report](SIH26037-autonomous-driving-main/tests/benchmark/results/BENCHMARK_REPORT.md) for the full stress-test results.

## What the software does

`Simulated camera, radar, LiDAR → tracked road users → motion prediction → risk check → path planning → vehicle control → next sensor reading`

The vehicle repeatedly checks its surroundings and updates its path. The tests cover an unmarked village road, an unsignalized intersection, a slow-traffic merge, a dense market, and a sudden cattle crossing. The implementation and its limits are explained in the [project README](SIH26037-autonomous-driving-main/README.md).

## What the results mean

The recorded 60-case benchmark **ran all 60 cases**. All produced valid measurements: **58 reached the goal, two timed out, and none had a scored collision episode**. The separate strict performance check passed **0/60** cases because the predicted time-to-collision, ride smoothness, and some replanning-time limits were missed. In the results CSV, `FAIL` means a strict limit was missed; it does **not** mean a test failed to execute. These limits are team-proposed, not official SIH pass criteria.

This is a simulation prototype. It uses synthetic sensor detections and constant-velocity prediction; YOLOX-S, learned multi-hypothesis prediction, and real-road testing are proposed future work.

## Folder guide

| Path | What you will find |
|---|---|
| [`ppt/`](ppt/) | Hackathon presentation PDF |
| [`SIH26037-autonomous-driving-main/`](SIH26037-autonomous-driving-main/) | MATLAB/Simulink project and its own detailed README |
| [`src/+sih/`](SIH26037-autonomous-driving-main/src/+sih/) | Perception, prediction, risk, planning, control, and simulation code |
| [`docs/`](SIH26037-autonomous-driving-main/docs/) | Architecture, algorithms, and scenario definitions |
| [`outputs/`](SIH26037-autonomous-driving-main/outputs/) | Demo videos, screenshots, plots, and earlier five-scenario results |
| [`tests/benchmark/results/`](SIH26037-autonomous-driving-main/tests/benchmark/results/) | 60-case CSV results, case logs, and benchmark report |

## Run it

Use MATLAB from the `SIH26037-autonomous-driving-main` folder. The recorded 60-case campaign was made with **MATLAB R2026b** and requires Simulink, Automated Driving Toolbox, Vehicle Dynamics Blockset, and the toolboxes used by the project. The [benchmark instructions](SIH26037-autonomous-driving-main/tests/benchmark/README.md) give the exact prerequisites and commands.

```matlab
run_demo                         % Cattle-crossing demo
run_vdb_all_scenarios            % Five Vehicle Dynamics Blockset scenarios
runAllTests('resume')            % Verify saved 60-case logs on MATLAB R2026b
```
