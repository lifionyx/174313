function [tracks,info]=observe(truth,ego,t,c,prior,suite)
% Truth mode makes the deterministic stack debuggable; never call it sensor fusion.
if strcmp(c.perceptionMode,'truth')
    tracks=truth; info=struct('mode','truth','camera',0,'radar',0,'lidar',0);
    return;
end
[meas,info]=suite.measure(truth,ego,t);
tracks=sih.fuseMeasurements(meas,prior,t,c);
% Lidar obstacle surfaces corroborate object tracks and tighten position
% uncertainty only when point geometry agrees with the track location.
if ~isempty(info.lidarOccupied)
    for k=1:numel(tracks)
        dist=hypot(info.lidarOccupied(:,1)-tracks(k).x, ...
            info.lidarOccupied(:,2)-tracks(k).y);
        if any(dist<2.5)
            tracks(k).cov=max(0.05,0.5*tracks(k).cov(1,1))*eye(2);
            tracks(k).confidence=min(1,tracks(k).confidence+0.1);
        end
    end
end
end
