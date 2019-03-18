function data = dflowfm_readDataPartitioned(mapFiles,varName,IDdims,grd)

if nargin < 4
    checkGhostCells = 0;
else
    checkGhostCells = 1;
end

IDdimsReal = IDdims;

for mm = 1:length(mapFiles)
    varInfo = nc_getvarinfo([mapFiles(mm).folder,filesep,mapFiles(mm).name],varName);
    
    % set requested indices for each dimension
    startID = [];
    lengthID = [];
    for dd = 1:size(varInfo.Size,2)
        if length(IDdims) >= dd
            if IDdims{dd} == 0
                IDdimsReal{dd} = 1:varInfo.Size(dd);
            end
        else
            IDdimsReal{dd} = 1:varInfo.Size(dd);
        end
        startID = [startID IDdimsReal{dd}(1)-1];
        lengthID = [lengthID length(IDdimsReal{dd})];
    end
    
    if mm == 1
        data = [nc_varget([mapFiles(mm).folder,filesep,mapFiles(mm).name],varName,startID,lengthID)]; % u velocity at cell center
    else
        try
            data = [data;nc_varget([mapFiles(mm).folder,filesep,mapFiles(mm).name],varName,startID,lengthID)]; % u velocity at cell center
        catch
            error('data cannot be concatenated. Probably caused by different nc_varget function. This function is based on the nc_varget from wlsettings (p:\delta\wlsettings\dl_snctools\nc_varget.m)')
        end
    end
end
data = data';

if checkGhostCells && length(mapFiles)>1
    %     if ~isempty(find(~cellfun('isempty',regexp(varInfo.Dimension,'nFlowElem'))))
    Xcheck = grd.face.FlowElem_x';
    Ycheck = grd.face.FlowElem_y';
    %     end
    
    % finds cells which occur twice
    [~,IDFirst] = unique([Xcheck Ycheck],'rows','first');
    [~,IDLast] = unique([Xcheck Ycheck],'rows','last');
    IDghostCells = find(IDLast~=IDFirst);
    
    %     IDzero = find(data==0);
    %     data(IDzero) = NaN;
    if ~isempty(IDghostCells)
        for tt = 1:size(data,1)
            % check for the ghostcells which cell has the largest absolute value (this seems to be the correct value)
            dataFirstLast = [data(tt,IDFirst(IDghostCells));data(tt,IDLast(IDghostCells))];
            [~,id] = max(abs(dataFirstLast),[],1);
            
            dataReal(find(id==1)) = dataFirstLast(1,find(id==1));
            dataReal(find(id==2)) = dataFirstLast(2,find(id==2));
            
            data(tt,IDFirst(IDghostCells)) = dataReal;
            data(tt,IDLast(IDghostCells)) = dataReal;
        end
    end
end