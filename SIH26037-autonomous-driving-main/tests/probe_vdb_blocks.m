root=fileparts(fileparts(mfilename('fullpath'))); addpath(root); setup_project;
libs={'vehdynlibeom','vehdynlibsim3d','vehdynlibsim3dcore'};
for k=1:numel(libs)
    try
        load_system(libs{k});
        blocks=find_system(libs{k},'LookUnderMasks','all', ...
            'FollowLinks','off','Type','Block');
        mask=contains(lower(string(blocks)), ...
            {'vehicle body 3dof','simulation 3d scene configuration', ...
            'simulation 3d vehicle'});
        fprintf('\nLibrary %s matching blocks:\n',libs{k}); disp(blocks(mask));
    catch ME
        fprintf('Library %s failed: %s\n',libs{k},ME.message);
    end
end
