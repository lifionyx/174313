function [safe,clearance]=checkTrajectory(traj,pred,sc,c)
safe=true; clearance=inf;
if any(abs(traj.y)>sc.roadHalfWidth-c.egoWidth/2)
    safe=false; return;
end
if any(getOccupancy(sc.freeSpace,[traj.x(:) traj.y(:)])>0.5)
    safe=false; return;
end
for k=1:numel(pred.actors)
    a=pred.actors(k);
    ax=interp1(pred.times,a.x,traj.t,'linear','extrap');
    ay=interp1(pred.times,a.y,traj.t,'linear','extrap');
    ar=interp1(pred.times,a.radius,traj.t,'linear','extrap');
    d=hypot(traj.x-ax,traj.y-ay)-(ar+c.egoWidth/2);
    clearance=min(clearance,min(d));
    if any(d<0), safe=false; end
end
end
