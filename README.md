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

## Complete project file tree

<details>
<summary>Show all project files</summary>

```text
SIH26037-autonomous-driving-main/
├── .gitignore
├── audit_environment.m
├── AutonomousDriving.slx
├── build_simulink_model.m
├── build_vdb_closed_loop.m
├── capture_outputs.m
├── generate_results.m
├── generate_vdb_3d_report.m
├── README.md
├── record_vdb_all_3d.m
├── run_all_scenarios.m
├── run_demo.m
├── run_seed_sweep.m
├── run_vdb_3d_demo.m
├── run_vdb_all_scenarios.m
├── run_vdb_unreal_preview.m
├── runAllTests.m
├── setup_project.m
├── VDB_ClosedLoop.slx
├── VDB_Unreal_ClosedLoop.slx
├── docs/
│   ├── algorithms.md
│   ├── architecture.md
│   └── scenarios.md
├── outputs/
│   ├── EVIDENCE_INDEX.md
│   ├── FINAL_RESULTS.md
│   ├── VDB_3D_EVIDENCE.md
│   ├── VDB_3D_RESULTS.md
│   ├── figures/
│   │   ├── cattle_risk.png
│   │   ├── cattle_speed.png
│   │   ├── cattle_ttc.png
│   │   ├── executed_trajectories.png
│   │   ├── jerk_smoothness.png
│   │   ├── minimum_clearance.png
│   │   ├── replanning_latency.png
│   │   ├── scenario_success_completion.png
│   │   └── vdb_3d_benchmark.png
│   ├── metrics/
│   │   ├── 01_village_events.csv
│   │   ├── 02_intersection_events.csv
│   │   ├── 03_highway_merge_events.csv
│   │   ├── 04_market_events.csv
│   │   ├── 05_cattle_crossing_events.csv
│   │   ├── scenario_1.mat
│   │   ├── scenario_2.mat
│   │   ├── scenario_3.mat
│   │   ├── scenario_4.mat
│   │   ├── scenario_5.mat
│   │   ├── seed_sweep.csv
│   │   ├── synthetic_fusion_benchmark.csv
│   │   ├── truth_benchmark.csv
│   │   └── vdb_synthetic_benchmark.csv
│   ├── screen_recordings/
│   │   ├── SIH26037_VDB_3D_cattle_screen_recording.mp4
│   │   ├── SIH26037_VDB_3D_highway_merge_screen_recording.mp4
│   │   ├── SIH26037_VDB_3D_intersection_screen_recording.mp4
│   │   ├── SIH26037_VDB_3D_market_screen_recording.mp4
│   │   └── SIH26037_VDB_3D_village_screen_recording.mp4
│   ├── screenshots/
│   │   ├── 01_village/
│   │   │   ├── 01_initial.png
│   │   │   ├── 02_cruise.png
│   │   │   ├── 03_interaction.png
│   │   │   ├── 04_prediction.png
│   │   │   ├── 05_planning.png
│   │   │   ├── 06_highest_risk.png
│   │   │   ├── 07_response.png
│   │   │   └── 08_final.png
│   │   ├── 02_intersection/
│   │   │   ├── 01_initial.png
│   │   │   ├── 02_cruise.png
│   │   │   ├── 03_interaction.png
│   │   │   ├── 04_prediction.png
│   │   │   ├── 05_planning.png
│   │   │   ├── 06_highest_risk.png
│   │   │   ├── 07_response.png
│   │   │   └── 08_final.png
│   │   ├── 03_highway_merge/
│   │   │   ├── 01_initial.png
│   │   │   ├── 02_cruise.png
│   │   │   ├── 03_interaction.png
│   │   │   ├── 04_prediction.png
│   │   │   ├── 05_planning.png
│   │   │   ├── 06_highest_risk.png
│   │   │   ├── 07_response.png
│   │   │   └── 08_final.png
│   │   ├── 04_market/
│   │   │   ├── 01_initial.png
│   │   │   ├── 02_cruise.png
│   │   │   ├── 03_interaction.png
│   │   │   ├── 04_prediction.png
│   │   │   ├── 05_planning.png
│   │   │   ├── 06_highest_risk.png
│   │   │   ├── 07_response.png
│   │   │   └── 08_final.png
│   │   ├── 05_cattle_crossing/
│   │   │   ├── 01_initial.png
│   │   │   ├── 02_cruise.png
│   │   │   ├── 03_interaction.png
│   │   │   ├── 04_prediction.png
│   │   │   ├── 05_planning.png
│   │   │   ├── 06_highest_risk.png
│   │   │   ├── 07_response.png
│   │   │   └── 08_final.png
│   │   ├── 3d_unreal/
│   │   │   ├── 01_unreal_camera_initial.png
│   │   │   ├── 02_unreal_camera_final.png
│   │   │   └── wheel_probe.png
│   │   ├── 3d_vdb/
│   │   │   ├── 01_initial.png
│   │   │   ├── 02_cattle_appears.png
│   │   │   ├── 03_critical_risk.png
│   │   │   ├── 04_emergency_brake.png
│   │   │   ├── 05_replanning.png
│   │   │   ├── 06_terminal.png
│   │   │   ├── highway_merge/
│   │   │   │   ├── 01_initial.png
│   │   │   │   ├── 02_cruising.png
│   │   │   │   ├── 03_interaction.png
│   │   │   │   ├── 04_risk.png
│   │   │   │   ├── 05_response.png
│   │   │   │   └── 06_terminal.png
│   │   │   ├── intersection/
│   │   │   │   ├── 01_initial.png
│   │   │   │   ├── 02_cruising.png
│   │   │   │   ├── 03_interaction.png
│   │   │   │   ├── 04_risk.png
│   │   │   │   ├── 05_response.png
│   │   │   │   └── 06_terminal.png
│   │   │   ├── market/
│   │   │   │   ├── 01_initial.png
│   │   │   │   ├── 02_cruising.png
│   │   │   │   ├── 03_interaction.png
│   │   │   │   ├── 04_risk.png
│   │   │   │   ├── 05_response.png
│   │   │   │   └── 06_terminal.png
│   │   │   └── village/
│   │   │       ├── 01_initial.png
│   │   │       ├── 02_cruising.png
│   │   │       ├── 03_interaction.png
│   │   │       ├── 04_risk.png
│   │   │       ├── 05_response.png
│   │   │       └── 06_terminal.png
│   │   ├── planning/
│   │   │   ├── 01_village.png
│   │   │   ├── 02_intersection.png
│   │   │   ├── 03_highway_merge.png
│   │   │   ├── 04_market.png
│   │   │   └── 05_cattle_crossing.png
│   │   ├── prediction/
│   │   │   ├── 01_village.png
│   │   │   ├── 02_intersection.png
│   │   │   ├── 03_highway_merge.png
│   │   │   ├── 04_market.png
│   │   │   └── 05_cattle_crossing.png
│   │   ├── sensors/
│   │   │   ├── 01_village.png
│   │   │   ├── 02_intersection.png
│   │   │   ├── 03_highway_merge.png
│   │   │   ├── 04_market.png
│   │   │   └── 05_cattle_crossing.png
│   │   └── simulink/
│   │       ├── closed_loop_subsystem.png
│   │       ├── full_model.png
│   │       ├── vdb_closed_loop_full_model.png
│   │       └── vdb_unreal_full_model.png
│   └── videos/
│       ├── cattle_crossing_demo.mp4
│       ├── highway_merge_demo.mp4
│       ├── intersection_demo.mp4
│       ├── market_demo.mp4
│       ├── SIH26037_FINAL_DEMO.mp4
│       ├── vdb_3d_cattle_crossing_demo.mp4
│       ├── vdb_3d_cattle_demo.mp4
│       ├── vdb_3d_highway_merge_demo.mp4
│       ├── vdb_3d_intersection_demo.mp4
│       ├── vdb_3d_market_demo.mp4
│       ├── vdb_3d_village_demo.mp4
│       └── village_demo.mp4
├── results/
│   ├── figures/
│   │   ├── cattle_decisions.png
│   │   ├── cattle_demo.mp4
│   │   ├── cattle_demo.png
│   │   ├── cattle_truth_decisions.png
│   │   ├── sensor_debug.png
│   │   ├── synthetic_fusion_scenario_1.png
│   │   ├── synthetic_fusion_scenario_2.png
│   │   ├── synthetic_fusion_scenario_3.png
│   │   ├── synthetic_fusion_scenario_4.png
│   │   ├── synthetic_fusion_scenario_5.png
│   │   ├── synthetic_fusion_summary.png
│   │   ├── truth_scenario_1.png
│   │   ├── truth_scenario_2.png
│   │   ├── truth_scenario_3.png
│   │   ├── truth_scenario_4.png
│   │   ├── truth_scenario_5.png
│   │   └── truth_summary.png
│   └── metrics/
│       ├── demo.mat
│       ├── seed_sweep.csv
│       ├── synthetic_fusion_benchmark.csv
│       ├── synthetic_fusion_scenario_1.mat
│       ├── synthetic_fusion_scenario_2.mat
│       ├── synthetic_fusion_scenario_3.mat
│       ├── synthetic_fusion_scenario_4.mat
│       ├── synthetic_fusion_scenario_5.mat
│       ├── truth_benchmark.csv
│       ├── truth_scenario_1.mat
│       ├── truth_scenario_2.mat
│       ├── truth_scenario_3.mat
│       ├── truth_scenario_4.mat
│       ├── truth_scenario_5.mat
│       ├── vdb_3d_demo.mat
│       ├── vdb_sensor_cattle_scored.mat
│       ├── vdb_sensor_cattle.mat
│       ├── vdb_synthetic_scenario_1.mat
│       ├── vdb_synthetic_scenario_2.mat
│       ├── vdb_synthetic_scenario_3.mat
│       ├── vdb_synthetic_scenario_4.mat
│       ├── vdb_synthetic_scenario_5.mat
│       ├── vdb_truth_cattle.mat
│       └── vdb_unreal_preview.mat
├── src/
│   └── +sih/
│       ├── actorStates.m
│       ├── assessRisk.m
│       ├── behavior.m
│       ├── benchmarkCase.m
│       ├── captureScenarioEvidence.m
│       ├── captureSimulinkEvidence.m
│       ├── checkTrajectory.m
│       ├── combineEvidenceVideos.m
│       ├── config.m
│       ├── control.m
│       ├── egoToWorld.m
│       ├── exportEvidenceVideo.m
│       ├── exportUnrealCamera.m
│       ├── exportVideo.m
│       ├── fuseMeasurements.m
│       ├── generateOutputFigures.m
│       ├── iddInventory.m
│       ├── makeScenario.m
│       ├── metrics.m
│       ├── observe.m
│       ├── planTrajectory.m
│       ├── plotDecisionTimeline.m
│       ├── plotRun.m
│       ├── plotSensorDebug.m
│       ├── predictActors.m
│       ├── recordVdb3D.m
│       ├── renderEvidenceFrame.m
│       ├── renderVdb3DFrame.m
│       ├── safeStop.m
│       ├── selectEvidenceEvents.m
│       ├── SensorSuite.m
│       ├── simulate.m
│       ├── simulinkPipeline.m
│       ├── stepVehicle.m
│       ├── unrealCarRotation.m
│       ├── unrealCarTranslation.m
│       ├── vdbAutonomy.m
│       ├── vdbGoalReached.m
│       ├── vdbMetrics.m
│       ├── vdbWorldDerivative.m
│       ├── verifyOutputs.m
│       └── writeEvidenceDocs.m
└── tests/
    ├── audit_3d_environment.m
    ├── check_parse.m
    ├── inspect_vdb_interface.m
    ├── probe_unreal_vehicle.m
    ├── probe_vdb_blocks.m
    ├── probe_vdb_ports.m
    ├── run_tests.m
    ├── test_sim3d_runtime.m
    ├── test_simulink_smoke.m
    ├── test_vdb_plant.m
    └── benchmark/
        ├── benchmarkTests.m
        ├── codeFingerprint.m
        ├── emptyBenchmarkRow.m
        ├── makeManifest.m
        ├── README.md
        ├── runCase.m
        ├── scoreCase.m
        ├── SIH_VDB_Benchmark.slx
        ├── writeBenchmarkReports.m
        └── results/
            ├── benchmark_cli.log
            ├── BENCHMARK_REPORT.md
            ├── campaign_cli_original.log
            ├── compatibility_audit.log
            ├── existing_tests_validation.log
            ├── manifest_cases.csv
            ├── manifest.mat
            ├── post_campaign_validation.log
            ├── report_regeneration.log
            ├── run_01_B00.mat
            ├── run_02_N01.mat
            ├── run_03_N02.mat
            ├── run_04_N03.mat
            ├── run_05_A01.mat
            ├── run_06_A02.mat
            ├── run_07_A03.mat
            ├── run_08_A04.mat
            ├── run_09_E01.mat
            ├── run_10_E02.mat
            ├── run_11_S01.mat
            ├── run_12_S02.mat
            ├── run_13_B00.mat
            ├── run_14_N01.mat
            ├── run_15_N02.mat
            ├── run_16_N03.mat
            ├── run_17_A01.mat
            ├── run_18_A02.mat
            ├── run_19_A03.mat
            ├── run_20_A04.mat
            ├── run_21_E01.mat
            ├── run_22_E02.mat
            ├── run_23_S01.mat
            ├── run_24_S02.mat
            ├── run_25_B00.mat
            ├── run_26_N01.mat
            ├── run_27_N02.mat
            ├── run_28_N03.mat
            ├── run_29_A01.mat
            ├── run_30_A02.mat
            ├── run_31_A03.mat
            ├── run_32_A04.mat
            ├── run_33_E01.mat
            ├── run_34_E02.mat
            ├── run_35_S01.mat
            ├── run_36_S02.mat
            ├── run_37_B00.mat
            ├── run_38_N01.mat
            ├── run_39_N02.mat
            ├── run_40_N03.mat
            ├── run_41_A01.mat
            ├── run_42_A02.mat
            ├── run_43_A03.mat
            ├── run_44_A04.mat
            ├── run_45_E01.mat
            ├── run_46_E02.mat
            ├── run_47_S01.mat
            ├── run_48_S02.mat
            ├── run_49_B00.mat
            ├── run_50_N01.mat
            ├── run_51_N02.mat
            ├── run_52_N03.mat
            ├── run_53_A01.mat
            ├── run_54_A02.mat
            ├── run_55_A03.mat
            ├── run_56_A04.mat
            ├── run_57_E01.mat
            ├── run_58_E02.mat
            ├── run_59_S01.mat
            ├── run_60_S02.mat
            ├── SIH26037_5_scenarios.csv
            ├── SIH26037_60_cases.csv
            ├── smoke_goalstop.log
            ├── smoke_validation_ee0e8577f527.mat
            └── pre_campaign_smoke_v1/
                ├── manifest_cases.csv
                ├── manifest.mat
                ├── smoke_preflight.log
                └── smoke_validation.mat
```

</details>
