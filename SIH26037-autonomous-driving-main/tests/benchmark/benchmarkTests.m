function benchmarkTests(manifest)
% Focused regression tests for the published benchmark definitions.
c=sih.config('fast','synthetic_fusion');
v=manifest.cases(1); sc=sih.makeScenario(1,c,v);
t=(0:4)';
e=[0 0 0 0 0; 10 0 0 1 0; 40 0 0 2 0; ...
    65 0 0 3 0; 80 0 0 0 0];
d=zeros(5,32); d(:,6)=2; d(:,7)=[10;0;20;0;30];
E=timeseries(e,t); D=timeseries(d,t);
[r,x]=scoreCase(E,D,sc,v,manifest);
assert(r.valid && r.completed && x.replans==3 && r.p95ReplanMs==30);
assert(r.maxAbsPhysicalJerk==4 && ~r.jerkPASS);
assert(r.collisionEpisodes==0);

d(2,6)=0; [r,x]=scoreCase(E,timeseries(d,t),sc,v,manifest);
assert(r.valid && r.minimumTTC==0 && ~r.ttcPASS && x.validTTC==5);
d(:,6)=99; [r,x]=scoreCase(E,timeseries(d,t),sc,v,manifest);
assert(~r.valid && isnan(r.minimumTTC) && x.excludedTTC==5);

d(:,6)=2; e(2:3,1)=25;
[r,~]=scoreCase(timeseries(e,t),timeseries(d,t),sc,v,manifest);
assert(r.collisionEpisodes==1 && ~r.completed && ...
    strcmp(r.rawOutcome,'collision'));

e=[0 0 0 0 0; 10 0 0 1 0; 40 0 0 2 0; ...
    65 0 0 3 0; 80 0 0 0 0];
bad=t; bad(3)=bad(2);
[r,~]=scoreCase(timeseries(e,bad),timeseries(d,t),sc,v,manifest);
assert(~r.valid && contains(r.invalidReason,'timestamps'));
[r,~]=scoreCase(timeseries(e,t),timeseries(d,bad),sc,v,manifest);
assert(~r.valid && contains(r.invalidReason,'timestamps'));

e(end,1)=70;
[r,~]=scoreCase(timeseries(e,t),timeseries(d,t),sc,v,manifest);
assert(r.valid && ~r.completed && strcmp(r.rawOutcome,'timeout'));
e(end,1)=80; e(:,4)=0;
[r,~]=scoreCase(timeseries(e,t),timeseries(d,t),sc,v,manifest);
assert(r.valid && r.Overall_PASS && all([r.collisionPASS,r.ttcPASS, ...
    r.completionPASS,r.latencyPASS,r.jerkPASS]));
e(end,2)=sc.roadHalfWidth;
[r,~]=scoreCase(timeseries(e,t),timeseries(d,t),sc,v,manifest);
assert(~r.completed && ~r.completionPASS && ...
    strcmp(r.rawOutcome,'road_departure'));
fprintf('Benchmark unit definitions: PASS (TTC, episodes, timing, jerk, timestamps, completion, aggregation)\n');
end
