function risk=assessRisk(ego,pred,c)
% Straight-ahead TTC is a behavior trigger; planner checks full candidates.
risk=struct('level','LOW','ttc',inf,'separation',inf, ...
    'actorId',0,'confidence',1);
for k=1:numel(pred.actors)
    a=pred.actors(k);
    for j=1:numel(pred.times)
        t=pred.times(j); ex=ego(1)+ego(4)*cos(ego(3))*t;
        ey=ego(2)+ego(4)*sin(ego(3))*t;
        sep=hypot(ex-a.x(j),ey-a.y(j))-a.radius(j)-1.1;
        risk.separation=min(risk.separation,sep);
        if sep<0 && t<risk.ttc
            risk.ttc=t; risk.actorId=a.id; risk.confidence=a.confidence;
        end
    end
end
if risk.ttc<c.minTTC, risk.level='CRITICAL';
elseif risk.ttc<2.2, risk.level='HIGH';
elseif risk.ttc<4, risk.level='CAUTION'; end
end
