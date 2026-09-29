function pred=predictActors(tracks,c)
% Constant-velocity trajectories with class-dependent uncertainty growth.
times=0:c.predDt:c.predHorizon;
pred=struct('times',times,'actors',[]);
actors=repmat(struct('id',0,'type','','x',[],'y',[],'radius',[], ...
    'confidence',0),0,1);
for k=1:numel(tracks)
    a=tracks(k); growth=0.18;
    if any(strcmp(a.type,{'pedestrian','two_wheeler','cattle'})), growth=0.35; end
    if strcmp(a.type,'unknown')
        if a.confidence>=0.8, growth=0.15; else, growth=0.4; end
    end
    sigma=sqrt(max(0,trace(a.cov)))/2;
    actors(end+1)=struct('id',a.id,'type',a.type, ...
        'x',a.x+a.vx*times,'y',a.y+a.vy*times, ...
        'radius',a.radius+c.safetyBuffer+sigma+growth*times, ...
        'confidence',a.confidence); %#ok<AGROW>
end
pred.actors=actors;
end
