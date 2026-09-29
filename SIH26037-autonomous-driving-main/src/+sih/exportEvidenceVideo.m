function exportEvidenceVideo(r,file,c,events)
% Time-lapse video with telemetry, tracks, prediction, and selected plan.
writer=VideoWriter(file,'MPEG-4'); writer.FrameRate=8; open(writer);
folder=fileparts(file);
f=figure('Visible','off','Color','w','Position',[40 40 1280 720]);
cleanup=onCleanup(@()cleanResources(writer,f));
dt=median(diff(r.log.time)); stride=max(1,round(0.9/dt));
indices=unique([1:stride:numel(r.log.time),[events.index],numel(r.log.time)]);
for idx=indices
    temp=fullfile(folder,sprintf('_evidence_frame_%04d.png',idx));
    sih.renderEvidenceFrame(r,idx,'live autonomy',temp,c,f,80);
    frame=imread(temp);
    frame=imresize(frame,[720 1280]);
    writeVideo(writer,frame);
    delete(temp);
end
clear cleanup;
end

function cleanResources(writer,f)
try, close(writer); catch, end
if isgraphics(f), close(f); end
end
