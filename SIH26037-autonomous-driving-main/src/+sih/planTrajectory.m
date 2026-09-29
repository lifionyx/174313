function [best,info]=planTrajectory(ego,pred,b,sc,c,previous)
% Receding-horizon trajectory lattice. Quintic lateral shifts, bounded
% longitudinal acceleration, time-indexed collision rejection.
t=(0:c.predDt:c.predHorizon)';
if nargin<6 || isempty(previous), previousOffset=0;
else, previousOffset=previous.targetOffset; end
offsets=[-4 -3.4 -2.5 -1.5 0 1.5 2.5 3.4 4];
referenceY=interp1(sc.referencePath(:,1),sc.referencePath(:,2), ...
    min(sc.length,max(0,ego(1))),'linear','extrap');
offsets=offsets+referenceY;
speeds=unique(max(0,[b.speed b.speed-2 b.speed-4 4 3 2 1 0]));
speeds=speeds(speeds<=b.speed+1e-9);
best=[]; bestCost=inf;
candidateTemplate=struct('x',[],'y',[],'targetOffset',0, ...
    'targetSpeed',0,'accepted',false);
info=struct('safeCount',0,'clearance',-inf);
info.candidates=repmat(candidateTemplate,0,1);
for target=offsets
    for speed=speeds
        a=max(-c.comfortDecel,min(c.maxAccel,(speed-ego(4))/2));
        v=max(0,min(c.maxSpeed,ego(4)+a*t));
        x=ego(1)+cumtrapz(t,v*cos(ego(3)));
        T=2.2; u=min(1,t/T);
        q=10*u.^3-15*u.^4+6*u.^5;
        y0=ego(2)+ego(4)*sin(ego(3))*t.*exp(-t/0.7);
        y=y0+(target-ego(2))*q;
        tr=struct('t',t,'x',x,'y',y,'v',v,'targetSpeed',speed, ...
            'targetOffset',target,'accel',a);
        preview=abs(speed-speeds(end))<1e-9;
        if preview
            candidate=struct('x',x,'y',y,'targetOffset',target, ...
                'targetSpeed',speed,'accepted',false);
        end
        [safe,clearance]=sih.checkTrajectory(tr,pred,sc,c);
        if ~safe
            if preview, info.candidates(end+1)=candidate; end %#ok<AGROW>
            continue;
        end
        info.safeCount=info.safeCount+1;
        dy=gradient(y,c.predDt); ddy=gradient(dy,c.predDt);
        curvature=ddy./max(v.^2,4);
        % Near standstill curvature from a time-parametric shift is poorly
        % conditioned; the bicycle controller still limits actual steering.
        if max(abs(ddy))>6 || any(abs(curvature(v>2))>0.6)
            if preview, info.candidates(end+1)=candidate; end %#ok<AGROW>
            continue;
        end
        if preview
            candidate.accepted=true;
            info.candidates(end+1)=candidate; %#ok<AGROW>
        end
        cost=-c.weights.progress*(x(end)-ego(1)) ...
            +c.weights.offset*sum(y.^2)*c.predDt ...
            +c.weights.speed*(b.speed-speed)^2 ...
            +c.weights.clearance/(max(clearance,0)+0.3) ...
            +c.weights.smooth*sum(diff(curvature).^2) ...
            +c.weights.accel*a^2;
        if abs(ego(2))>0.3
            cost=cost+0.15*(target-previousOffset)^2;
        end
        for m=1:numel(pred.actors)
            obstacle=pred.actors(m);
            if obstacle.x(1)>ego(1)-2 && obstacle.x(1)<ego(1)+25
                gap=abs(target-obstacle.y(1));
                cost=cost+5*max(0,4-gap)^2;
            end
        end
        if cost<bestCost, bestCost=cost; best=tr; info.clearance=clearance; end
    end
end
if isempty(best)
    % Safe fallback trajectory is a stationary target; controller brakes.
    best=struct('t',t,'x',ego(1)+zeros(size(t)), ...
        'y',ego(2)+zeros(size(t)),'v',zeros(size(t)), ...
        'targetSpeed',0,'targetOffset',ego(2),'accel',-c.emergencyDecel);
    info.fallback=true;
else
    info.fallback=false;
end
end
