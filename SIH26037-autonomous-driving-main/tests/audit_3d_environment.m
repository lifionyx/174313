root=fileparts(fileparts(mfilename('fullpath')));
addpath(root);
setup_project;
fprintf('MATLAB %s\n',version);
names={'vdynblks','drivingsim3d','sim3d','sim3dActor', ...
    'uavScenario','VideoWriter','getframe','exportgraphics'};
for k=1:numel(names)
    fprintf('%-22s exist=%d which=%s\n',names{k}, ...
        exist(names{k},'file'),which(names{k}));
end
try
    load_system('vdynblks');
    blocks=find_system('vdynblks','LookUnderMasks','all', ...
        'FollowLinks','on','Type','Block');
    useful=blocks(contains(lower(string(blocks)), ...
        {'vehicle body 3dof','simulation 3d scene configuration', ...
        'simulation 3d vehicle'}));
    fprintf('Relevant Vehicle Dynamics Blockset blocks:\n');
    disp(useful);
catch ME
    fprintf('Vehicle Dynamics library inspection failed: %s\n',ME.message);
end
try
    addons=matlab.addons.installedAddons;
    ix=contains(lower(string(addons.Name)),{'unreal','3d','automated driving'});
    disp(addons(ix,:));
catch ME
    fprintf('Add-on inventory unavailable: %s\n',ME.message);
end
try
    info=VideoWriter.getProfiles;
    disp(string({info.Name}));
catch ME
    fprintf('Video profile probe failed: %s\n',ME.message);
end
