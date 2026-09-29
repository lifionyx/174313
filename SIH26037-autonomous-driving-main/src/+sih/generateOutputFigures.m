function generated=generateOutputFigures(outputRoot,runResults)
% Every numeric series is read from the executed benchmark or its MAT logs.
folder=fullfile(outputRoot,'figures'); if ~exist(folder,'dir'), mkdir(folder); end
t=readtable(fullfile(outputRoot,'metrics','synthetic_fusion_benchmark.csv'));
generated=cell(0,1);
f=makeFigure;
bar(t.scenario,[t.meanReplanMs t.p95ReplanMs],'grouped'); grid on;
legend('Mean','95th percentile','Location','best');
xlabel('Scenario'); ylabel('Planning latency (ms)');
title('Measured replanning latency');
saveFigure(f,'replanning_latency.png');

f=makeFigure;
bar(t.scenario,t.minimumClearance,'FaceColor',[0.1 0.6 0.5]); grid on;
xlabel('Scenario'); ylabel('Minimum geometric clearance (m)');
title('Closest approach in executed runs');
saveFigure(f,'minimum_clearance.png');

f=makeFigure; tiledlayout(2,1);
nexttile; bar(t.scenario,double(t.success),'FaceColor',[0.2 0.65 0.3]);
ylim([0 1.15]); ylabel('Goal reached'); grid on;
title('Canonical scenario completion');
nexttile; bar(t.scenario,t.duration,'FaceColor',[0.25 0.45 0.8]);
xlabel('Scenario'); ylabel('Duration (s)'); grid on;
saveFigure(f,'scenario_success_completion.png');

f=makeFigure; tiledlayout(2,1);
nexttile; bar(t.scenario,t.rmsJerk); ylabel('RMS jerk (m/s^3)');
grid on; title('Measured comfort and path smoothness');
nexttile; bar(t.scenario,t.curvatureChange);
ylabel('Sum of curvature changes (1/m)'); xlabel('Scenario'); grid on;
saveFigure(f,'jerk_smoothness.png');

f=makeFigure; hold on; grid on;
colors=lines(5);
for id=1:5
    r=runResults{id};
    plot(r.log.ego(:,1),r.log.ego(:,2),'LineWidth',2, ...
        'Color',colors(id,:),'DisplayName',sprintf('%d %s',id,r.name));
end
ylim([-7 7]); xlim([0 85]);
xlabel('World x (m)'); ylabel('World y (m)');
title('Executed ego paths in five road scenarios');
legend('Location','bestoutside');
saveFigure(f,'executed_trajectories.png');

r=runResults{5}; time=r.log.time;
ttcTrace=r.log.ttc; ttcTrace(~isfinite(ttcTrace))=5;
f=makeFigure; plot(time,min(5,ttcTrace),'r','LineWidth',1.2); grid on;
ylim([0 5]); xlim([time(1) time(end)]);
xlabel('Time (s)'); ylabel('Predicted TTC (s)');
title('Cattle crossing: time to contact (values above 5 s clipped)');
saveFigure(f,'cattle_ttc.png');

f=makeFigure; plot(time,r.log.ego(:,4),'b','LineWidth',1.5); grid on;
xlabel('Time (s)'); ylabel('Ego speed (m/s)');
title('Cattle crossing: closed-loop speed and braking');
saveFigure(f,'cattle_speed.png');

labels={'LOW','CAUTION','HIGH','CRITICAL'};
level=zeros(numel(time),1);
for j=1:numel(time)
    level(j)=find(strcmp(labels,r.log.risk{j}),1);
end
f=makeFigure; stairs(time,level,'Color',[0.8 0.2 0.1], ...
    'LineWidth',1.6); grid on;
yticks(1:4); yticklabels(labels); ylim([0.7 4.3]);
xlabel('Time (s)'); ylabel('Risk level');
title('Cattle crossing: logged risk assessment');
saveFigure(f,'cattle_risk.png');

    function fig=makeFigure
        fig=figure('Visible','off','Color','w', ...
            'Position',[50 50 1400 800]);
    end
    function saveFigure(fig,name)
        file=fullfile(folder,name);
        exportgraphics(fig,file,'Resolution',160);
        assert(isfile(file),'Figure export failed: %s',file);
        generated{end+1,1}=file; %#ok<AGROW>
        close(fig);
    end
end
