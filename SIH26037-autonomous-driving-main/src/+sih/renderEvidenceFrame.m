function renderEvidenceFrame(r,idx,kind,file,c,f,resolution)
% Render only quantities recorded or recomputed from an executed run.
if nargin<6 || isempty(f)
    f=figure('Visible','off','Color','w','Position',[40 40 1600 900]);
    closeFigure=true;
else
    closeFigure=false;
end
if nargin<7, resolution=160; end
clf(f);
tl=tiledlayout(f,2,3,'Padding','compact','TileSpacing','compact');
ax=nexttile(tl,1,[2 2]); hold(ax,'on'); grid(ax,'on'); axis(ax,'equal');
ego=r.log.ego(idx,:); t=r.log.time(idx);
rectangle(ax,'Position',[0,-r.roadHalfWidth,r.goalX+10, ...
    2*r.roadHalfWidth],'FaceColor',[0.94 0.94 0.94], ...
    'EdgeColor',[0.3 0.3 0.3]);
plot(ax,r.log.ego(1:idx,1),r.log.ego(1:idx,2), ...
    'Color',[0.1 0.25 0.85],'LineWidth',2.5);
info=r.log.plannerInfo{idx};
if strcmp(kind,'planning') && ~isempty(info) && isfield(info,'candidates')
    for k=1:numel(info.candidates)
        p=info.candidates(k);
        if p.accepted, color=[0.4 0.75 0.55]; style='-';
        else, color=[0.72 0.72 0.72]; style='--'; end
        plot(ax,p.x,p.y,'LineStyle',style,'Color',color, ...
            'LineWidth',0.8);
    end
end
plan=r.log.paths{idx};
plot(ax,plan.x,plan.y,'Color',[0 0.75 0.9],'LineWidth',2.2);
truth=r.log.actors{idx};
for k=1:numel(truth)
    a=truth(k); theta=linspace(0,2*pi,40);
    plot(ax,a.x+a.radius*cos(theta),a.y+a.radius*sin(theta), ...
        'Color',[0.15 0.15 0.15],'LineWidth',1.5);
    text(ax,a.x+0.4,a.y+0.5,strrep(a.type,'_',' '), ...
        'Color',[0.15 0.15 0.15],'FontSize',8,'Interpreter','none');
end
tracks=r.log.tracks{idx};
pred=sih.predictActors(tracks,c);
for k=1:numel(tracks)
    a=tracks(k);
    plot(ax,a.x,a.y,'rx','MarkerSize',9,'LineWidth',1.7);
    if a.x>ego(1)-15 && a.x<ego(1)+55
        plot(ax,pred.actors(k).x,pred.actors(k).y,':', ...
            'Color',[0.85 0.3 0.25],'LineWidth',1.3);
        if any(strcmp(kind,{'prediction','highest_risk','interaction'}))
            for j=[min(6,numel(pred.times)),min(16,numel(pred.times))]
                radius=pred.actors(k).radius(j);
                theta=linspace(0,2*pi,35);
                plot(ax,pred.actors(k).x(j)+radius*cos(theta), ...
                    pred.actors(k).y(j)+radius*sin(theta),':', ...
                    'Color',[0.9 0.55 0.5]);
            end
        end
    end
end
sensor=r.log.sensors{idx};
if isfield(sensor,'lidarOccupied') && ~isempty(sensor.lidarOccupied)
    pts=sensor.lidarOccupied;
    plot(ax,pts(:,1),pts(:,2),'.','Color',[0.15 0.6 0.25], ...
        'MarkerSize',5);
end
corners=[c.egoLength/2,-c.egoWidth/2; ...
    c.egoLength/2,c.egoWidth/2; -c.egoLength/2,c.egoWidth/2; ...
    -c.egoLength/2,-c.egoWidth/2];
R=[cos(ego(3)) -sin(ego(3));sin(ego(3)) cos(ego(3))];
body=(R*corners')'+ego(1:2);
patch(ax,body(:,1),body(:,2),[0.1 0.3 0.9], ...
    'EdgeColor',[0 0 0.5],'LineWidth',1.3);
xline(ax,r.goalX,'Color',[0.1 0.55 0.2],'LineStyle','--');
if strcmp(kind,'initial')
    left=0; right=min(r.goalX+8,55);
elseif strcmp(kind,'final')
    left=max(0,r.goalX-45); right=r.goalX+8;
else
    left=max(0,ego(1)-10); right=min(r.goalX+10,ego(1)+45);
end
xlim(ax,[left right]); ylim(ax,[-r.roadHalfWidth-3 r.roadHalfWidth+3]);
xlabel(ax,'World x (m)'); ylabel(ax,'World y (m)');
title(ax,'Actual ego path, tracks, prediction, and selected plan');

axInfo=nexttile(tl,3); axis(axInfo,'off');
ttc=r.log.ttc(idx);
if isfinite(ttc), ttcText=sprintf('%.2f s',ttc);
else, ttcText='not defined'; end
observed=r.log.ttc(1:idx); observed=observed(isfinite(observed));
if isempty(observed), minTtcText='not defined';
else, minTtcText=sprintf('%.2f s',min(observed)); end
risk=r.log.risk{idx};
lastPlan=find(r.log.latencyMs(1:idx)>0,1,'last');
if isempty(lastPlan), latency=nan; else, latency=r.log.latencyMs(lastPlan); end
if isfield(sensor,'camera')
    counts=sprintf('Camera %d | Radar %d | Lidar %d pts', ...
        sensor.camera,sensor.radar,sensor.lidar);
else
    counts='Truth perception mode';
end
lines={sprintf('Time             %.1f s',t), ...
    sprintf('Behavior         %s',r.log.behavior{idx}), ...
    sprintf('Risk             %s',risk), ...
    sprintf('Speed            %.2f m/s',ego(4)), ...
    sprintf('TTC now          %s',ttcText), ...
    sprintf('Minimum TTC      %s',minTtcText), ...
    sprintf('Clearance        %.2f m',r.log.clearance(idx)), ...
    sprintf('Last replan      %.1f ms',latency), ...
    sprintf('Tracks           %d',numel(tracks)),counts};
for j=1:numel(lines)
    text(axInfo,0.02,1.02-j*0.092,lines{j}, ...
        'Units','normalized','FontSize',11,'Interpreter','none');
end
axTrace=nexttile(tl,6); hold(axTrace,'on'); grid(axTrace,'on');
time=r.log.time(1:idx);
plot(axTrace,time,r.log.ego(1:idx,4),'b','LineWidth',1.5);
ttcTrace=r.log.ttc(1:idx); ttcTrace(~isfinite(ttcTrace))=5;
plot(axTrace,time,min(5,ttcTrace),'r','LineWidth',1);
plot(axTrace,t,ego(4),'bo','MarkerFaceColor','b');
legend(axTrace,{'Speed','TTC (cap 5 s)'},'Location','best');
xlabel(axTrace,'Time (s)'); ylabel(axTrace,'m/s or s');
sgtitle(tl,sprintf('%s | %s | t=%.1f s',r.name, ...
    strrep(kind,'_',' '),t),'Interpreter','none');
folder=fileparts(file); if ~exist(folder,'dir'), mkdir(folder); end
exportgraphics(f,file,'Resolution',resolution);
if closeFigure, close(f); end
end
