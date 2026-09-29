function result=simulate(id,c)
if nargin<2, c=sih.config; end
sc=sih.makeScenario(id,c); rng(sc.seed);
if strcmp(c.perceptionMode,'synthetic_fusion')
    sc.timeout=max(sc.timeout,65); % noisy perception requires cautious progress
end
ego=sc.ego; N=ceil(sc.timeout/c.dt)+1;
states=zeros(N,4); commands=zeros(N,2); clock=zeros(N,1);
latency=zeros(N,1); clearances=nan(N,1); ttcs=nan(N,1);
behaviors=cell(N,1); paths=cell(N,1); actorsLog=cell(N,1); tracksLog=cell(N,1);
plannerInfoLog=cell(N,1);
riskLevels=cell(N,1);
collision=0; outcome='timeout'; lastPlan=-inf;
plan=[]; b=struct('state','CRUISE','speed',c.maxSpeed,'emergency',false);
tracks=[]; sensorLog=cell(N,1); failures=cell(0,1);
if strcmp(c.perceptionMode,'synthetic_fusion'), suite=sih.SensorSuite(sc,c);
else, suite=[]; end
for i=1:N
    t=(i-1)*c.dt; truth=sih.actorStates(sc,t);
    [tracks,sensorLog{i}]=sih.observe(truth,ego,t,c,tracks,suite);
    planningTracks=tracks;
    pred=sih.predictActors(planningTracks,c);
    riskPred=sih.predictActors(tracks,c);
    risk=sih.assessRisk(ego,riskPred,c);
    if t-lastPlan>=c.planPeriod-1e-8 || isempty(plan)
        ticHandle=tic;
        b=sih.behavior(ego,risk,sc,c);
        try
            [plan,planInfo]=sih.planTrajectory(ego,pred,b,sc,c,plan);
        catch ME
            failures{end+1}=sprintf('t=%.2f %s',t,getReport(ME,'basic')); %#ok<AGROW>
            plan=sih.safeStop(ego,c); b.state='EMERGENCY_BRAKE';
            b.speed=0; b.emergency=true; planInfo.fallback=true;
        end
        latency(i)=toc(ticHandle)*1000;
        plannerInfoLog{i}=planInfo;
        lastPlan=t;
    end
    currentB=b;
    % Emergency authority runs at plant rate, independent of 0.5 s replans.
    if risk.ttc<c.minTTC && risk.separation<0 && ego(4)>1 && ...
            (risk.ttc<0.5 || risk.confidence<0.7)
        currentB.state='EMERGENCY_BRAKE';
        currentB.speed=0; currentB.emergency=true;
    end
    [steer,accel]=sih.control(ego,plan,currentB,c,t-lastPlan);
    states(i,:)=ego; commands(i,:)=[steer accel]; clock(i)=t;
    behaviors{i}=currentB.state; paths{i}=plan;
    riskLevels{i}=risk.level;
    actorsLog{i}=truth; tracksLog{i}=tracks;
    ttcs(i)=risk.ttc;
    minClear=inf;
    for k=1:numel(truth)
        d=hypot(ego(1)-truth(k).x,ego(2)-truth(k).y) ...
            -(c.egoWidth/2+truth(k).radius);
        minClear=min(minClear,d);
        if d<0, collision=collision+1; end
    end
    clearances(i)=minClear;
    if collision>0, outcome='collision'; break; end
    if abs(ego(2))>sc.roadHalfWidth-c.egoWidth/2
        outcome='road_departure'; break;
    end
    if ego(1)>=sc.goalX-1 && ego(4)<1.5
        outcome='goal'; break;
    end
    ego=sih.stepVehicle(ego,steer,accel,c);
end
ix=1:i;
emergencyFlags=commands(ix,2)<=-c.emergencyDecel+1e-6;
emergencies=sum(diff([false;emergencyFlags])==1);
log=struct('time',clock(ix),'ego',states(ix,:),'control',commands(ix,:), ...
    'latencyMs',latency(ix),'clearance',clearances(ix), ...
    'ttc',ttcs(ix),'behavior',{behaviors(ix)},'risk',{riskLevels(ix)}, ...
    'paths',{paths(ix)}, ...
    'actors',{actorsLog(ix)},'tracks',{tracksLog(ix)}, ...
    'plannerInfo',{plannerInfoLog(ix)}, ...
    'sensors',{sensorLog(ix)});
metrics=sih.metrics(log,sc,outcome,collision,emergencies);
result=struct('id',id,'name',sc.name,'outcome',outcome,'metrics',metrics, ...
    'log',log,'failures',{failures},'goalX',sc.goalX,'roadHalfWidth',sc.roadHalfWidth);
end
