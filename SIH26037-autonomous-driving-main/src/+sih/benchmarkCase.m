function variation=benchmarkCase(index)
% Read the frozen campaign specification used by the VDB autonomy block.
p=mfilename('fullpath'); root=fileparts(fileparts(fileparts(p)));
file=fullfile(root,'tests','benchmark','results','manifest.mat');
assert(exist(file,'file')==2,'SIH:MissingManifest', ...
    'Frozen benchmark manifest is missing: %s',file);
s=load(file,'manifest');
assert(isscalar(index) && index==fix(index) && index>=1 && ...
    index<=numel(s.manifest.cases),'SIH:BadCaseIndex');
variation=s.manifest.cases(index);
end
