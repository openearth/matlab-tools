function [grd,grdPart] = dflowfm_readNetPartitioned(mapFiles,FlagShiftNodesCutCellPolygonLST)

%% Reads network from partitioned Delft3D-FM files (_map.nc, _net.nc, etc.)
%
% required input:
% mapFiles = structure containing the fields folder and name (resulting from e.g. mapFiles = dir([d:/temp/NCfiles/])
%
% optional input (recommended, because otherwise plotting may take a long time):
% FlagShiftNodesCutCellPolygonLST = 1: changes the X and Y coordinates of the nodes, which have been shifted due to the cutcellpolygon.lst routine in Delft3D-FM (if applied)

if nargin < 2
    FlagShiftNodesCutCellPolygonLST = 0;
end

for mm = 1:length(mapFiles)
    disp(['Reading: ',mapFiles(mm).name])
    if nc_isvar([mapFiles(mm).folder,filesep,mapFiles(mm).name], 'mesh2d_node_x')
        grdPart(mm) = dflowfm.readNet([mapFiles(mm).folder,filesep,mapFiles(mm).name]); % Ugrid format
    else
        grdPart(mm) = dflowfm.readNetOld([mapFiles(mm).folder,filesep,mapFiles(mm).name]); % Old Netcdf format
    end
    
    if mm == 1
        grd = grdPart(mm);
    else
        %% Determine amount of nodes, elements and netlinks from previous partitions
        
        if isfield(grd,'node')
            addNode = length(grd.node.x);
        end
        if isfield(grd,'face')
            addFlowElem = length(grd.face.FlowElem_x);
        end
        if isfield(grd,'edge')
            addNetLink = length(grd.edge.NetLinkType);
        end
        
        %% Append variables
        if isfield(grd,'node')
            % merge fields
            nodeFields = fieldnames(grd.node);
            for ff = 1:length(nodeFields)
                if ~strcmpi(nodeFields{ff},'n')
                    grd.node.(nodeFields{ff}) = [grd.node.(nodeFields{ff}) grdPart(mm).node.(nodeFields{ff})];
                end
            end            
            grd.node.n = length(grd.node.x);
        end
        
        if isfield(grd,'edge')
            % merge fields
            edgeFields = fieldnames(grd.edge);
            for ff = 1:length(edgeFields)
                if strcmpi(edgeFields{ff},'NetLink')
                    grd.edge.NetLink = [grd.edge.NetLink grdPart(mm).edge.NetLink+addNode];
                elseif strcmpi(edgeFields{ff},'FlowLink')
                    grd.edge.FlowLink = [grd.edge.FlowLink grdPart(mm).edge.FlowLink+addFlowElem];                  
                elseif ~strcmpi(edgeFields{ff},'NetLinkSize') & ~strcmpi(edgeFields{ff},'FlowLinkSize')
                    grd.edge.(edgeFields{ff}) = [grd.edge.(edgeFields{ff}) grdPart(mm).edge.(edgeFields{ff})];
                end
            end
            
            grd.edge.NetLinkSize = length(grd.edge.NetLinkType);
            grd.edge.FlowLinkSize = length(grd.edge.FlowLinkType);
        end
        
        if isfield(grd,'face')
            % merge fields
            faceFields = fieldnames(grd.face);
            for ff = 1:length(faceFields)
                if strcmpi(faceFields{ff},'FlowElemCont_x')
                    grd.face.FlowElemCont_x = appendMatrices(grd.face.FlowElemCont_x,grdPart(mm).face.FlowElemCont_x,2);
                elseif strcmpi(faceFields{ff},'FlowElemCont_y')
                    grd.face.FlowElemCont_y = appendMatrices(grd.face.FlowElemCont_y,grdPart(mm).face.FlowElemCont_y,2);
                elseif strcmpi(faceFields{ff},'NetElemNode')
                    grd.face.NetElemNode = appendMatrices(grd.face.NetElemNode,grdPart(mm).face.NetElemNode+addNode,1);
                elseif strcmpi(faceFields{ff},'BndLink')
                    grd.face.BndLink = [grd.face.BndLink grdPart(mm).face.BndLink+addNetLink];
                elseif ~strcmpi(faceFields{ff},'FlowElemSize')
                    grd.face.(faceFields{ff}) = [grd.face.(faceFields{ff}) grdPart(mm).face.(faceFields{ff})];
                end
            end
            grd.face.FlowElemSize = length(grd.face.FlowElem_x);
        end
        
        if isfield(grd,'map3')
            grd.map3= [grd.map3;grdPart(mm).map3+addFlowElem];
        end
        
        if isfield(grd,'tri')
            grd.tri= [grd.tri;grdPart(mm).tri+addNode];
        end
    end
end

%% shift nodes which have been cut by the cutcellpolygon.lst
if FlagShiftNodesCutCellPolygonLST
    try
        grd = dflowfm_shiftNodesCutCellPolygon(grd)
    catch
        disp('Warning: Could not take into account the shifting of nodes due to the cutcellpolygon.lst, because you don''t have a license for the Statistics toolbox')
    end
end

end

function newVal = appendMatrices(val1,val2,AppendDimension)
switch AppendDimension
    case 1
        newVal = zeros(size(val1,1)+size(val2,1),max(size(val1,2),size(val2,2)))+NaN;
        newVal(1:size(val1,1),1:size(val1,2)) = val1;
        newVal(size(val1,1)+1:end,1:size(val2,2)) = val2;        
    case 2
        newVal = zeros(max(size(val1,1),size(val2,1)),size(val1,2)+size(val2,2))+NaN;
        newVal(1:size(val1,1),1:size(val1,2)) = val1;
        newVal(1:size(val2,1),size(val1,2)+1:end) = val2;
end

end