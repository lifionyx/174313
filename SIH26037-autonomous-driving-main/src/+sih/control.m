function [steer,accel]=control(ego,traj,b,c,elapsed)
emergency=b.emergency || traj.accel==-c.emergencyDecel;
look=max(1.2,min(c.predHorizon,elapsed+1.2));
tx=interp1(traj.t,traj.x,look); ty=interp1(traj.t,traj.y,look);
alpha=atan2(ty-ego(2),tx-ego(1))-ego(3);
alpha=atan2(sin(alpha),cos(alpha));
L=max(2,hypot(tx-ego(1),ty-ego(2)));
steer=atan2(2*c.wheelbase*sin(alpha),L);
steer=max(-c.maxSteer,min(c.maxSteer,steer));
tv=interp1(traj.t,traj.v,look);
accel=max(-c.comfortDecel,min(c.maxAccel,1.5*(tv-ego(4))));
if strcmp(b.state,'STOP')
    accel=max(-c.comfortDecel,min(c.maxAccel,0.8*b.remaining-1.8*ego(4)));
end
if isfield(b,'roadHalfWidth')
    margin=b.roadHalfWidth-c.egoWidth/2-abs(ego(2));
    if margin<0.5 && sign(ego(2))*sin(ego(3))>0
        steer=-sign(ego(2))*c.maxSteer;
        accel=min(accel,(0.7-ego(4))/c.dt);
    end
end
if emergency, accel=-c.emergencyDecel; end
accel=max(-c.emergencyDecel,min(c.maxAccel,accel));
end
