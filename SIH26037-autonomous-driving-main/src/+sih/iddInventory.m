function files=iddInventory(datasetRoot,maxFiles)
% Small, read-only discovery entry point for a locally mounted IDD subset.
if nargin<2, maxFiles=1000; end
assert(isfolder(datasetRoot),'IDD root does not exist: %s',datasetRoot);
assert(maxFiles>0 && maxFiles==fix(maxFiles),'maxFiles must be positive integer');
queue={datasetRoot}; paths=cell(0,1); kinds=cell(0,1);
while ~isempty(queue) && numel(paths)<maxFiles
    folder=queue{1}; queue(1)=[];
    entries=dir(folder);
    for k=1:numel(entries)
        e=entries(k); if any(strcmp(e.name,{'.','..'})), continue; end
        full=fullfile(folder,e.name);
        if e.isdir
            queue{end+1}=full; %#ok<AGROW>
        else
            [~,~,ext]=fileparts(e.name); ext=lower(ext);
            if any(strcmp(ext,{'.png','.jpg','.jpeg','.bin','.pcd','.mat'}))
                paths{end+1,1}=full; kinds{end+1,1}=ext; %#ok<AGROW>
                if numel(paths)>=maxFiles, break; end
            end
        end
    end
end
files=table(paths,kinds,'VariableNames',{'path','extension'});
end
