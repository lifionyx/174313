setup_project;
if ~exist(fullfile('results','logs'),'dir'), mkdir(fullfile('results','logs')); end
diary(fullfile('results','logs','seed_sweep.txt'));
seeds=[26038 26039];
rows=cell(numel(seeds)*5,1); index=0;
for seed=seeds
    for id=1:5
        c=sih.config('fast','synthetic_fusion'); c.seed=seed;
        r=sih.simulate(id,c); index=index+1;
        m=r.metrics; m.seed=seed; rows{index}=m;
        fprintf('seed=%d scenario=%d outcome=%s collisions=%d x=%.1f\n', ...
            seed,id,r.outcome,r.metrics.collisionCount,r.metrics.finalX);
        if ~isempty(r.failures)
            error('SIH:PlannerFailure','%s',strjoin(r.failures,newline));
        end
    end
end
summary=struct2table([rows{:}]);
writetable(summary,fullfile('results','metrics','seed_sweep.csv'));
diary off;
assert(all(summary.success) && all(summary.collisionCount==0), ...
    'At least one seed-sweep scenario failed or collided.');
