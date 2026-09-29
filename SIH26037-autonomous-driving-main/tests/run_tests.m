root=fileparts(fileparts(mfilename('fullpath'))); addpath(root); setup_project;
if ~exist(fullfile(root,'results','logs'),'dir')
    mkdir(fullfile(root,'results','logs'));
end
diary(fullfile(root,'results','logs','tests.txt'));
c=sih.config('fast','truth');
assert(c.dt>0 && c.planPeriod>=c.dt && c.predHorizon>c.planPeriod);
assert(c.maxSteer>0 && c.maxSpeed>0 && c.safetyBuffer>0);
fprintf('Configuration: PASS\n');

ego=[2 3 pi/2 1]; p=sih.egoToWorld(ego,[1 0]);
assert(norm(p-[2 4])<1e-10); fprintf('Coordinate transform: PASS\n');

sc=sih.makeScenario(1,c); a=sih.actorStates(sc,0); assert(numel(a)==2);
assert(getOccupancy(sc.freeSpace,[10 sc.roadHalfWidth+1])>0.5);
assert(getOccupancy(sc.freeSpace,[10 0])<0.5);
pred=sih.predictActors(a,c);
assert(abs(pred.actors(2).x(end)-(a(2).x+a(2).vx*c.predHorizon))<1e-9);
assert(pred.actors(2).radius(end)>pred.actors(2).radius(1));
fprintf('Prediction and uncertainty: PASS\n');

near=a(1); near.x=5; near.y=0; near.vx=0; near.vy=0;
rp=sih.predictActors(near,c); risk=sih.assessRisk([0 0 0 5],rp,c);
assert(isfinite(risk.ttc) && ~strcmp(risk.level,'LOW'));
b=sih.behavior([0 0 0 5],risk,sc,c);
assert(any(strcmp(b.state,{'CAUTION','YIELD','EMERGENCY_BRAKE'})));
fprintf('TTC, risk, behavior: PASS\n');

emptyPred=sih.predictActors([],c);
[plan,info]=sih.planTrajectory([0 0 0 0],emptyPred, ...
    sih.behavior([0 0 0 0],sih.assessRisk([0 0 0 0],emptyPred,c),sc,c),sc,c);
assert(~info.fallback && all(isfinite(plan.x)) && all(isfinite(plan.y)));
[safe,~]=sih.checkTrajectory(plan,emptyPred,sc,c); assert(safe);
collisionPath=struct('t',rp.times(:),'x',5+zeros(numel(rp.times),1), ...
    'y',zeros(numel(rp.times),1));
[safe,~]=sih.checkTrajectory(collisionPath,rp,sc,c); assert(~safe);
fprintf('Planner and dynamic collision check: PASS\n');

[steer,accel]=sih.control([0 0 0 3],plan, ...
    struct('emergency',false,'state','CRUISE','remaining',50),c,0);
assert(abs(steer)<=c.maxSteer && accel<=c.maxAccel && accel>=-c.comfortDecel);
[steerEdge,accelEdge]=sih.control([10 4.55 0.2 8],plan, ...
    struct('emergency',false,'state','CRUISE','remaining',50, ...
    'roadHalfWidth',5.5),c,0);
assert(abs(steerEdge)<=c.maxSteer && accelEdge>=-c.emergencyDecel);
fprintf('Controller limits: PASS\n');

for id=1:5
    s=sih.makeScenario(id,c);
    assert(~isempty(s.name) && ~isempty(s.actors) && s.goalX>0);
end
fprintf('Five scenario constructors: PASS\n');

inventory=sih.iddInventory(fullfile(root,'data','idd'),10);
assert(height(inventory)==0);
fprintf('IDD inventory empty-data fallback: PASS\n');

r=sih.simulate(1,c);
assert(isempty(r.failures) && r.metrics.success && r.metrics.collisionCount==0);
assert(r.metrics.replans>1 && r.metrics.pathLength>10);
assert(isfinite(r.metrics.meanReplanMs));
fprintf('End-to-end truth smoke and metrics: PASS (x=%.2f, t=%.1f)\n', ...
    r.metrics.finalX,r.metrics.duration);
diary off;
