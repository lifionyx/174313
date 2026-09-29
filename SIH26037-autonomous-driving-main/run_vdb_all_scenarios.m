function summary=run_vdb_all_scenarios
setup_project;
root=fileparts(mfilename('fullpath'));
resultDir=fullfile(root,'results','metrics');
outputDir=fullfile(root,'outputs','metrics');
if ~exist(resultDir,'dir'), mkdir(resultDir); end
if ~exist(outputDir,'dir'), mkdir(outputDir); end
rows=cell(5,1);
for id=1:5
    sc=sih.makeScenario(id,sih.config('fast','synthetic_fusion'));
    model=build_vdb_closed_loop(id,1,false);
    load_system(model);
    output=sim('SIH_VDB_ClosedLoop','StopTime', ...
        num2str(max(sc.timeout,65)));
    e=output.get('vdbEgo'); d=output.get('vdbDecisions');
    r=sih.vdbMetrics(e,d,id);
    rows{id}=r.metrics;
    save(fullfile(resultDir,sprintf('vdb_synthetic_scenario_%d.mat',id)),'r');
    fprintf('VDB scene %d: %s, x=%.2f, collisions=%d, clearance=%.2f\n', ...
        id,r.metrics.outcome,r.metrics.finalX, ...
        r.metrics.collisionCount,r.metrics.minimumClearance);
    close_system('SIH_VDB_ClosedLoop',0);
    if ~r.metrics.success || r.metrics.collisionCount>0
        error('SIH:VDBScenarioFailed','VDB scenario %d failed: %s', ...
            id,r.metrics.outcome);
    end
end
summary=struct2table([rows{:}]);
writetable(summary,fullfile(outputDir,'vdb_synthetic_benchmark.csv'));
disp(summary(:,{'scenario','success','collisionCount','duration', ...
    'minimumClearance','meanReplanMs'}));
end
