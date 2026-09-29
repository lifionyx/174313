function runAllTests(mode)
if nargin<1, mode='fresh'; end
assert(ismember(mode,{'fresh','resume'}),'Mode must be fresh or resume');
root=fileparts(mfilename('fullpath'));
addpath(root); setup_project;
addpath(fullfile(root,'tests','benchmark'));
out=fullfile(root,'tests','benchmark','results');
if ~exist(out,'dir'), mkdir(out); end
diary(fullfile(out,'benchmark_cli.log')); cleanup=onCleanup(@()diary('off')); %#ok<NASGU>
fprintf('COMMAND=matlab -batch "runAllTests%s"\n', ...
    ternary(strcmp(mode,'resume'),"('resume')",''));
fprintf('MATLAB=%s | release=%s | root=%s\n',version,version('-release'),root);
assert(strcmp(version('-release'),'2026b'),'R2026b is required');
assert(license('test','Simulink') && ...
    license('test','Automated_Driving_Toolbox') && ...
    license('test','Vehicle_Dynamics_Blockset'), ...
    'Required VDB/Simulink/Automated Driving licenses are unavailable');
manifestFile=fullfile(out,'manifest.mat');
if exist(manifestFile,'file')
    s=load(manifestFile,'manifest'); manifest=s.manifest;
    assert(strcmp(manifest.codeFingerprint,codeFingerprint(root)) && ...
        strcmp(manifest.matlabRelease,version('-release')) && ...
        strcmp(manifest.thresholdVersion,'user-proposed-strict-v1'), ...
        'Frozen manifest differs from code, release, or threshold version');
else
    manifest=makeManifest(root);
    save(manifestFile,'manifest');
    writetable(struct2table(manifest.cases),fullfile(out,'manifest_cases.csv'));
end
assert(numel(manifest.cases)==60 && ...
    isequal([manifest.cases.index],1:60),'Invalid frozen 60-case manifest');
benchmarkTests(manifest);
modelPath=build_vdb_closed_loop(1,1,false,true);
fprintf('MODEL=%s\n',modelPath);
% An extra unscored smoke run confirms the model, sensors and case injection.
smokeFile=fullfile(out,['smoke_validation_' manifest.codeFingerprint(1:12) '.mat']);
if ~exist(smokeFile,'file')
    [smokeRow,smokeDetail,smokeEgo,smokeDecisions]= ...
        runCase(manifest.cases(1),manifest,modelPath);
    save(smokeFile,'smokeRow','smokeDetail', ...
        'smokeEgo','smokeDecisions');
    assert(smokeRow.valid,'One-case VDB smoke was invalid: %s', ...
        smokeRow.invalidReason);
    fprintf('VDB smoke: %s, outcome=%s, ego samples=%d, decision samples=%d\n', ...
        smokeRow.status,smokeRow.rawOutcome,numel(smokeEgo.Time), ...
        numel(smokeDecisions.Time));
end
rows=repmat(emptyBenchmarkRow(manifest.cases(1),manifest),60,1);
for k=1:60
    v=manifest.cases(k);
    file=fullfile(out,sprintf('run_%02d_%s.mat',k,v.caseId));
    if exist(file,'file')
        assert(strcmp(mode,'resume'), ...
            'Existing per-run log found; use runAllTests(''resume'')');
        saved=load(file);
        verifySaved(saved,v,manifest);
        row=saved.row;
        fprintf('%02d %s %s: strict_gate=%s [verified resume] outcome=%s\n', ...
            k,v.scenarioName,v.caseId,row.status,row.rawOutcome);
    else
        [row,detail,vdbEgo,vdbDecisions,exception]=executeCase(v,manifest,modelPath);
        log=struct('variation',v,'codeFingerprint',manifest.codeFingerprint, ...
            'release',manifest.matlabRelease, ...
            'thresholdVersion',manifest.thresholdVersion, ...
            'row',row,'detail',detail,'vdbEgo',vdbEgo, ...
            'vdbDecisions',vdbDecisions,'exception',exception, ...
            'completedUTC',char(datetime('now','TimeZone','UTC', ...
            'Format','yyyy-MM-dd HH:mm:ss Z')));
        save(file,'-struct','log','-v7.3');
        fprintf('%02d %s %s: strict_gate=%s outcome=%s C=%g TTC=%.6g L95=%.6g J=%.6g %s\n', ...
            k,v.scenarioName,v.caseId,row.status,row.rawOutcome, ...
            row.collisionEpisodes,row.minimumTTC,row.p95ReplanMs, ...
            row.maxAbsPhysicalJerk,row.invalidReason);
    end
    rows(k)=row;
end
close_system('SIH_VDB_Benchmark',0);
writeBenchmarkReports(rows,manifest,out);
fprintf('CAMPAIGN=%d/60 executed, %d/60 valid, %d/60 goals, %d collision episodes\n', ...
    sum(~strcmp({rows.rawOutcome},'not_run')),sum([rows.valid]), ...
    sum([rows.completed]),sum([rows.collisionEpisodes]));
fprintf('STRICT GATES=%d/60 pass all, %d/60 miss at least one, %d/60 invalid\n', ...
    sum([rows.Overall_PASS]),sum(strcmp({rows.status},'FAIL')), ...
    sum(strcmp({rows.status},'INVALID')));
if any(~[rows.valid])
    error('SIH:BenchmarkInvalid','One or more benchmark cases were invalid');
end
end

function [row,detail,e,d,exception]=executeCase(v,m,modelPath)
e=[]; d=[]; exception='';
try
    [row,detail,e,d]=runCase(v,m,modelPath);
catch ME
    row=emptyBenchmarkRow(v,m);
    row.rawOutcome='simulation_exception';
    row.invalidReason=sprintf('%s: %s',ME.identifier,ME.message);
    detail=struct('exceptionReport',getReport(ME,'extended','hyperlinks','off'));
    exception=detail.exceptionReport;
end
end

function verifySaved(saved,v,m)
needed={'variation','codeFingerprint','release','thresholdVersion', ...
    'row','detail','vdbEgo','vdbDecisions','exception'};
assert(all(isfield(saved,needed)) && isequaln(saved.variation,v) && ...
    strcmp(saved.codeFingerprint,m.codeFingerprint) && ...
    strcmp(saved.release,m.matlabRelease) && ...
    strcmp(saved.thresholdVersion,m.thresholdVersion) && ...
    saved.row.scenarioId==v.scenarioId && ...
    strcmp(saved.row.caseId,v.caseId),'Stale or corrupt per-run MAT log');
if ~isempty(saved.vdbEgo) && ~isempty(saved.vdbDecisions)
    sc=sih.makeScenario(v.scenarioId,sih.config('fast','synthetic_fusion'),v);
    [check,~]=scoreCase(saved.vdbEgo,saved.vdbDecisions,sc,v,m);
    fields={'status','valid','rawOutcome','collisionEpisodes','minimumTTC', ...
        'completed','p95ReplanMs','maxAbsPhysicalJerk','Overall_PASS'};
    for j=1:numel(fields)
        assert(isequaln(check.(fields{j}),saved.row.(fields{j})), ...
            'Saved benchmark score does not match raw log');
    end
else
    assert(strcmp(saved.row.rawOutcome,'simulation_exception') && ...
        ~isempty(saved.exception),'Unverifiable empty per-run log');
end
end

function s=ternary(cond,a,b)
if cond, s=a; else, s=b; end
end
