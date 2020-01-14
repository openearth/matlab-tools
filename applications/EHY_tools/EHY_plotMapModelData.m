function varargout = EHY_plotMapModelData(gridInfo,zData,varargin)
%% varargout = EHY_plotMapModelData(gridInfo,zData,varargin)
% Create top views using QuickPlot / d3d_qp functionalities (for
% 'DFM'-runs) or pcolor (for 'D3D'-runs)
%
% This function only plots the pcolor / patch part,
% so you can easily add your own colorbar, xlims, etc.
%
% gridInfo     :   struct (with fields face_nodes_x and face_nodes_x) obtained with:
%                  gridInfo = EHY_getGridInfo(filename,{'face_nodes_xy'});
% zData        :   matrix: Data in net elements (cell centers)
%
% Example1: EHY_plotMapModelData
% Example2: EHY_plotMapModelData(gridInfo,zData)
%             with gridInfo = EHY_getGridInfo(outputfile,{'face_nodes_xy'});
%                  Data     = EHY_getMapModelData(outputfile, ... );
%                  zData    = Data.val(1,:);
%
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl
% created by Julien Groenenboom, October 2018
%
%% Settings
OPT.linestyle = 'none'; % other options: '-'
OPT.edgecolor = 'k';
OPT.facecolor = 'flat';
OPT.linewidth = 0.5;
OPT.t = []; % time index, needed for plotting data along xy-trajectory

% if pairs were given as input OPT
if ~isempty(varargin)
    if mod(length(varargin),2)==0
        OPT = setproperty(OPT,varargin);
    else
        error('Additional input arguments must be given in pairs.')
    end
end

if isempty(OPT.linestyle); OPT.linestyle='none'; end
if ~isnumeric(OPT.t); OPT.t = str2num(OPT.t); end
    
%% check input
if ~all([exist('gridInfo','var') exist('zData','var')])
    % no input, start interactive script
    EHY_plotMapModelData_interactive
    return
end

%% structured or unstructured grid
if isstruct(gridInfo)
    if isfield(gridInfo,'face_nodes_x') && isfield(gridInfo,'face_nodes_y')
        modelType= 'dfm';
    elseif isfield(gridInfo,'Xcor') && isfield(gridInfo,'Ycor')
        modelType= 'd3d';
    else
        error('Something wrong with first input argument')
    end
else
    error('Something wrong with first input argument');
end

if isempty(zData)
    error('No zData to plot')
elseif size(zData,1)==1
    zData = squeeze(zData);
end

%% check for unstructured grids (modelType = 'dfm')
if strcmp(modelType,'dfm')
    if size(gridInfo.face_nodes_x,2)~=numel(zData)
        error('size(gridInfo.face_nodes_x,2) should be the same as  prod(size(zData))')
    end
end

%% check for structured grids (modelType = 'd3d')
if strcmp(modelType,'d3d') 
    if ndims(gridInfo.Ycor) - ndims(gridInfo.Xcor) == 1
        % probably data along xy-trajectory 
        if isempty(OPT.t)
            error('You need to provide variable ''t'' to plot data along xy-trajectory');
        else
            % -> [cells,layers]
            gridInfo.Xcor = reshape(gridInfo.Xcor,length(gridInfo.Xcor),1);
            gridInfo.Xcor = repmat(gridInfo.Xcor,1,size(gridInfo.Ycor,3));
            gridInfo.Ycor = squeeze(gridInfo.Ycor(OPT.t,:,:));
            
            % add dummy values for plotting with pcolor
            for ii = 1:size(gridInfo.Ycor,1)
                gridInfo2.Xcor(2*ii-1,:) = gridInfo.Xcor(ii,:);
                gridInfo2.Xcor(2*ii  ,:) = gridInfo.Xcor(ii+1,:);
                gridInfo2.Ycor(2*ii-1,:) = gridInfo.Ycor(ii,:);
                gridInfo2.Ycor(2*ii  ,:) = gridInfo.Ycor(ii,:);
                zData2(2*ii-1,:) = zData(ii,:);
                zData2(2*ii  ,:) = zData(ii,:);
            end
            zData2(end,:) = [];
            gridInfo = gridInfo2;
            zData = zData2;
        end
    end
    
    if ~all(size(gridInfo.Xcor)==size(gridInfo.Ycor))
        error('size(gridInfo.Xcor) and size(gridInfo.Ycor) should be the same')
    end
    
    if all(size(gridInfo.Xcor)-size(zData) == [1 1])
        % this is needer for info in cell center, like delft3d 4 output
        zData(end+1,:) = NaN;
        zData(:,end+1) = NaN;
    elseif all(size(gridInfo.Xcor)-size(zData) == [0 0])
        % this is needed for info in cell corners, like griddata_netcdf
        % for plotting with pcolor > apply center2corner and
        % add dummy row and column in zData
        gridInfo.Xcor = center2corner(gridInfo.Xcor);
        gridInfo.Ycor = center2corner(gridInfo.Ycor);
        zData(end+1,:) = NaN;
        zData(:,end+1) = NaN;
    else
         error('size(gridInfo.Xcor/Ycor) should be equal or one size bigger than size(zData)')
    end

end

%% plot figure
switch modelType
    case 'dfm'
        
        % don't plot NaN's (gives problems in older MATLAB versions)
        nanInd = isnan(zData);
        gridInfo.face_nodes_x(:,nanInd) = [];
        gridInfo.face_nodes_y(:,nanInd) = [];
        zData(nanInd) = [];
        
        nnodes = size(gridInfo.face_nodes_x,1) - sum(isnan(gridInfo.face_nodes_x));
        unodes = unique(nnodes);
        unodes(unodes==0) = [];
        
        for i = 1:length(unodes)
            nr = unodes(i);
            poly_n = find(nnodes==nr);
            npoly = length(poly_n);
            tvertex = nr*npoly;
            XYvertex = NaN(tvertex,2);
            Vpatch = NaN(npoly,1);
            offset = 0;
            for ip = 1:npoly
                XYvertex(offset+(1:nr),:) = [gridInfo.face_nodes_x(1:nr,poly_n(ip)) gridInfo.face_nodes_y(1:nr,poly_n(ip))];
                offset = offset+nr;
                Vpatch(ip) = zData(poly_n(ip));
            end
            
            hPatch(i,1)=patch('vertices',XYvertex, ...
                'faces',reshape(1:tvertex,[nr npoly])', ...
                'facevertexcdata',Vpatch, ...
                'marker','none',...
                'edgecolor',OPT.edgecolor,...
                'linestyle',OPT.linestyle,...
                'faceColor',OPT.facecolor,...
                'LineWidth',OPT.linewidth);
        end
        
        if nargout==1
            varargout{1}=hPatch;
        end
        
    case 'd3d'
        hPcolor = pcolor(gridInfo.Xcor,gridInfo.Ycor,zData);
        set(hPcolor,'linestyle',OPT.linestyle,'edgecolor',OPT.edgecolor,'facecolor',OPT.facecolor);
        
        if nargout==1
            varargout{1}=hPcolor;
        end
end
