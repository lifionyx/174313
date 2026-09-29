# Architecture and frames

The executable loop is `sih.simulate`: scenario truth → sensor suite or explicit truth mode → world tracks → 4 s predictions → risk → behavior → trajectory lattice → controller → bicycle plant → next step. `sih.simulinkPipeline` calls the same subsystem functions in a fixed-step Simulink model for the village scene.

World coordinates are metres. +x points along intended road progress, +y is left of that direction, and yaw is counterclockwise in radians. The ego state is `[x,y,yaw,speed]`; the camera/radar/lidar generators receive target poses relative to the ego. `egoToWorld` rotates measurements back to world coordinates. Actor truth is never returned as a track in `synthetic_fusion` mode; it is used to simulate sensors and score collisions.

The `drivingScenario` object defines programmatic road geometry and custom-size actor representations. A backend-independent event model handles late actor births and crossings so both truth and sensor modes use the same events. A Navigation Toolbox `binaryOccupancyMap` encodes the road envelope, with an analytic vehicle-width boundary check. The x direction is the reference route through free space; the local planner varies lateral offset and speed without using lane paint. This is sufficient for the five straight-through prototype tasks, but it is not a general map or intersection route planner.

Sensor mode uses `visionDetectionGenerator` and `drivingRadarDataGenerator` object detections, `lidarPointCloudGenerator` geometry, nearest-neighbor measurement association, an alpha-beta-style velocity update, short track coasting, and increasing uncertainty. Lidar obstacle points corroborate nearby tracks and reduce their covariance. All tracks influence immediate risk; confirmation affects track confidence and predicted uncertainty. Simulator cluster IDs are not used as perception IDs. The project does not claim raw-image detection, semantic lidar segmentation, or JPDA performance.

The Simulink model has a fixed-step Clock, a closed-loop autonomy subsystem that invokes the tested MATLAB stack, and a logged ten-channel state/diagnostic output. Its executed smoke test uses truth mode. Sensor-mode validation is through the MATLAB runner.

## Vehicle Dynamics Blockset and 3D profile

`build_vdb_closed_loop.m` generates a separate `models/SIH_VDB_ClosedLoop.slx`. Its Vehicle Dynamics Blockset `Vehicle Body 3DOF Single Track` block receives steering angle and longitudinal tire forces from `sih.vdbAutonomy`. The body block integrates longitudinal/lateral velocity and yaw rate; x/y integrators close the ego pose feedback loop. The package adapter converts the block's SAE right-positive lateral convention to this project's left-positive world convention. `run_vdb_all_scenarios` executes this model in synthetic camera/radar/lidar mode in all five scenarios and scores its actual logged trajectory against scenario truth.

`sih.recordVdb3D` draws the logged VDB pose, actor geometry, detected tracks, predictions, and planner telemetry as a MATLAB 3D figure. The captured MP4 uses actual `getframe` calls while replaying a successful run; the screenshots are taken at logged events. This is a visual replay of an executed VDB closed loop, with analytic 3D geometry for road users. The vehicle physics remain planar 3DOF.

`models/SIH_VDB_Unreal_ClosedLoop.slx` adds `Simulation 3D Scene Configuration`, `Simulation 3D Vehicle`, and a `Simulation 3D Camera` to the same VDB closed loop. It uses the installed generic `Open surface` Unreal scene. The Unreal camera is a visual preview and does not feed the autonomous perception stack. Detailed Indian traffic actor assets in Unreal or RoadRunner have not been authored.
