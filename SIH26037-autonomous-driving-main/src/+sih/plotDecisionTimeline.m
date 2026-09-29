function plotDecisionTimeline(r,file)
folder=fileparts(file); if ~exist(folder,'dir'), mkdir(folder); end
f=figure('Visible','off','Color','w');
tiledlayout(2,1);
nexttile; hold on; grid on;
plot(r.log.time,r.log.ego(:,4),'b','LineWidth',1.5);
ttc=min(5,r.log.ttc); ttc(~isfinite(ttc))=5;
plot(r.log.time,ttc,'r','LineWidth',1);
legend('Speed (m/s)','TTC clipped at 5 s','Location','best');
title(sprintf('%s — speed and predicted risk',r.name));
ylabel('Speed / TTC');
nexttile; hold on; grid on;
labels={'CRUISE','CAUTION','YIELD','STOP','EMERGENCY_BRAKE'};
code=zeros(numel(r.log.behavior),1);
for k=1:numel(code)
    idx=find(strcmp(labels,r.log.behavior{k}),1);
    if ~isempty(idx), code(k)=idx; end
end
stairs(r.log.time,code,'k','LineWidth',1.4);
yticks(1:numel(labels)); yticklabels(labels);
xlabel('Simulation time (s)'); ylabel('Selected behavior');
exportgraphics(f,file); close(f);
end
