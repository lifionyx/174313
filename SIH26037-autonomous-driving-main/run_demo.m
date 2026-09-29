setup_project;
c=sih.config('full','synthetic_fusion');
if ~exist(fullfile('results','logs'),'dir'), mkdir(fullfile('results','logs')); end
diary(fullfile('results','logs','demo.txt'));
r=sih.simulate(5,c);
if ~exist(fullfile('results','metrics'),'dir'), mkdir(fullfile('results','metrics')); end
save(fullfile('results','metrics','demo.mat'),'r');
disp(struct2table(r.metrics));
sih.plotRun(r,fullfile('results','figures','cattle_demo.png'));
sih.plotSensorDebug(r,c,fullfile('results','figures','sensor_debug.png'));
sih.plotDecisionTimeline(r,fullfile('results','figures','cattle_decisions.png'));
if ~isempty(r.failures), error('SIH:PlannerFailure','%s',strjoin(r.failures,newline)); end
diary off;
assert(r.metrics.success && r.metrics.collisionCount==0, ...
    'Demo did not reach its goal safely.');
out=fullfile(fileparts(mfilename('fullpath')),'outputs');
if ~exist(fullfile(out,'metrics'),'dir'), mkdir(fullfile(out,'metrics')); end
sih.captureScenarioEvidence(r,out,c);
