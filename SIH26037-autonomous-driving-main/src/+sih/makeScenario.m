function sc = makeScenario(id,c,variation)
% World frame: +x road progress, +y left, yaw counterclockwise.
if nargin<2, c=sih.config; end
assert(isscalar(id) && id==fix(id) && id>=1 && id<=5,'Scenario ID must be 1..5');
sc.id=id; sc.length=85; sc.goalX=79; sc.timeout=45; sc.roadHalfWidth=6;
sc.ego=[0 0 0 0]; sc.passMode='goal';
blank=struct('id',0,'type','','x0',0,'y0',0,'vx',0,'vy',0, ...
    'birth',0,'radius',0,'length',0,'width',0,'motion','linear');
a=repmat(blank,0,1);
switch id
    case 1
        sc.name='Unmarked village road'; sc.roadHalfWidth=5.5;
        a(end+1)=mk(1,'pushcart',25,0,0,0,0,0.85,1.7,1.1,'linear');
        a(end+1)=mk(2,'two_wheeler',48,-1.8,2,0,0,0.7,2,0.8,'linear');
    case 2
        sc.name='Unsignalized urban intersection'; sc.roadHalfWidth=6;
        a(end+1)=mk(1,'auto_rickshaw',42,-5,0,1.9,0,1.1,2.8,1.5,'linear');
        a(end+1)=mk(2,'pedestrian',51,5,0,-0.8,2,0.45,0.6,0.6,'linear');
        a(end+1)=mk(3,'two_wheeler',64,-3,0,0.7,6,0.65,1.9,0.7,'linear');
    case 3
        sc.name='Arterial slow-traffic merge'; sc.roadHalfWidth=6.5;
        a(end+1)=mk(1,'truck',22,0,3,0,0,1.4,5,2.2,'linear');
        a(end+1)=mk(2,'auto_rickshaw',43,-4,2.2,0.2,0,1,2.7,1.5,'merge');
    case 4
        sc.name='Dense mixed market'; sc.roadHalfWidth=6;
        sc.goalX=65; sc.length=72; sc.timeout=55;
        a(end+1)=mk(1,'pushcart',17,-1.5,0,0,0,0.8,1.5,1.1,'linear');
        a(end+1)=mk(2,'auto_rickshaw',30,-2.5,0,0,0,0.9,2.8,1.4,'linear');
        a(end+1)=mk(3,'pedestrian',40,-4,0,0.6,2,0.4,0.6,0.6,'linear');
        a(end+1)=mk(4,'two_wheeler',52,-1,1.5,0,0,0.65,1.9,0.7,'linear');
    case 5
        sc.name='Sudden cattle crossing'; sc.roadHalfWidth=5.5;
        sc.goalX=48; sc.length=55; sc.timeout=35;
        a(end+1)=mk(1,'cattle',32,-2.5,0,1.0,5.0,1.15,2.2,1.2,'cross');
        a(end+1)=mk(2,'pushcart',45,3.5,0,0,0,0.8,1.6,1,'linear');
end
sc.actors=a; sc.seed=c.seed+id;
if nargin>=3 && ~isempty(variation)
    sc.seed=variation.seed;
    switch variation.kind
        case 'none'
        case 'actor_speed'
            k=variation.actorIndex;
            sc.actors(k).vx=sc.actors(k).vx*variation.factor;
            sc.actors(k).vy=sc.actors(k).vy*variation.factor;
        case 'actor_birth'
            k=variation.actorIndex;
            sc.actors(k).birth=sc.actors(k).birth+variation.delta;
        case 'ego_lateral'
            sc.ego(2)=sc.ego(2)+variation.delta;
        case {'camera_dropout','radar_dropout'}
        otherwise
            error('SIH:UnknownVariation','Unknown benchmark variation %s',variation.kind);
    end
end
sc.referencePath=[(0:2:sc.length)' zeros(numel(0:2:sc.length),1)];
% Navigation Toolbox occupancy representation of the unmarked road envelope.
sc.freeSpace=binaryOccupancyMap(sc.length+20,2*sc.roadHalfWidth+8,1);
sc.freeSpace.GridLocationInWorld=[-2 -sc.roadHalfWidth-4];
xEdge=(0:0.5:sc.length+15)';
for yEdge=[-sc.roadHalfWidth-2,-sc.roadHalfWidth-1, ...
        sc.roadHalfWidth+1,sc.roadHalfWidth+2]
    setOccupancy(sc.freeSpace,[xEdge yEdge+zeros(size(xEdge))],1);
end
% Executable Automated Driving Toolbox scenario; labels and motion are
% managed by the backend-independent world model for event-driven actors.
ds=drivingScenario('SampleTime',c.dt,'StopTime',sc.timeout);
road(ds,[0 0 0;sc.length 0 0],2*sc.roadHalfWidth);
if id==2, road(ds,[43 -13 0;43 13 0],8); end
sc.backend=ds;
end

function a=mk(id,type,x,y,vx,vy,birth,radius,len,width,motion)
a=struct('id',id,'type',type,'x0',x,'y0',y,'vx',vx,'vy',vy, ...
    'birth',birth,'radius',radius,'length',len,'width',width,'motion',motion);
end
