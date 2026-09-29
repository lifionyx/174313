function report=verifyOutputs(out,strictLogs)
if nargin<2, strictLogs=false; end
slugs={'01_village','02_intersection','03_highway_merge', ...
    '04_market','05_cattle_crossing'};
videos={'village_demo.mp4','intersection_demo.mp4', ...
    'highway_merge_demo.mp4','market_demo.mp4','cattle_crossing_demo.mp4'};
for id=1:5
    folder=fullfile(out,'screenshots',slugs{id});
    images=dir(fullfile(folder,'*.png'));
    assert(numel(images)>=8,'Scenario %d has fewer than 8 screenshots',id);
    assert(isfile(fullfile(out,'videos',videos{id})), ...
        'Scenario %d video is missing',id);
    assert(isfile(fullfile(out,'metrics',sprintf('scenario_%d.mat',id))));
end
assert(isfile(fullfile(out,'videos','SIH26037_FINAL_DEMO.mp4')));
assert(isfile(fullfile(out,'screenshots','simulink','full_model.png')));
assert(isfile(fullfile(out,'screenshots','simulink','closed_loop_subsystem.png')));
figures=dir(fullfile(out,'figures','*.png'));
assert(numel(figures)>=8,'Fewer than eight result figures exist');
imageFiles=[dir(fullfile(out,'screenshots','**','*.png'));figures];
for k=1:numel(imageFiles)
    file=fullfile(imageFiles(k).folder,imageFiles(k).name);
    assert(imageFiles(k).bytes>10000,'Empty or corrupt image: %s',file);
    meta=imfinfo(file);
    assert(meta.Width>=400 && meta.Height>=200, ...
        'Evidence image resolution is too small: %s',file);
end
videoFiles=dir(fullfile(out,'videos','*.mp4'));
for k=1:numel(videoFiles)
    file=fullfile(videoFiles(k).folder,videoFiles(k).name);
    assert(videoFiles(k).bytes>10000,'Empty video: %s',file);
    reader=VideoReader(file);
    assert(reader.Duration>0 && reader.Width>=640 && reader.Height>=360 ...
        && hasFrame(reader),'Unreadable evidence video: %s',file);
    readFrame(reader);
end
for doc={'EVIDENCE_INDEX.md','FINAL_RESULTS.md'}
    path=fullfile(out,doc{1}); assert(isfile(path));
    raw=fileread(path);
    links=regexp(raw,'\]\(([^)]+)\)','tokens');
    for k=1:numel(links)
        rel=links{k}{1};
        assert(isfile(fullfile(out,strrep(rel,'/',filesep))), ...
            'Broken evidence link in %s: %s',doc{1},rel);
    end
end
if strictLogs
    names={'environment_audit.txt','test_suite.txt', ...
        'canonical_benchmark.txt','simulink_smoke.txt'};
    for k=1:numel(names)
        assert(isfile(fullfile(out,'logs',names{k})), ...
            'Required CLI log is missing: %s',names{k});
    end
end
shots=dir(fullfile(out,'screenshots','**','*.png'));
report=struct('screenshots',numel(shots),'figures',numel(figures), ...
    'videos',numel(videoFiles));
fprintf('Verified %d screenshots, %d figures, %d videos and all index links.\n', ...
    report.screenshots,report.figures,report.videos);
end
