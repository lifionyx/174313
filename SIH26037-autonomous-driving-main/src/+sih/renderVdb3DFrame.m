function renderVdb3DFrame(r,index,file,fig,resolution)
% Render 3D geometry at a state recorded by the VDB Simulink plant.
% Actors are scenario truth for visual evaluation; red lines are logged tracks.
if nargin<4 || isempty(fig)
    fig=figure('Visible','off','Color','w','Position',[30 30 1440 810]);
    closeFigure=true;
else
    closeFigure=false;
end
if nargin<5, resolution=120; end
index=max(1,min(numel(r.time),index));
persistent scenarioCache
if isempty(scenarioCache) || scenarioCache.id~=r.id
    scenarioCache=sih.makeScenario(r.id,sih.config('fast','synthetic_fusion'));
end
sc=scenarioCache;
t=r.time(index); ego=r.ego(index,:);
j=find(r.decisionTime<=t+1e-7,1,'last'); if isempty(j), j=1; end
d=r.decisions(j,:);
clf(fig); layout=tiledlayout(fig,2,3,'Padding','compact', ...
    'TileSpacing','compact');
ax=nexttile(layout,1,[2 2]); hold(ax,'on');
patch(ax,[-5 sc.length+8 sc.length+8 -5], ...
    [-22 -22 22 22],[0 0 0 0], ...
    [0.47 0.57 0.39],'EdgeColor','none');
patch(ax,[-5 sc.length+8 sc.length+8 -5], ...
    [-sc.roadHalfWidth -sc.roadHalfWidth ...
    sc.roadHalfWidth sc.roadHalfWidth], ...
    [0.03 0.03 0.03 0.03], ...
    [0.35 0.37 0.39],'EdgeColor',[0.2 0.2 0.2]);
plot3(ax,r.ego(1:index,1),r.ego(1:index,2), ...
    0.08+zeros(index,1),'Color',[0.15 0.7 1], ...
    'LineWidth',2.2);
actors=sih.actorStates(sc,t);
for k=1:numel(actors)
    a=actors(k);
    heading=atan2(a.vy,a.vx);
    if strcmp(a.type,'cattle')
        [sx,sy,sz]=sphere(15);
        surf(ax,a.x+1.1*sx,a.y+0.65*sy,1.05+0.7*sz, ...
            'FaceColor',[0.55 0.30 0.14],'EdgeColor','none');
    else
        color=[0.85 0.55 0.15];
        if strcmp(a.type,'pedestrian'), color=[0.9 0.18 0.18]; end
        if strcmp(a.type,'two_wheeler'), color=[0.75 0.2 0.55]; end
        drawBox(ax,a.x,a.y,heading,max(a.length,0.6), ...
            max(a.width,0.5),0.15,1.5,color);
    end
    text(ax,a.x,a.y,2.25,strrep(a.type,'_',' '), ...
        'Color',[0.15 0.1 0.1],'FontSize',8, ...
        'HorizontalAlignment','center');
end
drawBox(ax,ego(1),ego(2),ego(3),4.2,1.8,0.35,1.65, ...
    [0.1 0.3 0.88]);
drawBox(ax,ego(1)+0.2*cos(ego(3)), ...
    ego(2)+0.2*sin(ego(3)),ego(3),2.1,1.58,1.68,1.84, ...
    [0.08 0.12 0.22]);
plot3(ax,[ego(1) d(8)],[ego(2) d(9)],[0.2 0.2], ...
    'Color',[0 0.9 0.95],'LineWidth',2.6);
for k=1:min(4,round(d(10)))
    base=10+4*(k-1);
    tr=d(base+(1:4));
    plot3(ax,[tr(1) tr(1)+3*tr(3)], ...
        [tr(2) tr(2)+3*tr(4)],[1.8 1.8], ...
        'r:','LineWidth',1.4);
    plot3(ax,tr(1),tr(2),1.8,'rx','MarkerSize',9,'LineWidth',1.5);
end
plot3(ax,[sc.goalX sc.goalX],[-sc.roadHalfWidth sc.roadHalfWidth], ...
    [0.1 0.1],'g--','LineWidth',1.8);
view(ax,[-47 26]); axis(ax,'equal'); grid(ax,'on');
xlim(ax,[max(-5,ego(1)-12) min(sc.length+8,ego(1)+35)]);
ylim(ax,[-sc.roadHalfWidth-7 sc.roadHalfWidth+7]); zlim(ax,[0 8]);
xlabel(ax,'Road progress x (m)'); ylabel(ax,'Lateral y (m)');
zlabel(ax,'Height (m)');
title(ax,'3D geometry driven by the executed VDB vehicle state');

hud=nexttile(layout,3); axis(hud,'off');
behaviorLabels={'CRUISE','FOLLOW','YIELD','CAUTION','STOP', ...
    'PASS_OBSTACLE','MERGE','EMERGENCY_BRAKE'};
riskLabels={'LOW','CAUTION','HIGH','CRITICAL'};
b=label(behaviorLabels,d(4)); risk=label(riskLabels,d(5));
if d(6)>=99, ttc='undefined'; else, ttc=sprintf('%.2f s',d(6)); end
lines={sprintf('Time                 %.1f s',t), ...
    sprintf('VDB speed            %.2f m/s',ego(4)), ...
    sprintf('Behavior             %s',b), ...
    sprintf('Risk                 %s',risk), ...
    sprintf('Predicted TTC        %s',ttc), ...
    sprintf('Truth clearance      %.2f m',r.clearance(index)), ...
    sprintf('Replanning           %.1f ms',d(7)), ...
    sprintf('Camera/Radar/Lidar   %d / %d / %d', ...
        round(d(27)),round(d(28)),round(d(29))), ...
    sprintf('Tracked agents       %d',round(d(10)))};
for k=1:numel(lines)
    text(hud,0.02,1.03-k*0.10,lines{k},'Units','normalized', ...
        'FontSize',10,'Interpreter','none');
end
trace=nexttile(layout,6); hold(trace,'on'); grid(trace,'on');
plot(trace,r.time(1:index),r.ego(1:index,4), ...
    'Color',[0.1 0.35 0.85],'LineWidth',1.7);
plot(trace,t,ego(4),'bo','MarkerFaceColor','b');
xlabel(trace,'Time (s)'); ylabel(trace,'Speed (m/s)');
title(trace,'Measured VDB longitudinal speed');
sgtitle(layout,sprintf('%s | VDB + synthetic fusion | %.1f s', ...
    r.name,t),'Interpreter','none');
if ~isempty(file)
    folder=fileparts(file); if ~exist(folder,'dir'), mkdir(folder); end
    exportgraphics(fig,file,'Resolution',resolution);
end
if closeFigure, close(fig); end
end

function drawBox(ax,x,y,yaw,lengthM,widthM,z0,z1,color)
base=[lengthM/2 -widthM/2;lengthM/2 widthM/2; ...
    -lengthM/2 widthM/2;-lengthM/2 -widthM/2];
R=[cos(yaw) -sin(yaw);sin(yaw) cos(yaw)];
xy=(R*base')'+[x y];
vertices=[xy z0+zeros(4,1);xy z1+zeros(4,1)];
faces=[1 2 3 4;5 6 7 8;1 2 6 5;2 3 7 6; ...
    3 4 8 7;4 1 5 8];
patch(ax,'Vertices',vertices,'Faces',faces,'FaceColor',color, ...
    'FaceAlpha',0.93,'EdgeColor',[0.13 0.13 0.13]);
end

function txt=label(labels,index)
index=round(index);
if index>=1 && index<=numel(labels), txt=labels{index};
else, txt='UNKNOWN'; end
end
