setup_project;
if ~exist('sihPerceptionMode','var'), sihPerceptionMode='synthetic_fusion'; end
c=sih.config('fast',sihPerceptionMode);
if ~exist(fullfile('results','logs'),'dir'), mkdir(fullfile('results','logs')); end
diary(fullfile('results','logs',[sihPerceptionMode '_benchmark.txt']));
if ~exist(fullfile('results','metrics'),'dir'), mkdir(fullfile('results','metrics')); end
rows=cell(5,1);
for id=1:5
    r=sih.simulate(id,c); rows{id}=r.metrics;
    save(fullfile('results','metrics',sprintf('%s_scenario_%d.mat', ...
        sihPerceptionMode,id)),'r');
    fprintf('%d %s: %s, x=%.1f, collisions=%d\n',id,r.name,r.outcome, ...
        r.metrics.finalX,r.metrics.collisionCount);
    if ~isempty(r.failures), error('SIH:PlannerFailure','%s',strjoin(r.failures,newline)); end
end
summary=struct2table([rows{:}]);
writetable(summary,fullfile('results','metrics', ...
    sprintf('%s_benchmark.csv',sihPerceptionMode)));
disp(summary(:,{'scenario','success','outcome','collisionCount','duration', ...
    'meanReplanMs','minimumClearance','emergencyInterventions'}));
diary off;
assert(all(summary.success) && all(summary.collisionCount==0), ...
    'At least one canonical scenario failed or collided.');
if strcmp(sihPerceptionMode,'synthetic_fusion')
    capture_outputs;
end
