function ego=stepVehicle(ego,steer,accel,c)
v=max(0,min(c.maxSpeed,ego(4)+accel*c.dt));
vmean=(ego(4)+v)/2;
ego(1)=ego(1)+vmean*cos(ego(3))*c.dt;
ego(2)=ego(2)+vmean*sin(ego(3))*c.dt;
ego(3)=atan2(sin(ego(3)+vmean*tan(steer)/c.wheelbase*c.dt), ...
    cos(ego(3)+vmean*tan(steer)/c.wheelbase*c.dt));
ego(4)=v;
end
