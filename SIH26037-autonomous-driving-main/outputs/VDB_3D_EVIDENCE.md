# Verified VDB 3D evidence

These images and MP4s were generated from successful executed VDB Simulink runs. The MATLAB 3D view uses logged ego motion, scenario actor truth for visualization, and logged autonomy decisions. The sensor-mode planner does not consume the rendered view.

- [VDB benchmark chart](figures/vdb_3d_benchmark.png): measured clearance, latency, duration, and jerk from the executed CSV.

## 1. Village road

- [01 initial](screenshots/3d_vdb/village/01_initial.png): executed simulation frame.
- [02 cruising](screenshots/3d_vdb/village/02_cruising.png): executed simulation frame.
- [03 interaction](screenshots/3d_vdb/village/03_interaction.png): executed simulation frame.
- [04 risk](screenshots/3d_vdb/village/04_risk.png): executed simulation frame.
- [05 response](screenshots/3d_vdb/village/05_response.png): executed simulation frame.
- [06 terminal](screenshots/3d_vdb/village/06_terminal.png): executed simulation frame.
- [MATLAB screen recording](screen_recordings/SIH26037_VDB_3D_village_screen_recording.mp4): actual `getframe` frames of the 3D simulation view.
- [presentation video](videos/vdb_3d_village_demo.mp4): copy of the verified recording.

## 2. Urban intersection

- [01 initial](screenshots/3d_vdb/intersection/01_initial.png): executed simulation frame.
- [02 cruising](screenshots/3d_vdb/intersection/02_cruising.png): executed simulation frame.
- [03 interaction](screenshots/3d_vdb/intersection/03_interaction.png): executed simulation frame.
- [04 risk](screenshots/3d_vdb/intersection/04_risk.png): executed simulation frame.
- [05 response](screenshots/3d_vdb/intersection/05_response.png): executed simulation frame.
- [06 terminal](screenshots/3d_vdb/intersection/06_terminal.png): executed simulation frame.
- [MATLAB screen recording](screen_recordings/SIH26037_VDB_3D_intersection_screen_recording.mp4): actual `getframe` frames of the 3D simulation view.
- [presentation video](videos/vdb_3d_intersection_demo.mp4): copy of the verified recording.

## 3. Highway merge

- [01 initial](screenshots/3d_vdb/highway_merge/01_initial.png): executed simulation frame.
- [02 cruising](screenshots/3d_vdb/highway_merge/02_cruising.png): executed simulation frame.
- [03 interaction](screenshots/3d_vdb/highway_merge/03_interaction.png): executed simulation frame.
- [04 risk](screenshots/3d_vdb/highway_merge/04_risk.png): executed simulation frame.
- [05 response](screenshots/3d_vdb/highway_merge/05_response.png): executed simulation frame.
- [06 terminal](screenshots/3d_vdb/highway_merge/06_terminal.png): executed simulation frame.
- [MATLAB screen recording](screen_recordings/SIH26037_VDB_3D_highway_merge_screen_recording.mp4): actual `getframe` frames of the 3D simulation view.
- [presentation video](videos/vdb_3d_highway_merge_demo.mp4): copy of the verified recording.

## 4. Market road

- [01 initial](screenshots/3d_vdb/market/01_initial.png): executed simulation frame.
- [02 cruising](screenshots/3d_vdb/market/02_cruising.png): executed simulation frame.
- [03 interaction](screenshots/3d_vdb/market/03_interaction.png): executed simulation frame.
- [04 risk](screenshots/3d_vdb/market/04_risk.png): executed simulation frame.
- [05 response](screenshots/3d_vdb/market/05_response.png): executed simulation frame.
- [06 terminal](screenshots/3d_vdb/market/06_terminal.png): executed simulation frame.
- [MATLAB screen recording](screen_recordings/SIH26037_VDB_3D_market_screen_recording.mp4): actual `getframe` frames of the 3D simulation view.
- [presentation video](videos/vdb_3d_market_demo.mp4): copy of the verified recording.

## 5. Cattle crossing

- [01 initial](screenshots/3d_vdb/01_initial.png): executed simulation frame.
- [02 cattle appears](screenshots/3d_vdb/02_cattle_appears.png): executed simulation frame.
- [03 critical risk](screenshots/3d_vdb/03_critical_risk.png): executed simulation frame.
- [04 emergency brake](screenshots/3d_vdb/04_emergency_brake.png): executed simulation frame.
- [05 replanning](screenshots/3d_vdb/05_replanning.png): executed simulation frame.
- [06 terminal](screenshots/3d_vdb/06_terminal.png): executed simulation frame.
- [MATLAB screen recording](screen_recordings/SIH26037_VDB_3D_cattle_screen_recording.mp4): actual `getframe` frames of the 3D simulation view.
- [presentation video](videos/vdb_3d_cattle_crossing_demo.mp4): copy of the verified recording.

## Simulink

- [VDB closed-loop model](screenshots/simulink/vdb_closed_loop_full_model.png): actual generated Simulink model.

## Unreal camera preview

- [Unreal camera recording](screen_recordings/SIH26037_Unreal_VDB_camera.mp4): frames returned by the actual Simulation 3D Camera block.
- [01 unreal camera initial](screenshots/3d_unreal/01_unreal_camera_initial.png): actual Unreal camera frame.
- [02 unreal camera final](screenshots/3d_unreal/02_unreal_camera_final.png): actual Unreal camera frame.
- [Wheel alignment probe](screenshots/3d_unreal/wheel_probe.png): actual 1 s Unreal camera smoke run used to verify the Sedan mesh pose.

The generic Unreal open surface contains the ego vehicle only.
