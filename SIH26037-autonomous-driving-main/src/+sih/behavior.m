function b=behavior(ego,risk,sc,c)
b=struct('state','CRUISE','speed',c.maxSpeed,'emergency',false, ...
    'remaining',sc.goalX-ego(1),'roadHalfWidth',sc.roadHalfWidth);
if sc.id==4, b.speed=5; end
if risk.ttc<c.minTTC && risk.separation<0 && ego(4)>1 && ...
        (risk.ttc<0.5 || risk.confidence<0.7)
    b.state='EMERGENCY_BRAKE'; b.speed=0; b.emergency=true;
elseif strcmp(risk.level,'CRITICAL')
    b.state='YIELD'; b.speed=min(b.speed,1);
elseif strcmp(risk.level,'HIGH')
    b.state='YIELD'; b.speed=min(b.speed,3);
elseif strcmp(risk.level,'CAUTION')
    b.state='CAUTION'; b.speed=min(b.speed,5);
end
if sc.goalX-ego(1)<25
    b.state='STOP';
    remaining=max(0,sc.goalX-ego(1)-0.5);
    b.speed=min(b.speed,0.45*remaining);
end
end
