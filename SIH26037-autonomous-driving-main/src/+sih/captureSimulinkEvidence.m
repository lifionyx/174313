function files=captureSimulinkEvidence(outputRoot)
% Programmatic exports of the actual generated model and its real subsystem.
folder=fullfile(outputRoot,'screenshots','simulink');
if ~exist(folder,'dir'), mkdir(folder); end
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
model=fullfile(root,'models','SIH_AutonomousDriving.slx');
assert(isfile(model),'Simulink model is missing');
load_system(model);
files={fullfile(folder,'full_model.png'); ...
    fullfile(folder,'closed_loop_subsystem.png')};
print('-sSIH_AutonomousDriving','-dpng','-r300',files{1});
print('-sSIH_AutonomousDriving/Closed-loop autonomy', ...
    '-dpng','-r300',files{2});
assert(all(cellfun(@isfile,files)),'Simulink screenshot export failed');
close_system('SIH_AutonomousDriving',0);
end
