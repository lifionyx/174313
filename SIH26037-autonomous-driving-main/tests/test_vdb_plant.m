root=fileparts(fileparts(mfilename('fullpath'))); addpath(root); setup_project;
load_system('vehdynlibeom');
name='SIH_VDB_plant_probe';
if bdIsLoaded(name), close_system(name,0); end
new_system(name);
set_param(name,'Solver','ode4','FixedStep','0.01','StopTime','5');
block=[name '/Vehicle Body 3DOF'];
add_block('vehdynlibeom/Vehicle Body 3DOF Single Track',block, ...
    'Position',[230 100 440 320]);
set_param(block,'inputMode','External longitudinal forces');
for entry={'Steer',0,1;'FrontForce',0,2;'RearForce',1500,3}'
    b=[name '/' entry{1}];
    add_block('simulink/Sources/Constant',b, ...
        'Value',num2str(entry{2}), ...
        'Position',[40 80+65*entry{3} 100 110+65*entry{3}]);
    add_line(name,[entry{1} '/1'],['Vehicle Body 3DOF/' num2str(entry{3})]);
end
labels={'speed','lateral','yaw','yawRate'};
for j=1:4
    b=[name '/' labels{j}];
    add_block('simulink/Sinks/To Workspace',b, ...
        'VariableName',['vdb_' labels{j}], ...
        'SaveFormat','Timeseries', ...
        'Position',[540 75+55*j 650 95+55*j]);
    add_line(name,['Vehicle Body 3DOF/' num2str(j+1)], ...
        [labels{j} '/1']);
end
out=sim(name);
speed=out.get('vdb_speed'); yaw=out.get('vdb_yaw');
fprintf('VDB probe end speed %.3f m/s, yaw %.3f rad\n', ...
    speed.Data(end),yaw.Data(end));
assert(all(isfinite(speed.Data)) && speed.Data(end)>1, ...
    '3DOF vehicle body did not accelerate cleanly');
assert(abs(yaw.Data(end))<0.1,'Unexpected yaw under zero steering');
close_system(name,0);
