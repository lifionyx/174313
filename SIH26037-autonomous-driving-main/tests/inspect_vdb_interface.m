root=fileparts(fileparts(mfilename('fullpath'))); addpath(root); setup_project;
load_system('vehdynlibeom');
blocks=find_system('vehdynlibeom','SearchDepth',1,'Type','Block');
disp(blocks(contains(string(blocks),'Vehicle Body 3DOF')));
name='vehdynlibeom/Vehicle Body 3DOF Single Track';
fprintf('Block exists: %d\n',getSimulinkBlockHandle(name)>0);
if getSimulinkBlockHandle(name)>0
    fprintf('MaskType: %s\n',get_param(name,'MaskType'));
    masks=get_param(name,'MaskNames');
    values=get_param(name,'MaskValues');
    for k=1:numel(masks)
        if contains(lower(masks{k}),{'track','axle','steer','mass', ...
                'stiff','position','yaw','longitudinal','lateral'})
            fprintf('%s=%s\n',masks{k},values{k});
        end
    end
    ports=get_param(name,'PortHandles');
    for key={'Inport','Outport'}
        handles=ports.(key{1});
        for j=1:numel(handles)
            fprintf('%s %d name=%s\n',key{1},j, ...
                get_param(handles(j),'Name'));
        end
    end
end
load_system('vehdynlibsim3dcore');
scene='vehdynlibsim3dcore/Simulation 3D Scene Configuration';
fprintf('Scene block %d\n',getSimulinkBlockHandle(scene)>0);
if getSimulinkBlockHandle(scene)>0
    mask=get_param(scene,'MaskNames'); values=get_param(scene,'MaskValues');
    for k=1:numel(mask)
        if contains(lower(mask{k}),{'scene','source','camera','sample','project'})
            fprintf('%s=%s\n',mask{k},values{k});
        end
    end
end
