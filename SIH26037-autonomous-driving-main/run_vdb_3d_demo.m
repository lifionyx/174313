function r=run_vdb_3d_demo
setup_project;
root=fileparts(mfilename('fullpath'));
model=build_vdb_closed_loop(5,1,false);
load_system(model);
out=sim('SIH_VDB_ClosedLoop','StopTime','35');
e=out.get('vdbEgo'); d=out.get('vdbDecisions');
r=sih.vdbMetrics(e,d,5);
assert(r.metrics.success && r.metrics.collisionCount==0, ...
    'VDB cattle crossing did not reach a collision-free goal');
save(fullfile(root,'results','metrics','vdb_3d_demo.mat'),'r');
disp(struct2table(r.metrics));
shotFolder=fullfile(root,'outputs','screenshots','simulink');
if ~exist(shotFolder,'dir'), mkdir(shotFolder); end
print('-sSIH_VDB_ClosedLoop','-dpng','-r220', ...
    fullfile(shotFolder,'vdb_closed_loop_full_model.png'));
close_system('SIH_VDB_ClosedLoop',0);
sih.recordVdb3D(r,fullfile(root,'outputs'));
end
