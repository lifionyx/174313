function files=recordVdb3D(r,outputRoot)
% Actual MATLAB figure screen capture of the executed VDB run via getframe.
assert(r.metrics.success && r.metrics.collisionCount==0, ...
    'The VDB run must pass before a successful demo is recorded.');
folder=fullfile(outputRoot,'screen_recordings');
slugs={'village','intersection','highway_merge','market','cattle_crossing'};
slug=slugs{r.id};
if r.id==5, shots=fullfile(outputRoot,'screenshots','3d_vdb');
else, shots=fullfile(outputRoot,'screenshots','3d_vdb',slug); end
videos=fullfile(outputRoot,'videos');
for path={folder,shots,videos}
    if ~exist(path{1},'dir'), mkdir(path{1}); end
end
if r.id==5, base='SIH26037_VDB_3D_cattle_screen_recording.mp4';
else, base=['SIH26037_VDB_3D_' slug '_screen_recording.mp4']; end
file=fullfile(folder,base);
writer=VideoWriter(file,'MPEG-4'); writer.FrameRate=8; open(writer);
fig=figure('Visible','on','Color','w','Position',[60 60 1280 720]);
cleanup=onCleanup(@()closeResources(writer,fig));

t=r.decisionTime; d=r.decisions;
if r.id==5
    critical=find(t>=5 & d(:,5)==4,1);
    braking=find(t>=5 & d(:,4)==8,1);
    if isempty(critical), critical=find(t>=5,1); end
    if isempty(braking), braking=critical; end
    events=[0 5 t(critical) t(braking) min(8,r.time(end)) r.time(end)];
    names={'01_initial','02_cattle_appears','03_critical_risk', ...
        '04_emergency_brake','05_replanning','06_terminal'};
else
    [~,interaction]=min(r.clearance);
    critical=find(d(:,5)>=3,1); if isempty(critical), critical=1; end
    braking=find(d(:,4)==8,1); if isempty(braking), braking=critical; end
    events=[0 r.time(max(1,round(0.2*numel(r.time)))) ...
        r.time(interaction) t(critical) t(braking) r.time(end)];
    names={'01_initial','02_cruising','03_interaction', ...
        '04_risk','05_response','06_terminal'};
end
eventIndex=zeros(numel(events),1);
for j=1:numel(events)
    [~,eventIndex(j)]=min(abs(r.time-events(j)));
    sih.renderVdb3DFrame(r,eventIndex(j), ...
        fullfile(shots,[names{j} '.png']),fig,160);
end

step=max(1,round(0.45/median(diff(r.time))));
frames=unique([1:step:numel(r.time),eventIndex',numel(r.time)]);
for k=1:numel(frames)
    sih.renderVdb3DFrame(r,frames(k),'',fig);
    drawnow;
    frame=getframe(fig);
    writeVideo(writer,imresize(frame.cdata,[720 1280]));
end
clear cleanup;
copy=fullfile(videos,['vdb_3d_' slug '_demo.mp4']);
copyfile(file,copy);
assert(isfile(file) && isfile(copy));
files=struct('screenRecording',file,'video',copy, ...
    'screenshots',{cellstr(fullfile(shots,string(names)+'.png'))});
fprintf('Captured %d actual MATLAB figure frames to %s\n', ...
    numel(frames),file);
end

function closeResources(writer,fig)
try, close(writer); catch, end
if isgraphics(fig), close(fig); end
end
