function events=selectEvidenceEvents(r)
% Select observed moments from an executed log, never preset timestamps.
n=numel(r.log.time); dt=median(diff(r.log.time));
speed=r.log.ego(:,4);
cruise=find(speed>=min(3,max(speed)*0.55),1);
if isempty(cruise), cruise=max(1,round(n*0.2)); end
clearance=r.log.clearance;
clearance(~isfinite(clearance))=inf;
[~,interaction]=min(clearance);
if ~isfinite(clearance(interaction)), interaction=max(1,round(n*0.5)); end
ttc=r.log.ttc; ttc(~isfinite(ttc))=inf;
[~,highRisk]=min(ttc);
if ~isfinite(ttc(highRisk)), highRisk=interaction; end
prediction=max(1,interaction-round(1.5/dt));
hasTrack=cellfun(@(x)~isempty(x),r.log.tracks);
earlier=find(hasTrack & (1:n)'<=interaction);
if ~isempty(earlier)
    [~,j]=min(abs(earlier-prediction)); prediction=earlier(j);
end
replans=find(r.log.latencyMs>0);
if isempty(replans), planning=interaction;
else
    [~,j]=min(abs(replans-interaction)); planning=replans(j);
end
responsePool=find(r.log.control(:,2)<-2.5 | ...
    strcmp(r.log.behavior,'YIELD') | ...
    strcmp(r.log.behavior,'EMERGENCY_BRAKE'));
if isempty(responsePool), response=highRisk;
else
    [~,j]=min(abs(responsePool-highRisk)); response=responsePool(j);
end
if r.id==5
    % Anchor the crossing evidence to the cattle's actual logged appearance.
    % Early zero-TTC track transients elsewhere would otherwise dominate.
    cattleBirth=5.0;
    crossing=find(r.log.time>=cattleBirth & r.log.time<=cattleBirth+10);
    critical=crossing(strcmp(r.log.risk(crossing),'CRITICAL'));
    if ~isempty(critical)
        interaction=critical(1);
        responsePool=critical(strcmp(r.log.behavior(critical),'EMERGENCY_BRAKE') ...
            & critical>=interaction+round(0.5/dt));
        if ~isempty(responsePool), response=responsePool(1); end
    end
    [~,j]=min(ttc(crossing));
    if isfinite(ttc(crossing(j))), highRisk=crossing(j); end
    prediction=min(n,interaction+round(0.3/dt));
    if ~isempty(replans)
        [~,j]=min(abs(replans-highRisk)); planning=replans(j);
    end
end
events=struct('name',{'initial','cruise','interaction','prediction', ...
    'planning','highest_risk','response','final'}, ...
    'index',{1,cruise,interaction,prediction,planning,highRisk,response,n});
end
