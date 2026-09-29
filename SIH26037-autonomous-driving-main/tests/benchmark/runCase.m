function [row,detail,vdbEgo,vdbDecisions]=runCase(variation,manifest,modelPath)
% One real synthetic-fusion case through the VDB Simulink plant.
c=sih.config('fast','synthetic_fusion');
sc=sih.makeScenario(variation.scenarioId,c,variation);
assert(sc.seed==variation.seed && sc.ego(2)==variation.actualEgoY);
if ismember(variation.kind,{'actor_speed','actor_birth'})
    a=sc.actors(variation.actorIndex);
    assert(a.id==variation.actorId && a.vx==variation.actualVx && ...
        a.vy==variation.actualVy && a.birth==variation.actualBirth, ...
        'Scene perturbation mismatch');
end
[~,model]=fileparts(modelPath);
load_system(modelPath);
set_param([model '/Scenario ID'],'Value',num2str(variation.scenarioId));
set_param([model '/Sensor mode'],'Value','1');
set_param([model '/Benchmark case index'],'Value',num2str(variation.index));
set_param([model '/Goal X'],'Value',num2str(sc.goalX,17));
set_param([model '/World Y left'],'InitialCondition', ...
    num2str(variation.actualEgoY,17));
clear sih.vdbAutonomy
simout=sim(model,'StopTime',num2str(sc.timeout,17));
vdbEgo=simout.get('vdbEgo');
vdbDecisions=simout.get('vdbDecisions');
[row,detail]=scoreCase(vdbEgo,vdbDecisions,sc,variation,manifest);
end
