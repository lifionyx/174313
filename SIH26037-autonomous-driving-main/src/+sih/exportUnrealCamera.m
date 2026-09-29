function files=exportUnrealCamera(cameraSeries,outputRoot)
% Record frames returned by the actual Simulation 3D Camera block.
data=cameraSeries.Data;
assert(ndims(data)==4 && size(data,3)==3 && ...
    size(data,4)==numel(cameraSeries.Time));
recordDir=fullfile(outputRoot,'screen_recordings');
shotDir=fullfile(outputRoot,'screenshots','3d_unreal');
if ~exist(recordDir,'dir'), mkdir(recordDir); end
if ~exist(shotDir,'dir'), mkdir(shotDir); end
file=fullfile(recordDir,'SIH26037_Unreal_VDB_camera.mp4');
writer=VideoWriter(file,'MPEG-4'); writer.FrameRate=6; open(writer);
cleanup=onCleanup(@()close(writer));
for j=1:size(data,4)
    frame=data(:,:,:,j);
    if ~isa(frame,'uint8')
        if max(frame,[],'all')<=1, frame=im2uint8(frame);
        else, frame=uint8(frame); end
    end
    if j==1
        first=fullfile(shotDir,'01_unreal_camera_initial.png');
        imwrite(frame,first);
    end
    if j==size(data,4)
        last=fullfile(shotDir,'02_unreal_camera_final.png');
        imwrite(frame,last);
    end
    writeVideo(writer,imresize(frame,[720 1280]));
end
clear cleanup;
assert(isfile(file) && isfile(first) && isfile(last));
files=struct('video',file,'first',first,'last',last, ...
    'frameCount',size(data,4), ...
    'firstPixelVariance',var(double(data(:,:,:,1)),0,'all'));
fprintf('Unreal camera recorded %d frames; first-frame variance %.2f\n', ...
    files.frameCount,files.firstPixelVariance);
end
