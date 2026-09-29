function out=vdbAutonomy(u)
% Sampled closed-loop autonomy for a Vehicle Body 3DOF Simulink plant.
% Input: [time, SIH x, SIH y, SAE yaw, SAE longitudinal speed, scene, mode].
% Output: force/steering and recorded decision diagnostics.
persistent c sc tracks suite plan b lastPlan lastStep lastOut lastCase
u=u(:); t=u(1); id=round(u(6)); sensorMode=round(u(7));
caseIndex=0;
if numel(u)>=8, caseIndex=round(u(8)); end
reset=isempty(lastStep) || t<lastStep-1e-8 || ...
    (t==0 && lastStep>0) || isempty(sc) || sc.id~=id || ...
    isempty(lastCase) || lastCase~=caseIndex;
if reset
    if sensorMode==1, mode='synthetic_fusion'; else, mode='truth'; end
    c=sih.config('fast',mode);
    variation=[];
    if caseIndex>0
        variation=sih.benchmarkCase(caseIndex);
        assert(variation.scenarioId==id,'Benchmark case/scenario mismatch');
    end
    sc=sih.makeScenario(id,c,variation);
    rng(sc.seed); tracks=[]; plan=[]; lastPlan=-inf; lastStep=-c.dt;
    if caseIndex>0, lastOut=zeros(32,1);
    else, lastOut=zeros(30,1); end
    b=struct('state','CRUISE','speed',c.maxSpeed, ...
        'emergency',false,'remaining',sc.goalX);
    if sensorMode==1, suite=sih.SensorSuite(sc,c,variation); else, suite=[]; end
    lastCase=caseIndex;
end
if t<=lastStep+0.5*c.dt
    out=lastOut; return;
end
ego=[u(2),u(3),-u(4),max(0,u(5))];
truth=sih.actorStates(sc,t);
[tracks,sensor]=sih.observe(truth,ego,t,c,tracks,suite);
pred=sih.predictActors(tracks,c);
risk=sih.assessRisk(ego,pred,c);
latencyMs=0;
if t-lastPlan>=c.planPeriod-1e-8 || isempty(plan)
    started=tic;
    b=sih.behavior(ego,risk,sc,c);
    try
        [plan,~]=sih.planTrajectory(ego,pred,b,sc,c,plan);
    catch ME
        warning('SIH:VDBPlanner','t=%.2f %s',t,ME.message);
        plan=sih.safeStop(ego,c);
        b.state='EMERGENCY_BRAKE'; b.speed=0; b.emergency=true;
    end
    latencyMs=toc(started)*1000;
    lastPlan=t;
end
currentB=b;
if risk.ttc<c.minTTC && risk.separation<0 && ego(4)>1 && ...
        (risk.ttc<0.5 || risk.confidence<0.7)
    currentB.state='EMERGENCY_BRAKE'; currentB.speed=0;
    currentB.emergency=true;
end
[steer,accel]=sih.control(ego,plan,currentB,c,t-lastPlan);
if ego(4)<0.12 && accel<0, accel=0; end
force=2000*accel; % Match the Vehicle Body 3DOF block mass in the builder.
codes={'CRUISE','FOLLOW','YIELD','CAUTION','STOP', ...
    'PASS_OBSTACLE','MERGE','EMERGENCY_BRAKE'};
behaviorCode=find(strcmp(codes,currentB.state),1);
if isempty(behaviorCode), behaviorCode=0; end
riskCodes={'LOW','CAUTION','HIGH','CRITICAL'};
riskCode=find(strcmp(riskCodes,risk.level),1);
if isempty(riskCode), riskCode=0; end
out=zeros(numel(lastOut),1);
loggedTTC=risk.ttc;
if ~isfinite(loggedTTC), loggedTTC=99; end % Logged sentinel for undefined TTC.
out(1:10)=[-steer;force/2;force/2;behaviorCode;riskCode; ...
    loggedTTC;latencyMs;plan.x(end);plan.y(end);numel(tracks)];
for k=1:min(4,numel(tracks))
    offset=10+4*(k-1);
    out(offset+(1:4))=[tracks(k).x;tracks(k).y;tracks(k).vx;tracks(k).vy];
end
if isfield(sensor,'camera')
    out(27:29)=[sensor.camera;sensor.radar;sensor.lidar];
end
if caseIndex>0 && ~isempty(suite)
    out(31:32)=[suite.cameraDropped;suite.radarDropped];
end
out(30)=any(arrayfun(@(a)hypot(ego(1)-a.x,ego(2)-a.y) ...
    <c.egoWidth/2+a.radius,truth));
lastOut=out; lastStep=t;
end
