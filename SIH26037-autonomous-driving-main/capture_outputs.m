function capture_outputs
setup_project;
root=fileparts(mfilename('fullpath'));
out=fullfile(root,'outputs');
for folder={'metrics','figures','videos','screenshots','logs'}
    target=fullfile(out,folder{1});
    if ~exist(target,'dir'), mkdir(target); end
end
sourceMetrics=fullfile(root,'results','metrics');
csv=fullfile(sourceMetrics,'synthetic_fusion_benchmark.csv');
assert(isfile(csv),'Run the synthetic-fusion benchmark before capture_outputs.');
benchmark=readtable(csv);
assert(height(benchmark)==5 && all(benchmark.success) && ...
    all(benchmark.collisionCount==0), ...
    'Canonical benchmark has failed; evidence cannot be labeled successful.');
copyfile(csv,fullfile(out,'metrics','synthetic_fusion_benchmark.csv'));
other={'truth_benchmark.csv','seed_sweep.csv'};
for k=1:numel(other)
    source=fullfile(sourceMetrics,other{k});
    if isfile(source), copyfile(source,fullfile(out,'metrics',other{k})); end
end
c=sih.config('fast','synthetic_fusion');
runs=cell(5,1);
for id=1:5
    source=fullfile(sourceMetrics, ...
        sprintf('synthetic_fusion_scenario_%d.mat',id));
    assert(isfile(source),'Missing executed log: %s',source);
    loaded=load(source,'r'); r=loaded.r;
    assert(r.id==id && r.metrics.success && isempty(r.failures), ...
        'Scenario %d log is not a successful clean run.',id);
    runs{id}=r;
    copyfile(source,fullfile(out,'metrics',sprintf('scenario_%d.mat',id)));
    sih.captureScenarioEvidence(r,out,c);
    fprintf('Captured scenario %d: 8 screenshots + MP4\n',id);
end
sih.generateOutputFigures(out,runs);
sih.captureSimulinkEvidence(out);
sih.combineEvidenceVideos(out);
logFiles={'environment_audit.txt','tests.txt', ...
    'synthetic_fusion_benchmark.txt','truth_benchmark.txt','seed_sweep.txt'};
for k=1:numel(logFiles)
    source=fullfile(root,'results','logs',logFiles{k});
    if isfile(source)
        copyfile(source,fullfile(out,'logs',logFiles{k}));
    end
end
sih.writeEvidenceDocs(out,runs);
sih.verifyOutputs(out);
fprintf('All output artifacts generated and verified in %s\n',out);
end
