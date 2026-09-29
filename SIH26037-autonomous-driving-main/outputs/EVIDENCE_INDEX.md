# SIH26037 evidence index

The Vehicle Dynamics Blockset 3D recordings and Unreal camera preview are indexed in [VDB 3D evidence](VDB_3D_EVIDENCE.md). The artifacts below belong to the earlier MATLAB bicycle-model benchmark.

Every simulation image/video below was rendered from an actual successful logged run. Black outlines show simulation truth for evaluation; red crosses and dotted lines show sensor-mode tracks and predictions. The cyan curve is the selected ego trajectory.

## 1. Village road

| Artifact | Logged moment | Demonstrated behavior | Provenance |
|---|---:|---|---|
| [initial](screenshots/01_village/01_initial.png) | 0.0 s | Initial ego state and scenario geometry | Executed successful run |
| [cruise](screenshots/01_village/02_cruise.png) | 6.1 s | Normal cruising and selected plan | Executed successful run |
| [interaction](screenshots/01_village/03_interaction.png) | 18.7 s | Observed interaction with another road user | Executed successful run |
| [prediction](screenshots/01_village/04_prediction.png) | 17.2 s | Tracked actor motion and growing future occupancy | Executed successful run |
| [planning](screenshots/01_village/05_planning.png) | 18.5 s | Logged candidate lattice and selected trajectory | Executed successful run |
| [highest_risk](screenshots/01_village/06_highest_risk.png) | 0.2 s | Critical risk/TTC event during the interaction | Executed successful run |
| [response](screenshots/01_village/07_response.png) | 0.5 s | Observed braking, yielding, or replanning response | Executed successful run |
| [final](screenshots/01_village/08_final.png) | 44.2 s | Final successful terminal state | Executed successful run |
| [Scenario MP4](videos/village_demo.mp4) | Full recorded run | Ego, actors, tracks, prediction, plan, behavior, risk, speed, TTC, latency | Executed successful run |

## 2. Urban intersection

| Artifact | Logged moment | Demonstrated behavior | Provenance |
|---|---:|---|---|
| [initial](screenshots/02_intersection/01_initial.png) | 0.0 s | Initial ego state and scenario geometry | Executed successful run |
| [cruise](screenshots/02_intersection/02_cruise.png) | 1.5 s | Normal cruising and selected plan | Executed successful run |
| [interaction](screenshots/02_intersection/03_interaction.png) | 20.8 s | Observed interaction with another road user | Executed successful run |
| [prediction](screenshots/02_intersection/04_prediction.png) | 19.3 s | Tracked actor motion and growing future occupancy | Executed successful run |
| [planning](screenshots/02_intersection/05_planning.png) | 21.0 s | Logged candidate lattice and selected trajectory | Executed successful run |
| [highest_risk](screenshots/02_intersection/06_highest_risk.png) | 1.9 s | Critical risk/TTC event during the interaction | Executed successful run |
| [response](screenshots/02_intersection/07_response.png) | 1.9 s | Observed braking, yielding, or replanning response | Executed successful run |
| [final](screenshots/02_intersection/08_final.png) | 24.3 s | Final successful terminal state | Executed successful run |
| [Scenario MP4](videos/intersection_demo.mp4) | Full recorded run | Ego, actors, tracks, prediction, plan, behavior, risk, speed, TTC, latency | Executed successful run |

## 3. Highway merge

| Artifact | Logged moment | Demonstrated behavior | Provenance |
|---|---:|---|---|
| [initial](screenshots/03_highway_merge/01_initial.png) | 0.0 s | Initial ego state and scenario geometry | Executed successful run |
| [cruise](screenshots/03_highway_merge/02_cruise.png) | 1.5 s | Normal cruising and selected plan | Executed successful run |
| [interaction](screenshots/03_highway_merge/03_interaction.png) | 0.0 s | Observed interaction with another road user | Executed successful run |
| [prediction](screenshots/03_highway_merge/04_prediction.png) | 0.0 s | Tracked actor motion and growing future occupancy | Executed successful run |
| [planning](screenshots/03_highway_merge/05_planning.png) | 0.0 s | Logged candidate lattice and selected trajectory | Executed successful run |
| [highest_risk](screenshots/03_highway_merge/06_highest_risk.png) | 2.4 s | Critical risk/TTC event during the interaction | Executed successful run |
| [response](screenshots/03_highway_merge/07_response.png) | 2.3 s | Observed braking, yielding, or replanning response | Executed successful run |
| [final](screenshots/03_highway_merge/08_final.png) | 28.1 s | Final successful terminal state | Executed successful run |
| [Scenario MP4](videos/highway_merge_demo.mp4) | Full recorded run | Ego, actors, tracks, prediction, plan, behavior, risk, speed, TTC, latency | Executed successful run |

## 4. Dense market

| Artifact | Logged moment | Demonstrated behavior | Provenance |
|---|---:|---|---|
| [initial](screenshots/04_market/01_initial.png) | 0.0 s | Initial ego state and scenario geometry | Executed successful run |
| [cruise](screenshots/04_market/02_cruise.png) | 4.0 s | Normal cruising and selected plan | Executed successful run |
| [interaction](screenshots/04_market/03_interaction.png) | 7.0 s | Observed interaction with another road user | Executed successful run |
| [prediction](screenshots/04_market/04_prediction.png) | 5.5 s | Tracked actor motion and growing future occupancy | Executed successful run |
| [planning](screenshots/04_market/05_planning.png) | 7.0 s | Logged candidate lattice and selected trajectory | Executed successful run |
| [highest_risk](screenshots/04_market/06_highest_risk.png) | 9.1 s | Critical risk/TTC event during the interaction | Executed successful run |
| [response](screenshots/04_market/07_response.png) | 9.1 s | Observed braking, yielding, or replanning response | Executed successful run |
| [final](screenshots/04_market/08_final.png) | 24.8 s | Final successful terminal state | Executed successful run |
| [Scenario MP4](videos/market_demo.mp4) | Full recorded run | Ego, actors, tracks, prediction, plan, behavior, risk, speed, TTC, latency | Executed successful run |

## 5. Cattle crossing

| Artifact | Logged moment | Demonstrated behavior | Provenance |
|---|---:|---|---|
| [initial](screenshots/05_cattle_crossing/01_initial.png) | 0.0 s | Initial ego state and scenario geometry | Executed successful run |
| [cruise](screenshots/05_cattle_crossing/02_cruise.png) | 3.9 s | Normal cruising and selected plan | Executed successful run |
| [interaction](screenshots/05_cattle_crossing/03_interaction.png) | 5.4 s | Observed interaction with another road user | Executed successful run |
| [prediction](screenshots/05_cattle_crossing/04_prediction.png) | 5.7 s | Tracked actor motion and growing future occupancy | Executed successful run |
| [planning](screenshots/05_cattle_crossing/05_planning.png) | 8.0 s | Logged candidate lattice and selected trajectory | Executed successful run |
| [highest_risk](screenshots/05_cattle_crossing/06_highest_risk.png) | 8.1 s | Critical risk/TTC event during the interaction | Executed successful run |
| [response](screenshots/05_cattle_crossing/07_response.png) | 5.9 s | Observed braking, yielding, or replanning response | Executed successful run |
| [final](screenshots/05_cattle_crossing/08_final.png) | 26.7 s | Final successful terminal state | Executed successful run |
| [Scenario MP4](videos/cattle_crossing_demo.mp4) | Full recorded run | Ego, actors, tracks, prediction, plan, behavior, risk, speed, TTC, latency | Executed successful run |

## Cross-scenario diagnostic screenshots

- [Village road / sensors](screenshots/sensors/01_village.png): Camera/radar tracks and lidar geometry against truth, from successful scene 1.
- [Village road / prediction](screenshots/prediction/01_village.png): Predicted actor occupancy and uncertainty, from successful scene 1.
- [Village road / planning](screenshots/planning/01_village.png): Planner candidate and selected trajectories, from successful scene 1.
- [Urban intersection / sensors](screenshots/sensors/02_intersection.png): Camera/radar tracks and lidar geometry against truth, from successful scene 2.
- [Urban intersection / prediction](screenshots/prediction/02_intersection.png): Predicted actor occupancy and uncertainty, from successful scene 2.
- [Urban intersection / planning](screenshots/planning/02_intersection.png): Planner candidate and selected trajectories, from successful scene 2.
- [Highway merge / sensors](screenshots/sensors/03_highway_merge.png): Camera/radar tracks and lidar geometry against truth, from successful scene 3.
- [Highway merge / prediction](screenshots/prediction/03_highway_merge.png): Predicted actor occupancy and uncertainty, from successful scene 3.
- [Highway merge / planning](screenshots/planning/03_highway_merge.png): Planner candidate and selected trajectories, from successful scene 3.
- [Dense market / sensors](screenshots/sensors/04_market.png): Camera/radar tracks and lidar geometry against truth, from successful scene 4.
- [Dense market / prediction](screenshots/prediction/04_market.png): Predicted actor occupancy and uncertainty, from successful scene 4.
- [Dense market / planning](screenshots/planning/04_market.png): Planner candidate and selected trajectories, from successful scene 4.
- [Cattle crossing / sensors](screenshots/sensors/05_cattle_crossing.png): Camera/radar tracks and lidar geometry against truth, from successful scene 5.
- [Cattle crossing / prediction](screenshots/prediction/05_cattle_crossing.png): Predicted actor occupancy and uncertainty, from successful scene 5.
- [Cattle crossing / planning](screenshots/planning/05_cattle_crossing.png): Planner candidate and selected trajectories, from successful scene 5.

## Result figures

- [replanning_latency.png](figures/replanning_latency.png): Mean and 95th percentile latency by scenario; measured successful runs.
- [minimum_clearance.png](figures/minimum_clearance.png): Minimum geometric clearance by scenario; measured successful runs.
- [scenario_success_completion.png](figures/scenario_success_completion.png): Goal success and duration by scenario; measured successful runs.
- [jerk_smoothness.png](figures/jerk_smoothness.png): Measured jerk and curvature change; measured successful runs.
- [executed_trajectories.png](figures/executed_trajectories.png): Executed paths across five scenarios; measured successful runs.
- [cattle_ttc.png](figures/cattle_ttc.png): Logged cattle-scene TTC over time; measured successful runs.
- [cattle_speed.png](figures/cattle_speed.png): Logged cattle-scene ego speed over time; measured successful runs.
- [cattle_risk.png](figures/cattle_risk.png): Logged cattle-scene risk category over time; measured successful runs.

## Simulink and combined demonstration

- [Full model](screenshots/simulink/full_model.png): programmatic export of the actual .slx; the village model passed CLI simulation.
- [Closed-loop subsystem](screenshots/simulink/closed_loop_subsystem.png): programmatic export of the actual integrated MATLAB-function block.
- [Combined five-scene MP4](videos/SIH26037_FINAL_DEMO.mp4): MATLAB-native concatenation of the five successful scenario videos.

The model has one tested integrated MATLAB-function subsystem. It has no separate sensor, fusion, risk, planner, or controller block diagrams to screenshot; no such diagrams are represented as real Simulink subsystems.
