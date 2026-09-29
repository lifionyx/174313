function plotSensorDebug(r,c,file)
folder=fileparts(file); if ~exist(folder,'dir'), mkdir(folder); end
validFrames=cellfun(@(s)isfield(s,'lidar') && s.lidar>0,r.log.sensors);
idx=find(validFrames & r.log.ego(:,1)>min(20,r.goalX/3),1);
if isempty(idx), idx=max(1,round(numel(r.log.time)/2)); end
ego=r.log.ego(idx,:); truth=r.log.actors{idx}; tracks=r.log.tracks{idx};
pred=sih.predictActors(tracks,c);
f=figure('Visible','off','Color','w'); hold on; grid on; axis equal;
plot(nan,nan,'bs','MarkerFaceColor','b','DisplayName','Ego');
plot(nan,nan,'ko','DisplayName','Ground truth');
plot(nan,nan,'rx','DisplayName','Camera/radar track');
plot(nan,nan,'r:','DisplayName','4 s prediction');
plot(nan,nan,'g.','DisplayName','Lidar geometry');
sensor=r.log.sensors{idx};
if isfield(sensor,'lidarOccupied') && ~isempty(sensor.lidarOccupied)
    plot(sensor.lidarOccupied(:,1),sensor.lidarOccupied(:,2),'.', ...
        'Color',[0.3 0.7 0.3],'MarkerSize',6,'HandleVisibility','off');
end
plot(ego(1),ego(2),'bs','MarkerFaceColor','b','MarkerSize',9, ...
    'HandleVisibility','off');
for k=1:numel(truth)
    plot(truth(k).x,truth(k).y,'ko','MarkerSize',9, ...
        'HandleVisibility','off');
end
for k=1:numel(tracks)
    plot(tracks(k).x,tracks(k).y,'rx','MarkerSize',10, ...
        'LineWidth',1.5,'HandleVisibility','off');
    plot(pred.actors(k).x,pred.actors(k).y,'r:', ...
        'HandleVisibility','off');
end
legend('Location','northeast');
xlabel('World x (m)'); ylabel('World y (m)');
xlim([max(0,ego(1)-5) min(r.goalX+15,ego(1)+35)]);
ylim([-r.roadHalfWidth-3 r.roadHalfWidth+3]);
title(sprintf('%s — t=%.1f s, %s',r.name,r.log.time(idx), ...
    r.log.behavior{idx}));
exportgraphics(f,file); close(f);
end
