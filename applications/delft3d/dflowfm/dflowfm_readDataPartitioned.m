function data = dflowfm_readDataPartitioned(mapFiles,varName,IDdims,grd)

% dflowfm_readDataPartitioned reads data from both sequential as
% partitioned Delft3D-FM model output files. When the output is partitioned, 
% this function also makes sure that the ghostcells are excluded from the 
% output of this function.
%
% The following input variables need to be specified:
%    mapFiles: result of a dir command (only in Matlab 2016 and newer), for
%            example mapFiles = dir([c:\Run01\FM_output\*_map.nc])
%    varName: variable name in .nc file (check available variable names with 
%            the function nc_disp)
%    IDdims: A cell specifying for each dimension of the variable the
%            required elements {times, faces, layers (if model is in 3D)}. 
%            If all elements are required, one can use 0. The definition of 
%            the dimensions can be checked using the function nc_getvarinfo. 
%    grd (optional): structure containing the network information, which is
%            the result of grd = dflowfm_readNetPartitioned(mapFiles). When
%            grd is not specified, the ghostcells cannot be removed from
%            the output
%
% example: reading the salinity data (all faces) for the first output time and the
% first layer:
%    mapFiles = dir([c:\Run01\FM_output\*_map.nc]);
%    grd = grd = dflowfm_readNetPartitioned(mapFiles);
%    data = dflowfm_readDataPartitioned(mapFiles,'mesh2d_sa1',{1,0,1},grd);


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
    
    dataPartition = nc_varget([mapFiles(mm).folder,filesep,mapFiles(mm).name],varName,startID,lengthID);
    
    if mm == 1
        data = [nc_varget([mapFiles(mm).folder,filesep,mapFiles(mm).name],varName,startID,lengthID)];
    else
        try
            data = [data;nc_varget([mapFiles(mm).folder,filesep,mapFiles(mm).name],varName,startID,lengthID)];
        catch
            try
                if mm == 2
                    data = data';
                end
                data = [data;nc_varget([mapFiles(mm).folder,filesep,mapFiles(mm).name],varName,startID,lengthID)'];
            catch
                error('data cannot be concatenated. Probably caused by different nc_varget function. This function is based on the nc_varget from OEtools.')
            end
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