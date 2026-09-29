root=fileparts(fileparts(mfilename('fullpath')));
files=[dir(fullfile(root,'*.m')); ...
    dir(fullfile(root,'src','+sih','*.m')); ...
    dir(fullfile(root,'tests','*.m'))];
diagnostics=0;
for k=1:numel(files)
    path=fullfile(files(k).folder,files(k).name);
    m=checkcode(path,'-id');
    diagnostics=diagnostics+numel(m);
    if ~isempty(m)
        for j=1:numel(m)
            fprintf('%s:%d [%s] %s\n',files(k).name,m(j).line, ...
                m(j).id,m(j).message);
        end
        msg=lower(string({m.message}));
        if any(contains(msg,'parse error') | contains(msg,'syntax error'))
            error('SIH:Parse','Syntax issue in %s',path);
        end
    end
end
fprintf('Code Analyzer parsed %d MATLAB files; %d diagnostics.\n', ...
    numel(files),diagnostics);
