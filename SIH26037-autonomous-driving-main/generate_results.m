function generate_results(mode)
if nargin<1, mode='synthetic_fusion'; end
setup_project;
root=fileparts(mfilename('fullpath'));
csv=fullfile(root,'results','metrics',[mode '_benchmark.csv']);
assert(isfile(csv),'Run run_all_scenarios first for this mode.');
t=readtable(csv);
folder=fullfile(root,'results','figures');
if ~exist(folder,'dir'), mkdir(folder); end
f=figure('Visible','off','Color','w');
tiledlayout(2,1);
nexttile; bar(t.scenario,t.duration); ylabel('Duration (s)');
title(sprintf('SIH26037 benchmark — %s',mode)); grid on;
nexttile; bar(t.scenario,t.minimumClearance); ylabel('Minimum clearance (m)');
xlabel('Scenario'); grid on;
exportgraphics(f,fullfile(folder,[mode '_summary.png'])); close(f);
for id=1:5
    data=load(fullfile(root,'results','metrics', ...
        sprintf('%s_scenario_%d.mat',mode,id)));
    sih.plotRun(data.r,fullfile(folder,sprintf('%s_scenario_%d.png',mode,id)));
end
if strcmp(mode,'synthetic_fusion')
    data=load(fullfile(root,'results','metrics', ...
        'synthetic_fusion_scenario_1.mat'));
    sih.plotSensorDebug(data.r,sih.config('fast',mode), ...
        fullfile(folder,'sensor_debug.png'));
elseif strcmp(mode,'truth')
    data=load(fullfile(root,'results','metrics','truth_scenario_5.mat'));
    sih.plotDecisionTimeline(data.r, ...
        fullfile(folder,'cattle_truth_decisions.png'));
end
end
