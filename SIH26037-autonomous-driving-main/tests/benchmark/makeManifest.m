function manifest=makeManifest(root)
% Freeze 60 distinct, predeclared perturbations before examining results.
c=sih.config('fast','synthetic_fusion');
ids={'B00','N01','N02','N03','A01','A02','A03','A04', ...
    'E01','E02','S01','S02'};
blank=struct('index',0,'scenarioId',0,'scenarioName','', ...
    'caseId','','seed',0,'kind','','actorIndex',0,'actorId',0, ...
    'factor',1,'delta',0,'dropoutProbability',0, ...
    'originalVx',nan,'actualVx',nan,'originalVy',nan,'actualVy',nan, ...
    'originalBirth',nan,'actualBirth',nan, ...
    'originalEgoY',nan,'actualEgoY',nan,'appliedPerturbation','');
cases=repmat(blank,60,1);
for sid=1:5
    sc=sih.makeScenario(sid,c);
    actorIndex=find([sc.actors.vx]~=0 | [sc.actors.vy]~=0,1,'first');
    assert(~isempty(actorIndex),'Every benchmark scenario needs a moving actor');
    a=sc.actors(actorIndex);
    for j=1:12
        k=(sid-1)*12+j; v=blank;
        v.index=k; v.scenarioId=sid; v.scenarioName=sc.name;
        v.caseId=ids{j}; v.seed=26037;
        v.actorIndex=actorIndex; v.actorId=a.id;
        v.originalVx=a.vx; v.actualVx=a.vx;
        v.originalVy=a.vy; v.actualVy=a.vy;
        v.originalBirth=a.birth; v.actualBirth=a.birth;
        v.originalEgoY=sc.ego(2); v.actualEgoY=sc.ego(2);
        switch j
            case 1
                v.kind='none'; v.appliedPerturbation='canonical geometry; seed 26037';
            case {2,3,4}
                v.kind='none'; v.seed=26036+j;
                v.appliedPerturbation=sprintf('canonical geometry; seed %d',v.seed);
            case {5,6}
                v.kind='actor_speed';
                if j==5, v.factor=0.8; else, v.factor=1.2; end
                v.actualVx=a.vx*v.factor; v.actualVy=a.vy*v.factor;
                v.appliedPerturbation=sprintf('actor %d speed x %.1f: velocity (%.3g,%.3g) to (%.3g,%.3g) m/s', ...
                    a.id,v.factor,a.vx,a.vy,v.actualVx,v.actualVy);
            case {7,8}
                v.kind='actor_birth';
                if j==7, v.delta=-1; else, v.delta=1; end
                v.actualBirth=a.birth+v.delta;
                v.appliedPerturbation=sprintf('actor %d birth %.3g to %.3g s', ...
                    a.id,a.birth,v.actualBirth);
            case {9,10}
                v.kind='ego_lateral';
                if j==9, v.delta=0.5; else, v.delta=-0.5; end
                v.actualEgoY=sc.ego(2)+v.delta;
                v.appliedPerturbation=sprintf('ego initial y %.3g to %.3g m', ...
                    sc.ego(2),v.actualEgoY);
            case 11
                v.kind='camera_dropout'; v.dropoutProbability=0.1;
                v.appliedPerturbation='seeded 10% camera detection dropout';
            case 12
                v.kind='radar_dropout'; v.dropoutProbability=0.1;
                v.appliedPerturbation='seeded 10% radar detection dropout';
        end
        cases(k)=v;
    end
end
assert(numel(cases)==60 && numel(unique(strcat(string({cases.scenarioId})', ...
    '_',string({cases.caseId})')))==60);
manifest=struct;
manifest.schemaVersion='SIH26037-benchmark-v1';
manifest.thresholdVersion='user-proposed-strict-v1';
manifest.thresholds=struct('collisionEpisodes',0,'minimumTTCSeconds',0.95, ...
    'completed',true,'p95ReplanMs',100,'maxAbsPhysicalJerk',0.9);
manifest.matlabRelease=version('-release');
manifest.matlabVersion=version;
manifest.createdUTC=char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd HH:mm:ss Z'));
manifest.codeFingerprint=codeFingerprint(root);
[status,commit]=system('git rev-parse HEAD');
if status==0, manifest.gitCommit=strtrim(commit);
else, manifest.gitCommit='unavailable'; end
manifest.backend='SIH_VDB_Benchmark; Vehicle Body 3DOF Single Track';
manifest.sensorMode='synthetic_fusion';
manifest.measurements=['collision episodes from circular ego/actor geometry; ', ...
    'predicted TTC from decision column 6 excluding sentinel 99 and nonfinite; ', ...
    'goal scored by vdbMetrics before timeout and without collision/departure; ', ...
    'nearest-rank p95 of positive replan timings from decision column 7; ', ...
    'maximum speed-derived jerk from consecutive finite-difference accelerations'];
manifest.cases=cases;
end
