function exportVideo(r,file)
% Reproducible top-down time-lapse from actual closed-loop log.
folder=fileparts(file); if ~exist(folder,'dir'), mkdir(folder); end
writer=VideoWriter(file,'MPEG-4'); writer.FrameRate=10; open(writer);
temp=fullfile(folder,'_video_frame.png');
f=figure('Visible','off','Color','w','Position',[100 100 960 540]);
cleanup=onCleanup(@()closeVideo(writer,f,temp));
stride=max(1,round(0.5/mean(diff(r.log.time))));
indices=unique([1:stride:numel(r.log.time),numel(r.log.time)]);
for i=indices
    clf(f); ax=axes(f); hold(ax,'on'); grid(ax,'on'); axis(ax,'equal');
    yline(ax,r.roadHalfWidth,'k--');
    yline(ax,-r.roadHalfWidth,'k--');
    plot(ax,r.log.ego(1:i,1),r.log.ego(1:i,2), ...
        'b-','LineWidth',2);
    plot(ax,r.log.ego(i,1),r.log.ego(i,2),'bs', ...
        'MarkerFaceColor','b','MarkerSize',9);
    p=r.log.paths{i};
    plot(ax,p.x,p.y,'c-','LineWidth',1);
    a=r.log.actors{i};
    for k=1:numel(a)
        rectangle(ax,'Position',[a(k).x-a(k).radius, ...
            a(k).y-a(k).radius,2*a(k).radius,2*a(k).radius], ...
            'Curvature',[1 1],'EdgeColor','r','LineWidth',1.5);
    end
    xline(ax,r.goalX,'g--');
    xlim(ax,[0 r.goalX+8]);
    ylim(ax,[-r.roadHalfWidth-2 r.roadHalfWidth+2]);
    title(ax,sprintf('%s | t=%.1f s | %s',r.name, ...
        r.log.time(i),r.log.behavior{i}));
    xlabel(ax,'World x (m)'); ylabel(ax,'World y (m)');
    exportgraphics(f,temp,'Resolution',100);
    frame=imread(temp); frame=imresize(frame,[540 960]);
    writeVideo(writer,frame);
end
clear cleanup;
end

function closeVideo(writer,f,temp)
try, close(writer); catch, end
if isgraphics(f), close(f); end
if isfile(temp), delete(temp); end
end
