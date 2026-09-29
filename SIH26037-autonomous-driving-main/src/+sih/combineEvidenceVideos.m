function file=combineEvidenceVideos(outputRoot)
% MATLAB-native concatenation of the five already rendered scenario videos.
folder=fullfile(outputRoot,'videos');
names={'village_demo.mp4','intersection_demo.mp4', ...
    'highway_merge_demo.mp4','market_demo.mp4','cattle_crossing_demo.mp4'};
file=fullfile(folder,'SIH26037_FINAL_DEMO.mp4');
writer=VideoWriter(file,'MPEG-4'); writer.FrameRate=8; open(writer);
cleanup=onCleanup(@()close(writer));
for k=1:numel(names)
    source=fullfile(folder,names{k});
    assert(isfile(source),'Missing scenario video: %s',source);
    reader=VideoReader(source);
    while hasFrame(reader)
        writeVideo(writer,readFrame(reader));
    end
end
clear cleanup;
assert(isfile(file),'Combined video export failed');
end
