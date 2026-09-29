function c = config(profile, mode)
if nargin<1, profile='fast'; end
if nargin<2, mode='truth'; end
assert(any(strcmp(profile,{'fast','full'})),'Unknown profile');
assert(any(strcmp(mode,{'truth','synthetic_fusion'})),'Unknown perception mode');
c.profile=profile; c.perceptionMode=mode; c.dt=0.1; c.planPeriod=0.5;
c.predHorizon=4; c.predDt=0.2; c.maxSpeed=8; c.maxAccel=2;
c.comfortDecel=3; c.emergencyDecel=7; c.maxSteer=0.45;
c.wheelbase=2.7; c.egoLength=4.2; c.egoWidth=1.8;
c.safetyBuffer=0.4; c.minTTC=1.2; c.seed=26037;
c.sensorPeriod=[0.2 0.1 0.2]; % camera, radar, lidar
c.sensorRange=[55 75 35]; c.trackCoast=1.0;
c.roadRunnerEnabled=false; c.visualize=strcmp(profile,'full');
c.weights=struct('progress',1,'offset',0.04,'speed',0.1, ...
    'clearance',2,'smooth',0.4,'accel',0.2);
end
