classdef SensorSuite < handle
    % Installed-toolbox sensor generators; no truth is returned to the planner.
    properties
        egoActor
        sceneActors
        camera
        radar
        lidar
        scenario
        config
        roadHalfWidth
        dropoutCamera = 0
        dropoutRadar = 0
        cameraDropped = 0
        radarDropped = 0
        cameraOpportunities = 0
        radarOpportunities = 0
        dropoutStream
    end
    methods
        function obj=SensorSuite(sc,c,variation)
            obj.scenario=sc.backend; obj.config=c;
            obj.roadHalfWidth=sc.roadHalfWidth;
            if nargin>=3 && ~isempty(variation)
                if strcmp(variation.kind,'camera_dropout'), obj.dropoutCamera=0.1; end
                if strcmp(variation.kind,'radar_dropout'), obj.dropoutRadar=0.1; end
                obj.dropoutStream=RandStream('mt19937ar','Seed',variation.seed+1009*sc.id);
            end
            obj.egoActor=vehicle(obj.scenario,'Position',[0 0 0], ...
                'Length',c.egoLength,'Width',c.egoWidth,'ClassID',1);
            obj.sceneActors=cell(numel(sc.actors),1);
            for k=1:numel(sc.actors)
                a=sc.actors(k); classID=1;
                if strcmp(a.type,'pedestrian'), classID=4;
                elseif strcmp(a.type,'two_wheeler'), classID=3; end
                if classID==1
                    obj.sceneActors{k}=vehicle(obj.scenario,'ClassID',classID, ...
                        'Length',a.length,'Width',a.width,'Position',[-1000 1000 0]);
                else
                    obj.sceneActors{k}=actor(obj.scenario,'ClassID',classID, ...
                        'Length',a.length,'Width',a.width,'Position',[-1000 1000 0]);
                end
            end
            profiles=actorProfiles(obj.scenario);
            obj.camera=visionDetectionGenerator('SensorIndex',1, ...
                'UpdateInterval',c.sensorPeriod(1),'MaxRange',c.sensorRange(1), ...
                'ActorProfiles',profiles,'SensorLocation',[1.5 0], ...
                'FalsePositivesPerImage',0);
            obj.radar=drivingRadarDataGenerator('SensorIndex',2, ...
                'UpdateRate',1/c.sensorPeriod(2), ...
                'MountingLocation',[1.5 0 0.5], ...
                'FieldOfView',[120 10],'RangeLimits',[0 c.sensorRange(2)]);
            obj.lidar=lidarPointCloudGenerator('SensorIndex',3, ...
                'UpdateInterval',1,'MaxRange',c.sensorRange(3), ...
                'SensorLocation',[1.5 0],'HasRoadsInputPort',false, ...
                'HasNoise',true,'AzimuthResolution',3, ...
                'ElevationResolution',5,'AzimuthLimits',[-60 60], ...
                'ElevationLimits',[-10 5],'ActorProfiles',profiles);
            obj.lidar.EgoVehicleActorID=obj.egoActor.ActorID;
        end
        function [meas,info]=measure(obj,truth,ego,t)
            obj.egoActor.Position=[ego(1:2) 0];
            obj.egoActor.Yaw=rad2deg(ego(3));
            obj.egoActor.Velocity=[ego(4)*cos(ego(3)) ego(4)*sin(ego(3)) 0];
            for k=1:numel(obj.sceneActors)
                a=obj.sceneActors{k}; idx=find([truth.id]==k,1);
                if isempty(idx)
                    a.Position=[-1000 1000 0]; a.Velocity=[0 0 0];
                else
                    a.Position=[truth(idx).x truth(idx).y 0];
                    a.Velocity=[truth(idx).vx truth(idx).vy 0];
                end
            end
            poses=targetPoses(obj.egoActor);
            [cdets,nc]=obj.camera(poses,t);
            [rdets,nr]=obj.radar(poses,t);
            [cloud,valid,clusters]=obj.lidar(poses,t);
            obj.cameraOpportunities=obj.cameraOpportunities+nc;
            obj.radarOpportunities=obj.radarOpportunities+nr;
            if obj.dropoutCamera>0 && nc>0
                keep=rand(obj.dropoutStream,nc,1)>=obj.dropoutCamera;
                obj.cameraDropped=obj.cameraDropped+sum(~keep);
                cdets=cdets(keep); nc=numel(cdets);
            end
            if obj.dropoutRadar>0 && nr>0
                keep=rand(obj.dropoutStream,nr,1)>=obj.dropoutRadar;
                obj.radarDropped=obj.radarDropped+sum(~keep);
                rdets=rdets(keep); nr=numel(rdets);
            end
            meas=repmat(struct('x',0,'y',0,'vx',0,'vy',0, ...
                'source','','type','unknown'),0,1);
            for k=1:nc
                p=cdets{k}.Measurement;
                world=sih.egoToWorld(ego,p(1:2)');
                if abs(world(2))>obj.roadHalfWidth+3, continue; end
                meas(end+1)=struct('x',world(1),'y',world(2),'vx',nan, ...
                    'vy',nan,'source','camera','type','unknown'); %#ok<AGROW>
            end
            for k=1:nr
                p=rdets{k}.Measurement;
                if numel(p)<2 || ~all(isfinite(p(1:2))), continue; end
                world=sih.egoToWorld(ego,p(1:2)');
                if hypot(world(1)-ego(1),world(2)-ego(2))>obj.config.sensorRange(2)
                    continue;
                end
                if abs(world(2))>obj.roadHalfWidth+3, continue; end
                meas(end+1)=struct('x',world(1),'y',world(2),'vx',nan, ...
                    'vy',nan,'source','radar','type','unknown'); %#ok<AGROW>
            end
            npoints=0; occupied=zeros(0,2);
            if valid
                xyz=reshape(cloud.Location,[],3);
                xyz=xyz(all(isfinite(xyz),2),:);
                npoints=size(xyz,1);
                if npoints>0
                    % Point cloud is in the ego frame. Retain obstacle
                    % geometry separately from camera/radar object tracks.
                    R=[cos(ego(3)) -sin(ego(3)); ...
                        sin(ego(3)) cos(ego(3))];
                    occupied=(R*xyz(:,1:2)')'+ego(1:2);
                end
            end
            info=struct('mode','synthetic_fusion','camera',nc,'radar',nr, ...
                'lidar',npoints,'lidarClusters',size(clusters,1), ...
                'lidarOccupied',occupied,'cameraDropped',obj.cameraDropped, ...
                'radarDropped',obj.radarDropped, ...
                'cameraOpportunities',obj.cameraOpportunities, ...
                'radarOpportunities',obj.radarOpportunities);
        end
    end
end
