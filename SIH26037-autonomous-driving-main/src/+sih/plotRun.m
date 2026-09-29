function plotRun(r,file)
folder=fileparts(file); if ~exist(folder,'dir'), mkdir(folder); end
f=figure('Visible','off','Color','w'); hold on; axis equal; grid on;
plot(r.log.ego(:,1),r.log.ego(:,2),'b-','LineWidth',2, ...
    'DisplayName','Ego driven path');
yline(r.roadHalfWidth,'k--'); yline(-r.roadHalfWidth,'k--');
for i=1:numel(r.log.actors)
    if mod(i,10)~=1, continue; end
    a=r.log.actors{i};
    for j=1:numel(a), plot(a(j).x,a(j).y,'rx','MarkerSize',6); end
end
for i=1:numel(r.log.paths)
    if mod(i,30)~=1, continue; end
    p=r.log.paths{i}; plot(p.x,p.y,'Color',[0.5 0.7 1]);
end
xline(r.goalX,'g--'); title(sprintf('%s — %s',r.name,r.outcome));
xlabel('World x (m)'); ylabel('World y (m)');
xlim([0 r.goalX+8]); ylim([-r.roadHalfWidth-2 r.roadHalfWidth+2]);
exportgraphics(f,file); close(f);
end
