root=fileparts(fileparts(mfilename('fullpath'))); addpath(root); setup_project;
path=build_simulink_model;
load_system(path);
assert(bdIsLoaded('SIH_AutonomousDriving'));
out=sim('SIH_AutonomousDriving','StopTime','25');
log=out.get('egoLog');
data=squeeze(log.Data);
assert(size(data,2)==10,'Unexpected output width');
assert(all(isfinite(data(:))),'Non-finite Simulink output');
assert(all(data(:,9)==0),'Simulink collision');
assert(data(end,1)>=78,'Simulink ego did not reach goal');
fprintf('Simulink goal x=%.2f, min collision flag=%d\n', ...
    data(end,1),max(data(:,9)));
close_system('SIH_AutonomousDriving',0);
