function files=run_vdb_unreal_preview
setup_project;
root=fileparts(mfilename('fullpath'));
model=build_vdb_closed_loop(5,1,true);
load_system(model);
out=sim('SIH_VDB_Unreal_ClosedLoop','StopTime','6');
ego=out.get('vdbEgo'); decisions=out.get('vdbDecisions');
camera=out.get('unrealCamera');
assert(all(isfinite(ego.Data(:))) && ...
    ~any(decisions.Data(:,30)>0));
save(fullfile(root,'results','metrics','vdb_unreal_preview.mat'), ...
    'ego','decisions','camera');
files=sih.exportUnrealCamera(camera,fullfile(root,'outputs'));
fprintf('Unreal VDB preview t=%.1f s x=%.2f m speed=%.2f m/s\n', ...
    ego.Time(end),ego.Data(end,1),ego.Data(end,4));
folder=fullfile(root,'outputs','screenshots','simulink');
print('-sSIH_VDB_Unreal_ClosedLoop','-dpng','-r220', ...
    fullfile(folder,'vdb_unreal_full_model.png'));
close_system('SIH_VDB_Unreal_ClosedLoop',0);
end
