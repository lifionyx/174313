function report=generate_vdb_3d_report
root=fileparts(mfilename('fullpath'));
out=fullfile(root,'outputs');
csv=fullfile(out,'metrics','vdb_synthetic_benchmark.csv');
assert(isfile(csv),'Missing executed VDB benchmark CSV.');
t=readtable(csv);
assert(height(t)==5 && isequal(t.scenario(:),(1:5)') && ...
    all(t.success==1) && all(t.collisionCount==0), ...
    'Five successful collision-free VDB scenarios are required.');
slugs={'village','intersection','highway_merge','market','cattle_crossing'};
shortLabels={'Village','Intersection','Merge','Market','Cattle'};
titles={'Village road','Urban intersection','Highway merge','Market road','Cattle crossing'};
expected={'01_initial','02_cruising','03_interaction','04_risk','05_response','06_terminal'};
cattle={'01_initial','02_cattle_appears','03_critical_risk', ...
    '04_emergency_brake','05_replanning','06_terminal'};
screenCount=0;
for i=1:5
    mat=fullfile(root,'results','metrics',sprintf('vdb_synthetic_scenario_%d.mat',i));
    assert(isfile(mat),'Missing executed VDB MAT log: %s',mat);
    if i==5, recordingSlug='cattle'; else, recordingSlug=slugs{i}; end
    screen=fullfile(out,'screen_recordings', ...
        sprintf('SIH26037_VDB_3D_%s_screen_recording.mp4',recordingSlug));
    video=fullfile(out,'videos',sprintf('vdb_3d_%s_demo.mp4',slugs{i}));
    assert(isfile(screen) && isfile(video),'Missing scene %d video.',i);
    reader=VideoReader(screen);
    assert(hasFrame(reader),'Empty scene %d video.',i);
    frame=readFrame(reader);
    assert(size(frame,1)>=700 && size(frame,2)>=1200, ...
        'Scene %d video resolution too low.',i);
    if i==5
        shotDir=fullfile(out,'screenshots','3d_vdb'); names=cattle;
    else
        shotDir=fullfile(out,'screenshots','3d_vdb',slugs{i}); names=expected;
    end
    for j=1:6
        shot=fullfile(shotDir,[names{j} '.png']);
        assert(isfile(shot),'Missing scene %d screenshot: %s',i,shot);
        info=imfinfo(shot);
        assert(info.Width>=1200 && info.Height>=700, ...
            'Scene %d screenshot resolution too low.',i);
        screenCount=screenCount+1;
    end
end

figureFile=fullfile(out,'figures','vdb_3d_benchmark.png');
f=figure('Visible','off','Color','w','Position',[50 50 1500 850]);
layout=tiledlayout(f,2,2,'Padding','compact','TileSpacing','compact');
nexttile(layout); bar(t.minimumClearance); title('Minimum measured clearance');
ylabel('m'); xticks(1:5); xticklabels(shortLabels); grid on;
nexttile(layout); bar(t.meanReplanMs); title('Mean replanning latency');
ylabel('ms'); xticks(1:5); xticklabels(shortLabels); grid on;
nexttile(layout); bar(t.duration); title('Time to goal');
ylabel('s'); xticks(1:5); xticklabels(shortLabels); grid on;
nexttile(layout); bar(t.rmsJerk); title('RMS longitudinal jerk');
ylabel('m/s^3'); xticks(1:5); xticklabels(shortLabels); grid on;
title(layout,'Executed VDB synthetic-fusion benchmark (five goals, zero scored collisions)');
exportgraphics(f,figureFile,'Resolution',180); close(f);
assert(isfile(figureFile));

resultFile=fullfile(out,'VDB_3D_RESULTS.md');
fid=fopen(resultFile,'w'); assert(fid>0);
guard=onCleanup(@()fclose(fid));
fprintf(fid,'# Executed Vehicle Dynamics Blockset and 3D results\n\n');
fprintf(fid,'Source: [executed five-scene CSV](metrics/vdb_synthetic_benchmark.csv). ');
fprintf(fid,'All five canonical sensor-mode scenarios reached the goal without a scored collision. ');
fprintf(fid,'One deterministic seed per scenario was run with the VDB plant.\n\n');
fprintf(fid,'| Scenario | Result | Collisions | Duration (s) | Min clearance (m) | Mean / p95 planning (ms) | Emergency episodes |\n');
fprintf(fid,'|---|---|---:|---:|---:|---:|---:|\n');
for i=1:5
    fprintf(fid,'| %s | %s | %d | %.2f | %.2f | %.1f / %.1f | %d |\n', ...
        titles{i},char(string(t.outcome(i))),t.collisionCount(i), ...
        t.duration(i),t.minimumClearance(i),t.meanReplanMs(i), ...
        t.p95ReplanMs(i),t.emergencyInterventions(i));
end
fprintf(fid,'\nThe minimum TTC estimator reached zero in every scene. This is a conservative prediction-envelope result, not a measured collision; see geometric clearance and collision count above. ');
fprintf(fid,'VDB RMS jerk was %.1f to %.1f m/s^3, so longitudinal smoothness still needs improvement.\n\n', ...
    min(t.rmsJerk),max(t.rmsJerk));
fprintf(fid,'The VDB single-track block simulates planar longitudinal/lateral/yaw dynamics. ');
fprintf(fid,'The 3D MATLAB recordings are captured from the actual logged vehicle state and actor trajectories. ');
fprintf(fid,'The optional Unreal scene shows a 3D ego vehicle on a generic open surface; it is not a detailed Indian-road scene. ');
fprintf(fid,'No IDD-trained image perception or RoadRunner assets are claimed. ');
fprintf(fid,'No defensible numeric percentage of the SIH problem statement follows from these five deterministic tests.\n\n');
fprintf(fid,'See [the verified 3D evidence index](VDB_3D_EVIDENCE.md) for %d screenshots and five video recordings.\n',screenCount);
fprintf(fid,'[VDB benchmark chart](figures/vdb_3d_benchmark.png) plots the measured CSV values.\n');
clear guard;

index=fullfile(out,'VDB_3D_EVIDENCE.md');
fid=fopen(index,'w'); assert(fid>0);
guard=onCleanup(@()fclose(fid));
fprintf(fid,'# Verified VDB 3D evidence\n\n');
fprintf(fid,'These images and MP4s were generated from successful executed VDB Simulink runs. ');
fprintf(fid,'The MATLAB 3D view uses logged ego motion, scenario actor truth for visualization, and logged autonomy decisions. ');
fprintf(fid,'The sensor-mode planner does not consume the rendered view.\n\n');
fprintf(fid,'- [VDB benchmark chart](figures/vdb_3d_benchmark.png): measured clearance, latency, duration, and jerk from the executed CSV.\n\n');
for i=1:5
    fprintf(fid,'## %d. %s\n\n',i,titles{i});
    if i==5, relative='screenshots/3d_vdb/'; names=cattle;
    else, relative=['screenshots/3d_vdb/' slugs{i} '/']; names=expected; end
    for j=1:6
        fprintf(fid,'- [%s](%s%s.png): executed simulation frame.\n', ...
            strrep(names{j},'_',' '),relative,names{j});
    end
    if i==5, recordingSlug='cattle'; else, recordingSlug=slugs{i}; end
    fprintf(fid,'- [MATLAB screen recording](screen_recordings/SIH26037_VDB_3D_%s_screen_recording.mp4): actual `getframe` frames of the 3D simulation view.\n',recordingSlug);
    fprintf(fid,'- [presentation video](videos/vdb_3d_%s_demo.mp4): copy of the verified recording.\n\n',slugs{i});
end
modelShot=fullfile(out,'screenshots','simulink','vdb_closed_loop_full_model.png');
if isfile(modelShot)
    fprintf(fid,'## Simulink\n\n- [VDB closed-loop model](screenshots/simulink/vdb_closed_loop_full_model.png): actual generated Simulink model.\n\n');
end
unreal=fullfile(out,'screen_recordings','SIH26037_Unreal_VDB_camera.mp4');
if isfile(unreal)
    reader=VideoReader(unreal); assert(hasFrame(reader));
    fprintf(fid,'## Unreal camera preview\n\n');
    fprintf(fid,'- [Unreal camera recording](screen_recordings/SIH26037_Unreal_VDB_camera.mp4): frames returned by the actual Simulation 3D Camera block.\n');
    for j=1:2
        if j==1, name='01_unreal_camera_initial'; else, name='02_unreal_camera_final'; end
        file=fullfile(out,'screenshots','3d_unreal',[name '.png']);
        assert(isfile(file));
        fprintf(fid,'- [%s](screenshots/3d_unreal/%s.png): actual Unreal camera frame.\n',strrep(name,'_',' '),name);
    end
    wheelProbe=fullfile(out,'screenshots','3d_unreal','wheel_probe.png');
    if isfile(wheelProbe)
        fprintf(fid,'- [Wheel alignment probe](screenshots/3d_unreal/wheel_probe.png): actual 1 s Unreal camera smoke run used to verify the Sedan mesh pose.\n');
    end
    fprintf(fid,'\nThe generic Unreal open surface contains the ego vehicle only.\n');
end
clear guard;
report=struct('benchmark',csv,'results',resultFile,'evidence',index, ...
    'scenarioCount',height(t),'screenshotCount',screenCount,'screenRecordingCount',5);
fprintf('Verified %d VDB scenes, %d PNGs, five MP4 recordings.\n', ...
    report.scenarioCount,report.screenshotCount);
end
