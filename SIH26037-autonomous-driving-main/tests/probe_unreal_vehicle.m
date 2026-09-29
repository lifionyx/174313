root=fileparts(fileparts(mfilename('fullpath'))); addpath(root); setup_project;
load_system('vehdynlibsim3d');
name='SIH_UnrealVehicle_probe'; if bdIsLoaded(name), close_system(name,0); end
new_system(name);
b=[name '/Car'];
add_block('vehdynlibsim3d/Simulation 3D Vehicle',b, ...
    'Position',[100 100 310 300]);
pc=get_param(b,'PortConnectivity');
fprintf('Input/output port count=%d\n',numel(pc));
for k=1:numel(pc)
    fprintf('Port %d type=%s\n',k,string(pc(k).Type));
end
n=get_param(b,'MaskNames'); v=get_param(b,'MaskValues');
for k=1:numel(n)
    if contains(lower(n{k}),{'mesh','color','sample','actor','name', ...
            'initial','translation','rotation','scale'})
        fprintf('%s=%s\n',n{k},v{k});
    end
end
close_system(name,0);
