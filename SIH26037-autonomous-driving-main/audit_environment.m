if ~exist(fullfile('results','logs'),'dir'), mkdir(fullfile('results','logs')); end
diary(fullfile('results','logs','environment_audit.txt'));
fprintf('MATLAB %s (%s)\n',version,version('-release'));
disp(ver);
names = {'drivingScenario','visionDetectionGenerator','drivingRadarDataGenerator', ...
    'lidarPointCloudGenerator','trackerJPDA','trackerGNN','trackingIMM', ...
    'predictTracksToTime','trajectoryGeneratorFrenet','trajectoryOptimalFrenet', ...
    'referencePathFrenet','dynamicCapsuleList','plannerHybridAStar', ...
    'stateSpaceSE2','validatorOccupancyMap','occupancyMap', ...
    'binaryOccupancyMap','lateralControllerStanley','roadrunner', ...
    'road','vehicle','actor','actorProfiles','targetPoses', ...
    'exportgraphics','VideoWriter','sim','new_system', ...
    'add_block','save_system'};
for k=1:numel(names)
    n=names{k}; p=which(n);
    fprintf('%-32s exist=%d which=%s\n',n,exist(n,'file'),p);
end
try, s=drivingScenario('SampleTime',0.1); fprintf('drivingScenario construction: OK (%s)\n',class(s));
catch ME, fprintf('drivingScenario construction: FAIL %s\n',ME.message); end
constructors={'visionDetectionGenerator','drivingRadarDataGenerator','lidarPointCloudGenerator', ...
    'trackerJPDA','trackerGNN','stateSpaceSE2','occupancyMap','binaryOccupancyMap', ...
    'lateralControllerStanley'};
for k=1:numel(constructors)
    n=constructors{k};
    try, obj=feval(n); fprintf('%s construction: OK (%s)\n',n,class(obj));
    catch ME, fprintf('%s construction: FAIL %s\n',n,ME.message); end
end
try
    new_system('SIH_Audit_Temporary');
    add_block('simulink/Sources/Constant','SIH_Audit_Temporary/Constant');
    close_system('SIH_Audit_Temporary',0);
    fprintf('Programmatic Simulink generation: OK\n');
catch ME
    fprintf('Programmatic Simulink generation: FAIL %s\n',ME.message);
    if bdIsLoaded('SIH_Audit_Temporary'), close_system('SIH_Audit_Temporary',0); end
end
try
    r=sfroot; fprintf('Stateflow programmatic root: OK (%s)\n',class(r));
catch ME, fprintf('Stateflow programmatic root: FAIL %s\n',ME.message); end
diary off;
