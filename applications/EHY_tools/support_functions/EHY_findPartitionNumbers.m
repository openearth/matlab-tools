function partitionNrs = EHY_findPartitionNumbers(inputFile,varargin)

OPT.pliFile = '';
OPT.pli     = '';
OPT.disp    = 1;
OPT         = setproperty(OPT,varargin);

%%
partitionNrs = [];
    
%% check
if ~EHY_isPartitioned(inputFile)
    return
end

if ~isempty(OPT.pliFile)
    pli = io_polygon('read',OPT.pliFile);
elseif ~isempty(OPT.pli)
    pli = OPT.pli;
else
    error('You need to specify either "pliFile" or "pli"')
end

%% process
ncFiles = EHY_getListOfPartitionedNcFiles(inputFile);
for iF = 1:length(ncFiles)
    gridInfo = EHY_getGridInfo(ncFiles{iF},{'XYcor','face_nodes'},'mergePartitions',0);
    warning off
    arb = arbcross(gridInfo.face_nodes',gridInfo.Xcor,gridInfo.Ycor,pli(:,1),pli(:,2));
    warning on
    
    if any(~arb.outside)
        [~,name] = fileparts(ncFiles{iF}); % domain number
        if OPT.disp
            disp(['Trajectory from pli/pliFile crosses partition number: ' name(end-7:end-4)]);
        end
        partitionNrs(end+1,1) = str2num(name(end-7:end-4));
    end
end
