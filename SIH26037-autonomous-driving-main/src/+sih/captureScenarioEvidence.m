function record=captureScenarioEvidence(r,outputRoot,c)
% Screenshots and MP4 are rendered exclusively from an executed successful log.
assert(r.metrics.success && r.metrics.collisionCount==0, ...
    'Only successful, collision-free runs can be indexed as success evidence.');
slugs={'01_village','02_intersection','03_highway_merge', ...
    '04_market','05_cattle_crossing'};
videoNames={'village_demo.mp4','intersection_demo.mp4', ...
    'highway_merge_demo.mp4','market_demo.mp4','cattle_crossing_demo.mp4'};
slug=slugs{r.id}; events=sih.selectEvidenceEvents(r);
folder=fullfile(outputRoot,'screenshots',slug);
if ~exist(folder,'dir'), mkdir(folder); end
f=figure('Visible','off','Color','w','Position',[40 40 1600 900]);
cleanFigure=onCleanup(@()close(f));
rows=cell(numel(events),1);
for j=1:numel(events)
    e=events(j);
    name=sprintf('%02d_%s.png',j,e.name);
    file=fullfile(folder,name);
    sih.renderEvidenceFrame(r,e.index,e.name,file,c,f,150);
    rows{j}=struct('scenario',r.id,'event',e.name,'frame',e.index, ...
        'time',r.log.time(e.index),'behavior',r.log.behavior{e.index}, ...
        'ttc',r.log.ttc(e.index),'speed',r.log.ego(e.index,4), ...
        'clearance',r.log.clearance(e.index));
    assert(isfile(file),'Screenshot export failed: %s',file);
end
clear cleanFigure;
eventTable=struct2table([rows{:}]);
metricsDir=fullfile(outputRoot,'metrics');
if ~exist(metricsDir,'dir'), mkdir(metricsDir); end
eventFile=fullfile(outputRoot,'metrics',[slug '_events.csv']);
writetable(eventTable,eventFile);
for item={'prediction','planning'}
    targetDir=fullfile(outputRoot,'screenshots',item{1});
    if ~exist(targetDir,'dir'), mkdir(targetDir); end
    number=find(strcmp({events.name},item{1}),1);
    source=fullfile(folder,sprintf('%02d_%s.png',number,item{1}));
    copyfile(source,fullfile(targetDir,[slug '.png']));
end
sensorFrames=find(cellfun(@(s)isfield(s,'lidar') && s.lidar>0, ...
    r.log.sensors) & cellfun(@(a)~isempty(a),r.log.tracks));
if ~isempty(sensorFrames)
    sensorDir=fullfile(outputRoot,'screenshots','sensors');
    if ~exist(sensorDir,'dir'), mkdir(sensorDir); end
    [~,k]=min(abs(sensorFrames-events(3).index));
    sih.renderEvidenceFrame(r,sensorFrames(k),'sensor_fusion', ...
        fullfile(sensorDir,[slug '.png']),c,[],150);
end
videoDir=fullfile(outputRoot,'videos');
if ~exist(videoDir,'dir'), mkdir(videoDir); end
videoFile=fullfile(videoDir,videoNames{r.id});
sih.exportEvidenceVideo(r,videoFile,c,events);
assert(isfile(videoFile),'Video export failed: %s',videoFile);
record=struct('slug',slug,'events',events,'video',videoFile, ...
    'eventFile',eventFile);
end
