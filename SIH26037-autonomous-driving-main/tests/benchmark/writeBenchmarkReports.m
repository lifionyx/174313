function writeBenchmarkReports(rows,manifest,out)
% Write only values computed from this campaign's per-run MAT files.
writeFullPrecisionCSV(fullfile(out,'SIH26037_60_cases.csv'),rows);
blank=struct('scenarioId',0,'scenarioName','','planned',12, ...
    'executed',0,'valid',0,'completed',0,'passed',0,'failed',0, ...
    'invalid',0,'collisionEpisodes',0,'worstTTC',nan, ...
    'worstP95LatencyMs',nan,'worstMaxJerk',nan,'status','INVALID');
summary=repmat(blank,5,1);
for sid=1:5
    rr=rows([rows.scenarioId]==sid);
    s=blank; s.scenarioId=sid; s.scenarioName=rr(1).scenarioName;
    s.executed=sum(~strcmp({rr.rawOutcome},'not_run'));
    s.valid=sum([rr.valid]); s.completed=sum([rr.completed]);
    s.passed=sum([rr.Overall_PASS]);
    s.failed=sum(strcmp({rr.status},'FAIL'));
    s.invalid=sum(strcmp({rr.status},'INVALID'));
    cc=[rr.collisionEpisodes]; s.collisionEpisodes=sum(cc(isfinite(cc)));
    ttc=[rr.minimumTTC]; ttc=ttc(isfinite(ttc));
    if ~isempty(ttc), s.worstTTC=min(ttc); end
    lat=[rr.p95ReplanMs]; lat=lat(isfinite(lat));
    if ~isempty(lat), s.worstP95LatencyMs=max(lat); end
    jerk=[rr.maxAbsPhysicalJerk]; jerk=jerk(isfinite(jerk));
    if ~isempty(jerk), s.worstMaxJerk=max(jerk); end
    if s.executed<12 || s.invalid>0, s.status='INVALID';
    elseif s.passed==12, s.status='PASS'; else, s.status='FAIL'; end
    summary(sid)=s;
end
writeFullPrecisionCSV(fullfile(out,'SIH26037_5_scenarios.csv'),summary);
writeMarkdown(fullfile(out,'BENCHMARK_REPORT.md'),rows,summary,manifest);
makeBenchmarkImage(rows,summary,manifest, ...
    fullfile(out,'SIH26037_Benchmark_3x2.png'));
info=imfinfo(fullfile(out,'SIH26037_Benchmark_3x2.png'));
assert(info.Width==2400 && info.Height==1600,'Benchmark image dimensions mismatch');
assert(numel(rows)==60 && numel(summary)==5);
end

function writeFullPrecisionCSV(file,records)
fields=fieldnames(records);
fid=fopen(file,'w'); assert(fid>0,'Cannot open %s',file);
closer=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s\n',strjoin(fields,','));
for i=1:numel(records)
    values=cell(1,numel(fields));
    for k=1:numel(fields)
        value=records(i).(fields{k});
        if islogical(value)
            values{k}=sprintf('%d',value);
        elseif isnumeric(value)
            values{k}=sprintf('%.17g',value);
        else
            value=char(string(value));
            values{k}=['"' strrep(value,'"','""') '"'];
        end
    end
    fprintf(fid,'%s\n',strjoin(values,','));
end
end

function writeMarkdown(file,rows,summary,m)
fid=fopen(file,'w'); assert(fid>0); closer=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'# SIH26037 strict synthetic VDB benchmark\n\n');
fprintf(fid,'Campaign created UTC: %s. MATLAB %s (%s).\n\n', ...
    m.createdUTC,m.matlabVersion,m.matlabRelease);
fprintf(fid,'Code fingerprint: `%s`; Git commit: `%s`.\n\n', ...
    m.codeFingerprint,m.gitCommit);
collisions=[rows.collisionEpisodes];
fprintf(fid,'**Execution and outcomes:** %d/60 executed; %d/60 valid; %d/60 reached the goal; %d collision episodes.\n\n', ...
    sum(~strcmp({rows.rawOutcome},'not_run')),sum([rows.valid]), ...
    sum([rows.completed]),sum(collisions(isfinite(collisions))));
fprintf(fid,'**Strict-gate result:** %d/60 passed all gates; %d/60 missed at least one gate; %d/60 invalid.\n\n', ...
    sum([rows.Overall_PASS]),sum(strcmp({rows.status},'FAIL')), ...
    sum(strcmp({rows.status},'INVALID')));
fprintf(fid,['These are user-proposed gates, not official SIH acceptance limits. ', ...
    'A `FAIL` status means a valid, executed case missed at least one performance gate; ', ...
    'it does not mean the simulation failed to run or collided. ', ...
    'Read the outcome and individual gate columns to see which result occurred.\n\n']);
fprintf(fid,['Individual gate counts: collision %d/60, predicted TTC %d/60, ', ...
    'completion %d/60, replanning latency %d/60, physical jerk %d/60.\n\n'], ...
    sum([rows.collisionPASS]),sum([rows.ttcPASS]), ...
    sum([rows.completionPASS]),sum([rows.latencyPASS]), ...
    sum([rows.jerkPASS]));
fprintf(fid,'| Scenario | Executed | Valid | Completed | Passed | Failed | Invalid | Collision episodes | Worst TTC (s) | Worst P95 (ms) | Worst max jerk (m/s^3) | Status |\n');
fprintf(fid,'|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|\n');
for k=1:5
    s=summary(k);
    fprintf(fid,'| %s | %d/12 | %d | %d | %d/12 | %d | %d | %d | %.6g | %.6g | %.6g | %s |\n', ...
        s.scenarioName,s.executed,s.valid,s.completed,s.passed,s.failed, ...
        s.invalid,s.collisionEpisodes,s.worstTTC,s.worstP95LatencyMs, ...
        s.worstMaxJerk,s.status);
end
fprintf(fid,'\n## Frozen gates and definitions\n\n');
fprintf(fid,'1. Collision episodes **= 0**. A collision uses circular actor/ego geometry: distance between centers less than ego half-width plus actor radius. Consecutive collision samples count as one episode. Road departure independently fails completion.\n');
fprintf(fid,'2. Minimum **predicted** TTC **> 0.95 s** from VDB decision column 6. Valid zero and negative values are included. Exactly 99 (undefined sentinel) and nonfinite values are excluded. No remaining sample means INVALID.\n');
fprintf(fid,'3. Scenario completed **= true** only if the scorer finds the goal stop criterion before timeout and no collision or road departure. A safe stop short of the goal is not counted as completion in this campaign.\n');
fprintf(fid,'4. P95 replan latency **< 100 ms** from positive decision-column-7 timings, one per real replan. Zero non-replan placeholders are excluded. Nearest rank: sorted(ceil(0.95*N)). Wall-clock tic/toc timing depends on machine load and is not hard real-time proof.\n');
fprintf(fid,'5. Maximum absolute **physical longitudinal jerk < 0.9 m/s^3** from VDB signed longitudinal speed (ego column 4): interval acceleration diff(v)/diff(t), then jerk diff(acc)/diff(interval midpoints). The first and last endpoints have no second derivative; every interior value is retained, including emergency braking peaks. Commanded-acceleration jerk is diagnostic only.\n\n');
fprintf(fid,'All comparisons use raw double precision and strict inequalities; display values alone are rounded. The CSV writes numeric values with 17 significant digits; MAT logs contain original doubles and timeseries.\n\n');
fprintf(fid,'## Audit trail\n\n');
fprintf(fid,'`manifest.mat` and `manifest_cases.csv` freeze the 60 cases, actor IDs and exact parameter values. `run_XX_CASE.mat` stores each raw VDB ego and decision timeseries, score, dropout counters, and exception text immediately after its case. The score uses the same perturbed actor truth that the autonomy sensor suite receives. `benchmark_cli.log` contains the console record.\n\n');
fprintf(fid,'| Scenario | Case | Status | Outcome | Collision episodes | TTC (s) | TTC samples excluded | P95 (ms) | Max jerk (m/s^3) | Reason |\n');
fprintf(fid,'|---|---|---|---|---:|---:|---:|---:|---:|---|\n');
excludedTotal=0;
dropCamera=zeros(5,1); dropRadar=zeros(5,1);
for k=1:numel(rows)
    r=rows(k);
    logged=load(fullfile(fileparts(file),sprintf('run_%02d_%s.mat',k,r.caseId)),'detail');
    detail=logged.detail;
    excludedTotal=excludedTotal+detail.excludedTTC;
    if strcmp(r.caseId,'S01'), dropCamera(r.scenarioId)=detail.cameraDropped; end
    if strcmp(r.caseId,'S02'), dropRadar(r.scenarioId)=detail.radarDropped; end
    fprintf(fid,'| %d | %s | %s | %s | %.6g | %.6g | %d | %.6g | %.6g | %s |\n', ...
        r.scenarioId,r.caseId,r.status,r.rawOutcome,r.collisionEpisodes, ...
        r.minimumTTC,detail.excludedTTC,r.p95ReplanMs,r.maxAbsPhysicalJerk, ...
        strrep(r.invalidReason,'|','/'));
end
fprintf(fid,'\nAcross all runs, %d TTC samples were excluded because they were the documented undefined sentinel 99 or nonfinite. Valid zero TTC samples remain in the minima.\n\n',excludedTotal);
fprintf(fid,'| Scenario | Camera detections dropped in S01 | Radar detections dropped in S02 |\n');
fprintf(fid,'|---|---:|---:|\n');
for sid=1:5
    fprintf(fid,'| %d | %d | %d |\n',sid,dropCamera(sid),dropRadar(sid));
end
fprintf(fid,'\nSynthetic cases are simulator evidence only; they are not real-road safety certification or a percentage score for the broad SIH statement.\n');
end

function makeBenchmarkImage(rows,summary,m,file)
f=figure('Visible','off','Color','w','Units','pixels', ...
    'Position',[100 100 2400 1600]);
ax=axes(f,'Position',[0 0 1 1],'Visible','off');
xlim(ax,[0 1]); ylim(ax,[0 1]); hold(ax,'on');
navy=[0.07 0.13 0.22]; red=[0.69 0.12 0.11];
amber=[0.65 0.39 0.04]; green=[0.08 0.40 0.23];
text(ax,0.04,0.94,'SIH26037  |  60-case VDB benchmark', ...
    'FontSize',34,'FontWeight','bold','Color',navy);
text(ax,0.04,0.90,sprintf('%s  •  MATLAB %s',m.createdUTC,m.matlabRelease), ...
    'FontSize',18,'Color',navy);
executed=sum(~strcmp({rows.rawOutcome},'not_run'));
passed=sum([rows.Overall_PASS]); valid=sum([rows.valid]);
if executed<60
    headline=sprintf('INCOMPLETE — %d/60 executed  |  %d/60 passed',executed,passed);
elseif valid<60
    headline=sprintf('%d/60 passed  |  %d/60 valid  |  INVALID CASES',passed,valid);
else
    headline=sprintf('%d/60 passed  |  %d/60 valid',passed,valid);
end
text(ax,0.04,0.83,headline,'FontSize',30,'FontWeight','bold', ...
    'Color',ternaryColor(passed==60,green,red));
text(ax,0.04,0.75,'USER-PROPOSED STRICT GATES', ...
    'FontSize',18,'FontWeight','bold','Color',navy);
gates={'Collision episodes = 0','Predicted minimum TTC > 0.95 s', ...
    'Scenario completed = true','P95 replanning latency < 100 ms', ...
    'Max |physical longitudinal jerk| < 0.9 m/s³'};
for j=1:5
    text(ax,0.055,0.71-(j-1)*0.038,sprintf('%d. %s',j,gates{j}), ...
        'FontSize',17,'Color',navy);
end
text(ax,0.04,0.47,'SCENARIO', 'FontSize',16,'FontWeight','bold');
heads={'PASS/12','COLLISIONS','WORST TTC','WORST P95','WORST JERK','STATUS'};
xp=[0.38 0.50 0.62 0.73 0.84 0.95];
for j=1:6
    text(ax,xp(j),0.47,heads{j},'FontSize',14, ...
        'FontWeight','bold','HorizontalAlignment','center');
end
plot(ax,[0.04 0.98],[0.45 0.45],'Color',[0.7 0.75 0.8]);
for k=1:5
    s=summary(k); y=0.41-(k-1)*0.065;
    col=green;
    if strcmp(s.status,'FAIL'), col=red;
    elseif strcmp(s.status,'INVALID'), col=amber; end
    text(ax,0.04,y,sprintf('%d. %s',k,s.scenarioName), ...
        'FontSize',16,'Color',navy);
    vals={sprintf('%d/12',s.passed),sprintf('%d',s.collisionEpisodes), ...
        num(s.worstTTC,'%.3f'),num(s.worstP95LatencyMs,'%.1f ms'), ...
        num(s.worstMaxJerk,'%.2f'),s.status};
    for j=1:6
        text(ax,xp(j),y,vals{j},'FontSize',16, ...
            'FontWeight',ternary(j==6,'bold','normal'), ...
            'HorizontalAlignment','center','Color',ternaryColor(j==6,col,navy));
    end
end
text(ax,0.04,0.075,['TTC is autonomy-predicted; jerk is derived from VDB longitudinal speed. ', ...
    'N/A means no usable observation.'],'FontSize',15,'Color',navy);
text(ax,0.04,0.042,'Legend: PASS = all 12 cases meet all gates; FAIL = measured gate failure; INVALID = missing/unverifiable case.', ...
    'FontSize',14,'Color',navy);
set(f,'PaperUnits','inches','PaperPosition',[0 0 24 16], ...
    'PaperSize',[24 16]);
print(f,file,'-dpng','-r100'); close(f);
info=imfinfo(file);
if info.Width~=2400 || info.Height~=1600
    imwrite(imresize(imread(file),[1600 2400]),file);
end
end

function out=num(v,fmt)
if isfinite(v), out=sprintf(fmt,v); else, out='N/A'; end
end
function out=ternary(cond,a,b)
if cond, out=a; else, out=b; end
end
function out=ternaryColor(cond,a,b)
if cond, out=a; else, out=b; end
end
