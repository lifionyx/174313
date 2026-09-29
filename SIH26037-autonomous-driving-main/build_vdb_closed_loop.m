function modelPath=build_vdb_closed_loop(scenarioId,sensorMode,withUnreal,benchmarkMode)
if nargin<1, scenarioId=5; end
if nargin<2, sensorMode=0; end
if nargin<3, withUnreal=false; end
if nargin<4, benchmarkMode=false; end
assert(isscalar(scenarioId) && ismember(scenarioId,1:5));
assert(ismember(sensorMode,[0 1]));
setup_project;
root=fileparts(mfilename('fullpath'));
folder=fullfile(root,'models'); if ~exist(folder,'dir'), mkdir(folder); end
if benchmarkMode
    assert(~withUnreal,'Benchmark VDB plant is headless');
    name='SIH_VDB_Benchmark';
    folder=fullfile(root,'tests','benchmark');
elseif withUnreal, name='SIH_VDB_Unreal_ClosedLoop';
else, name='SIH_VDB_ClosedLoop'; end
modelPath=fullfile(folder,[name '.slx']);
if bdIsLoaded(name), close_system(name,0); end
load_system('vehdynlibeom');
new_system(name);
set_param(name,'Solver','ode4','FixedStep','0.02', ...
    'StopTime','35','SimulationMode','normal');

plant=[name '/Vehicle Body 3DOF Single Track'];
add_block('vehdynlibeom/Vehicle Body 3DOF Single Track',plant, ...
    'Position',[760 185 990 405]);
set_param(plant,'inputMode','External longitudinal forces', ...
    'm','2000','a','1.35','b','1.35');

add_block('simulink/Sources/Clock',[name '/Time'], ...
    'Position',[30 105 65 130]);
constant(name,'Scenario ID',scenarioId,[35 330 105 360]);
constant(name,'Sensor mode',sensorMode,[35 385 105 415]);
add_block('simulink/Signal Routing/Mux',[name '/Autonomy input'], ...
    'Inputs',num2str(7+benchmarkMode),'Position',[335 105 350 420]);
if benchmarkMode
    constant(name,'Benchmark case index',1,[35 445 105 475]);
end
add_block('simulink/User-Defined Functions/Interpreted MATLAB Function', ...
    [name '/Perception Prediction Risk Planning Control'], ...
    'MATLABFcn','sih.vdbAutonomy(u)', ...
    'OutputDimensions',num2str(30+2*benchmarkMode), ...
    'SampleTime','0.1','Position',[390 180 640 340]);
add_block('simulink/Signal Routing/Demux',[name '/Control ports'], ...
    'Outputs',sprintf('[1 1 1 %d]',27+2*benchmarkMode), ...
    'Position',[680 195 685 330]);
add_block('simulink/Sinks/Terminator',[name '/Other decisions'], ...
    'Position',[735 315 750 330]);

add_block('simulink/Signal Routing/Mux',[name '/Velocity and yaw'], ...
    'Inputs','3','Position',[1060 430 1075 560]);
add_block('simulink/User-Defined Functions/Interpreted MATLAB Function', ...
    [name '/SAE to road coordinates'], ...
    'MATLABFcn','sih.vdbWorldDerivative(u)', ...
    'OutputDimensions','2','SampleTime','0.02', ...
    'Position',[1120 460 1320 530]);
add_block('simulink/Signal Routing/Demux',[name '/World velocities'], ...
    'Outputs','2','Position',[1360 462 1365 528]);
add_block('simulink/Continuous/Integrator',[name '/World X'], ...
    'InitialCondition','0','Position',[1405 465 1435 495]);
add_block('simulink/Continuous/Integrator',[name '/World Y left'], ...
    'InitialCondition','0','Position',[1405 515 1435 545]);
add_block('simulink/Signal Routing/Mux',[name '/Ego state'], ...
    'Inputs','5','Position',[1500 120 1515 390]);
workspace(name,'vdbEgo','vdbEgo',[1560 235 1670 270]);
workspace(name,'vdbDecisions','vdbDecisions',[720 65 830 100]);
if benchmarkMode
    constant(name,'Goal X',79,[1530 580 1590 610]);
    add_block('simulink/Signal Routing/Mux',[name '/Goal input'], ...
        'Inputs','3','Position',[1605 440 1620 545]);
    add_block('simulink/User-Defined Functions/Interpreted MATLAB Function', ...
        [name '/Scored goal stop'], ...
        'MATLABFcn','sih.vdbGoalReached(u)', ...
        'OutputDimensions','1','SampleTime','0.02', ...
        'Position',[1660 460 1820 520]);
    add_block('simulink/Sinks/Stop Simulation', ...
        [name '/Stop at scored goal'], ...
        'Position',[1860 475 1890 505]);
end

add_line(name,'Time/1','Autonomy input/1');
add_line(name,'World X/1','Autonomy input/2');
add_line(name,'World Y left/1','Autonomy input/3');
add_line(name,'Vehicle Body 3DOF Single Track/4','Autonomy input/4');
add_line(name,'Vehicle Body 3DOF Single Track/2','Autonomy input/5');
add_line(name,'Scenario ID/1','Autonomy input/6');
add_line(name,'Sensor mode/1','Autonomy input/7');
if benchmarkMode
    add_line(name,'Benchmark case index/1','Autonomy input/8');
end
add_line(name,'Autonomy input/1', ...
    'Perception Prediction Risk Planning Control/1');
add_line(name,'Perception Prediction Risk Planning Control/1', ...
    'Control ports/1');
add_line(name,'Perception Prediction Risk Planning Control/1', ...
    'vdbDecisions/1');
add_line(name,'Control ports/1','Vehicle Body 3DOF Single Track/1');
add_line(name,'Control ports/2','Vehicle Body 3DOF Single Track/2');
add_line(name,'Control ports/3','Vehicle Body 3DOF Single Track/3');
add_line(name,'Control ports/4','Other decisions/1');
add_line(name,'Vehicle Body 3DOF Single Track/2','Velocity and yaw/1');
add_line(name,'Vehicle Body 3DOF Single Track/3','Velocity and yaw/2');
add_line(name,'Vehicle Body 3DOF Single Track/4','Velocity and yaw/3');
add_line(name,'Velocity and yaw/1','SAE to road coordinates/1');
add_line(name,'SAE to road coordinates/1','World velocities/1');
add_line(name,'World velocities/1','World X/1');
add_line(name,'World velocities/2','World Y left/1');
add_line(name,'World X/1','Ego state/1');
add_line(name,'World Y left/1','Ego state/2');
add_line(name,'Vehicle Body 3DOF Single Track/4','Ego state/3');
add_line(name,'Vehicle Body 3DOF Single Track/2','Ego state/4');
add_line(name,'Vehicle Body 3DOF Single Track/3','Ego state/5');
add_line(name,'Ego state/1','vdbEgo/1');
if benchmarkMode
    add_line(name,'World X/1','Goal input/1');
    add_line(name,'Vehicle Body 3DOF Single Track/2','Goal input/2');
    add_line(name,'Goal X/1','Goal input/3');
    add_line(name,'Goal input/1','Scored goal stop/1');
    add_line(name,'Scored goal stop/1','Stop at scored goal/1');
end
if withUnreal
    addUnreal(name);
end
save_system(name,modelPath); close_system(name,0);
end

function addUnreal(name)
load_system('vehdynlibsim3d');
load_system('vehdynlibsim3dcore');
load_system('drivingsim3d');
scene=[name '/Unreal 3D scene'];
add_block('vehdynlibsim3dcore/Simulation 3D Scene Configuration', ...
    scene,'Position',[1720 80 1930 170]);
set_param(scene,'SceneDesc','Open surface','Priority','0');
car=[name '/Unreal 3D sedan'];
add_block('vehdynlibsim3d/Simulation 3D Vehicle',car, ...
    'Position',[1720 265 1930 405]);
set_param(car,'PassVehMesh','Sedan','VehColor','Blue', ...
    'ActorName','SIH_Ego','SampleTime','0.02','Priority','-1');
add_block('simulink/Signal Routing/Mux',[name '/Unreal XY'], ...
    'Inputs','2','Position',[1525 440 1540 510]);
add_block('simulink/User-Defined Functions/Interpreted MATLAB Function', ...
    [name '/Unreal translation'], ...
    'MATLABFcn','sih.unrealCarTranslation(u)', ...
    'OutputDimensions','[5 3]','Output1D','off', ...
    'SampleTime','0.02', ...
    'Position',[1575 435 1695 505]);
add_block('simulink/Signal Routing/Mux',[name '/Unreal heading and steer'], ...
    'Inputs','2','Position',[1525 540 1540 610]);
add_block('simulink/User-Defined Functions/Interpreted MATLAB Function', ...
    [name '/Unreal rotation'], ...
    'MATLABFcn','sih.unrealCarRotation(u)', ...
    'OutputDimensions','[5 3]','Output1D','off', ...
    'SampleTime','0.02', ...
    'Position',[1575 535 1695 605]);
constantMatrix=[name '/Unreal vehicle scale'];
add_block('simulink/Sources/Constant',constantMatrix, ...
    'Value','ones(5,3)','Position',[1575 645 1695 675]);
add_line(name,'World X/1','Unreal XY/1');
add_line(name,'World Y left/1','Unreal XY/2');
add_line(name,'Unreal XY/1','Unreal translation/1');
add_line(name,'Unreal translation/1','Unreal 3D sedan/1');
add_line(name,'Vehicle Body 3DOF Single Track/4', ...
    'Unreal heading and steer/1');
add_line(name,'Control ports/1','Unreal heading and steer/2');
add_line(name,'Unreal heading and steer/1','Unreal rotation/1');
add_line(name,'Unreal rotation/1','Unreal 3D sedan/2');
add_line(name,'Unreal vehicle scale/1','Unreal 3D sedan/3');
camera=[name '/Unreal follow camera'];
add_block('drivingsim3d/Simulation 3D Camera',camera, ...
    'Position',[1990 260 2200 355]);
set_param(camera,'sensorId','1','sensorName','SIH_FollowCamera', ...
    'vehTag','SIH_Ego','mountLoc','Origin', ...
    'offsetFlag','on','tmountOffset','[-8, 0, 3]', ...
    'rmountOffset','[0, 18, 0]', ...
    'ImageSize','[360, 640]','OpticalCenter','[320, 180]', ...
    'FocalLength','[550, 550]', ...
    'SampleTime','0.2','Priority','1');
workspace(name,'unrealCamera','unrealCamera',[2250 275 2360 310]);
add_line(name,'Unreal follow camera/1','unrealCamera/1');
end

function constant(name,label,value,pos)
add_block('simulink/Sources/Constant',[name '/' label], ...
    'Value',num2str(value),'Position',pos);
end

function workspace(name,label,variable,pos)
add_block('simulink/Sinks/To Workspace',[name '/' label], ...
    'VariableName',variable,'SaveFormat','Timeseries','Position',pos);
end
