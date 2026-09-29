function out=actorStates(sc,t)
% Deterministic event-driven truth, independent of perception mode.
out=repmat(struct('id',0,'type','','x',0,'y',0,'vx',0,'vy',0, ...
    'radius',0,'length',0,'width',0,'confidence',1,'cov',zeros(2)),0,1);
for k=1:numel(sc.actors)
    a=sc.actors(k);
    if t<a.birth, continue; end
    tau=t-a.birth; x=a.x0+a.vx*tau; y=a.y0+a.vy*tau;
    if strcmp(a.motion,'merge')
        y=max(-4,min(0,a.y0+a.vy*tau));
    elseif strcmp(a.motion,'cross')
        y=min(3,a.y0+a.vy*tau);
    end
    out(end+1)=struct('id',a.id,'type',a.type,'x',x,'y',y,'vx',a.vx, ...
        'vy',a.vy,'radius',a.radius,'length',a.length,'width',a.width, ...
        'confidence',1,'cov',zeros(2)); %#ok<AGROW>
end
end
