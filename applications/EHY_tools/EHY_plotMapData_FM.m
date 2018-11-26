function hPatch=EHY_plotMapData_FM(gridInfo,zData,varargin)
%% EHY_plotMapData_FM(gridInfo,zData)
% Create top views using QuickPlot / d3d_qp functionalities
% However, this function only plots the pcolor / patch part,
% so you can more easily add your own colorbar, xlims, etc.
%
% gridInfo     :   struct (with fields face_nodes_x and face_nodes_x) obtained with:
%                  gridInfo=EHY_getGridInfo(filename,'face_nodes_xy');
% zData        :   Data in net elements (cell centers)
%
% Example1: EHY_plotMapData_FM
% Example2: EHY_plotMapData_FM(gridInfo,zData)
%             with gridInfo=EHY_getGridInfo(outputfile,'face_nodes_xy');
%                  Data = EHY_getMapModelData(outputfile, ... );
%                  zData=Data.Val(1,:);
%
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl
% created by Julien Groenenboom, October 2018
%
%% Settings
OPT.linestyle = 'none'; % other options: '-' 
OPT.edgecolor = 'k';
OPT.facecolor = 'flat';

% if pairs were given as input OPT
if ~isempty(varargin)
    if mod(length(varargin),2)==0
        OPT = setproperty(OPT,varargin);
    else
        error('Additional input arguments must be given in pairs.')
    end
end

%% check input

if ~all([exist('gridInfo','var') exist('zData','var')])
    % no input, start interactive script
    EHY_plotMapData_FM_interactive
    return
end

if ~all([isstruct(gridInfo) isfield(gridInfo,'face_nodes_x') isfield(gridInfo,'face_nodes_y')])
    error('Something wrong with first input argument');
end

if size(gridInfo.face_nodes_x,2)~=length(zData)
    error('Length of face_nodes_xy and zData should be the same')
end

if isempty(zData); error('No zData to plot'); end

%% plot figure
for ii=1:size(gridInfo.face_nodes_x,2)
    XY{1,ii}=[gridInfo.face_nodes_x(:,ii) gridInfo.face_nodes_y(:,ii); ];
    % delete NaNs
    XY{1,ii}(isnan(XY{1,ii}(:,1)),:)=[];
    % close polygon
    XY{1,ii}(end+1,:)=XY{1,ii}(1,:);
end

nnodes = cellfun('size',XY,1);
unodes = unique(nnodes);
unodes(unodes==0)=[];
for i = 1:length(unodes)
    n = unodes(i);
    nr = n-1;
    poly_n = find(nnodes==n);
    npoly = length(poly_n);
    tvertex = nr*npoly;
    XYvertex = NaN(tvertex,2);
    Vpatch = NaN(npoly,1);
    offset = 0;
    for ip = 1:npoly
        XYvertex(offset+(1:nr),:) = XY{poly_n(ip)}(1:nr,:);
        offset = offset+nr;
        Vpatch(ip) = zData(poly_n(ip));
    end
    
    hPatch(i,1)=patch('vertices',XYvertex, ...
        'faces',reshape(1:tvertex,[nr npoly])', ...
        'facevertexcdata',Vpatch, ...
        'marker','none',...
        'edgecolor',OPT.edgecolor,...
        'linestyle',OPT.linestyle,...
        'faceColor',OPT.facecolor);
end

EHYs(mfilename);
end