root=fileparts(fileparts(mfilename('fullpath'))); addpath(root); setup_project;
load_system('vehdynlibeom');
name='SIH_VDB_probe'; if bdIsLoaded(name), close_system(name,0); end
new_system(name);
source='vehdynlibeom/Vehicle Body 3DOF Single Track';
block=[name '/Vehicle Body 3DOF'];
add_block(source,block,'Position',[150 100 360 320]);
for mode={'External longitudinal velocity','External longitudinal forces'}
    set_param(block,'inputMode',mode{1});
    fprintf('\nMode: %s\n',mode{1});
    fprintf('MaskDisplay: %s\n',get_param(block,'MaskDisplay'));
    try
        icon=autosharedicon('vehdynliblat3dof',block,8);
        fprintf('Input labels: %s\n',strjoin(string(icon.input),' | '));
        fprintf('Output labels: %s\n',strjoin(string(icon.output),' | '));
    catch ME
        fprintf('Icon labels unavailable: %s\n',ME.message);
    end
    pc=get_param(block,'PortConnectivity');
    for k=1:numel(pc)
        fprintf('Port %d Type=%s Position=%s\n',k, ...
            string(pc(k).Type),mat2str(pc(k).Position));
    end
    inputs=find_system(block,'SearchDepth',1,'BlockType','Inport');
    outputs=find_system(block,'SearchDepth',1,'BlockType','Outport');
    fprintf('Inputs: %s\n',strjoin(string(inputs),' | '));
    fprintf('Outputs: %s\n',strjoin(string(outputs),' | '));
end
close_system(name,0);
