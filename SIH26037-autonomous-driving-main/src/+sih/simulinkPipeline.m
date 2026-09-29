function out=simulinkPipeline(t)
% One fixed-step closed-loop execution for the Simulink integration model.
% Complex subsystems use the same tested package functions as MATLAB runs.
persistent c sc ego plan b lastPlan lastStep
if isempty(lastStep) || t<lastStep-1e-6 || t==0 && lastStep>0
    c=sih.config('fast','truth'); sc=sih.makeScenario(1,c);
    ego=sc.ego; plan=[]; lastPlan=-inf; lastStep=-c.dt;
    b=struct('state','CRUISE','speed',c.maxSpeed,'emergency',false, ...
        'remaining',sc.goalX);
end
if t>lastStep+0.5*c.dt
    truth=sih.actorStates(sc,t);
    pred=sih.predictActors(truth,c);
    risk=sih.assessRisk(ego,pred,c);
    if t-lastPlan>=c.planPeriod-1e-8 || isempty(plan)
        b=sih.behavior(ego,risk,sc,c);
        try
            [plan,~]=sih.planTrajectory(ego,pred,b,sc,c,plan);
        catch ME
            warning('SIH:SimulinkPlanner','Planner failed at t=%.2f: %s',t,ME.message);
            plan=sih.safeStop(ego,c); b.emergency=true;
            b.state='EMERGENCY_BRAKE';
        end
        lastPlan=t;
    end
    currentB=b;
    if risk.ttc<c.minTTC && risk.separation<0 && ego(4)>1 && ...
            (risk.ttc<0.5 || risk.confidence<0.7)
        currentB.state='EMERGENCY_BRAKE';
        currentB.speed=0; currentB.emergency=true;
    end
    [steer,accel]=sih.control(ego,plan,currentB,c,t-lastPlan);
    collision=0;
    for k=1:numel(truth)
        if hypot(ego(1)-truth(k).x,ego(2)-truth(k).y) ...
                <c.egoWidth/2+truth(k).radius
            collision=1;
        end
    end
    codes={'CRUISE','CAUTION','YIELD','STOP','EMERGENCY_BRAKE'};
    behaviorCode=find(strcmp(codes,currentB.state),1);
    riskCodes={'LOW','CAUTION','HIGH','CRITICAL'};
    riskCode=find(strcmp(riskCodes,risk.level),1);
    out=[ego(:);steer;accel;riskCode;behaviorCode;collision;plan.targetOffset];
    if ego(1)<sc.goalX-1 || ego(4)>1.5
        ego=sih.stepVehicle(ego,steer,accel,c);
    end
    lastStep=t;
else
    out=[ego(:);0;0;1;1;0;0];
end
end
