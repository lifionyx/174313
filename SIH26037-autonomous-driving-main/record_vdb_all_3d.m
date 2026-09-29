function files=record_vdb_all_3d
setup_project;
root=fileparts(mfilename('fullpath'));
files=cell(5,1);
for id=1:5
    source=fullfile(root,'results','metrics', ...
        sprintf('vdb_synthetic_scenario_%d.mat',id));
    assert(isfile(source),'Run run_vdb_all_scenarios first: %s',source);
    data=load(source,'r'); r=data.r;
    assert(r.metrics.success && r.metrics.collisionCount==0);
    files{id}=sih.recordVdb3D(r,fullfile(root,'outputs'));
    fprintf('Recorded VDB 3D scene %d: %s\n',id, ...
        files{id}.screenRecording);
end
end
