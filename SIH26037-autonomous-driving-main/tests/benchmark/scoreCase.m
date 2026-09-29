function [row,detail]=scoreCase(vdbEgo,vdbDecisions,sc,variation,manifest)
% Apply the frozen, strict gates to one actual VDB simulation.
row=emptyBenchmarkRow(variation,manifest);
detail=struct('excludedTTC',0,'validTTC',0,'replans',0, ...
    'cameraDropped',0,'radarDropped',0,'commandedJerk',nan, ...
    'evaluatedSamples',0,'roadDeparture',false);
t=vdbEgo.Time(:); e=vdbEgo.Data;
dt=vdbDecisions.Time(:); d=vdbDecisions.Data;
if isempty(t) || isempty(dt) || size(e,2)~=5 || size(d,2)<32 || ...
        size(e,1)~=numel(t) || size(d,1)~=numel(dt) || ...
        any(~isfinite(t)) || any(~isfinite(dt)) || ...
        any(diff(t)<=0) || any(diff(dt)<=0) || ...
        any(~isfinite(e(:,1:4)),'all')
    row.invalidReason='invalid ego/decision dimensions, values, or timestamps';
    return
end
if abs(e(1,2)-variation.actualEgoY)>1e-6
    row.invalidReason='ego lateral perturbation did not reach VDB plant';
    return
end
r=sih.vdbMetrics(vdbEgo,vdbDecisions,variation.scenarioId,sc);
finish=numel(r.time);
keep=dt<=r.time(end)+1e-8;
q=d(keep,:); qTime=dt(keep);
if isempty(q)
    row.invalidReason='no decision samples in scored trajectory'; return
end
row.rawOutcome=r.metrics.outcome;
row.collisionEpisodes=r.metrics.collisionCount;
row.completed=strcmp(r.metrics.outcome,'goal') && ...
    r.metrics.collisionCount==0;
detail.roadDeparture=strcmp(r.metrics.outcome,'road_departure');
detail.evaluatedSamples=finish;
rawTTC=q(:,6);
usable=isfinite(rawTTC) & rawTTC~=99;
detail.excludedTTC=sum(~usable);
detail.validTTC=sum(usable);
if any(usable), row.minimumTTC=min(rawTTC(usable)); end
lat=q(:,7);
if any(~isfinite(lat)) || any(lat<0)
    row.invalidReason='invalid replanning latency samples'; return
end
lat=lat(lat>0); detail.replans=numel(lat);
if ~isempty(lat)
    sorted=sort(lat);
    row.p95ReplanMs=sorted(ceil(0.95*numel(sorted)));
end
% Physical longitudinal jerk: interval acceleration from signed VDB
% longitudinal speed, then acceleration difference over midpoint times.
% Endpoints have no second derivative and are omitted; no peak filtering.
speed=e(1:finish,4); time=t(1:finish);
if numel(time)>=3
    acc=diff(speed)./diff(time);
    midpoint=(time(1:end-1)+time(2:end))/2;
    jerk=diff(acc)./diff(midpoint);
    if all(isfinite(jerk)) && ~isempty(jerk)
        row.maxAbsPhysicalJerk=max(abs(jerk));
    end
end
% Diagnostic only, never used as the primary jerk gate.
if numel(qTime)>=2
    commandedAcc=sum(q(:,2:3),2)/2000;
    cj=diff(commandedAcc)./diff(qTime);
    if all(isfinite(cj)), detail.commandedJerk=max(abs(cj)); end
end
detail.cameraDropped=q(end,31);
detail.radarDropped=q(end,32);
if ~all(isfinite([detail.cameraDropped,detail.radarDropped])) || ...
        any([detail.cameraDropped,detail.radarDropped]<0)
    row.invalidReason='invalid sensor dropout counters'; return
end
if strcmp(variation.kind,'camera_dropout') && detail.cameraDropped<1
    row.invalidReason='camera dropout case observed no dropped detections'; return
end
if strcmp(variation.kind,'radar_dropout') && detail.radarDropped<1
    row.invalidReason='radar dropout case observed no dropped detections'; return
end
if detail.validTTC==0
    row.invalidReason='no usable predicted TTC samples'; return
end
if detail.replans==0
    row.invalidReason='no real replan latency samples'; return
end
if ~isfinite(row.maxAbsPhysicalJerk)
    row.invalidReason='physical longitudinal jerk cannot be estimated'; return
end
row.valid=true; row.invalidReason='';
row.collisionPASS=row.collisionEpisodes==0;
row.ttcPASS=row.minimumTTC>manifest.thresholds.minimumTTCSeconds;
row.completionPASS=row.completed && ~detail.roadDeparture;
row.latencyPASS=row.p95ReplanMs<manifest.thresholds.p95ReplanMs;
row.jerkPASS=row.maxAbsPhysicalJerk<manifest.thresholds.maxAbsPhysicalJerk;
row.Overall_PASS=all([row.collisionPASS,row.ttcPASS, ...
    row.completionPASS,row.latencyPASS,row.jerkPASS]);
if row.Overall_PASS, row.status='PASS'; else, row.status='FAIL'; end
end
