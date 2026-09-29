root=fileparts(fileparts(mfilename('fullpath'))); addpath(root); setup_project;
load_system('vehdynlibsim3dcore');
name='SIH_Sim3D_runtime_probe';
if bdIsLoaded(name), close_system(name,0); end
new_system(name);
set_param(name,'Solver','FixedStepDiscrete','FixedStep','0.02', ...
    'StopTime','0.3');
block=[name '/Scene Configuration'];
add_block('vehdynlibsim3dcore/Simulation 3D Scene Configuration', ...
    block,'Position',[100 100 330 180]);
fprintf('Scene description: %s\n',get_param(block,'SceneDesc'));
fprintf('Scene executable: %s\n',get_param(block,'ProjectName'));
fprintf('Executable exists: %d\n',isfile(get_param(block,'ProjectName')));
try
    out=sim(name);
    fprintf('Unreal scene simulation completed at %.2f s\n',out.tout(end));
catch ME
    fprintf('Unreal scene runtime failure: %s\n',getReport(ME,'basic'));
    close_system(name,0);
    rethrow(ME);
end
close_system(name,0);
