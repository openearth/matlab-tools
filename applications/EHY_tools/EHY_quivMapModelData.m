function varargout = EHY_quivMapModelData(gridInfo,vel_x,vel_y,varargin)
%% varargout = EHY_quivMapModelData(gridInfo,vel_x,vel_y,varargin)
% Create quiver vectors
%
% This function only plots the quiver vector part,
% so you can easily add your own colorbar, xlims, etc.
%
% gridInfo     :   struct (with fields Xcen and Ycen) obtained with:
%                  gridInfo=EHY_getGridInfo(filename,{'XYcen'});
%                  if not available on map-file, you can also use:
%                  struct (with fields face_nodes_x and face_nodes_x) obtained with:
%                  gridInfo=EHY_getGridInfo(filename,{'face_nodes_xy'});
%
% vel_x        :   x-velocity in cell centers (= Data.vel_x obtained with EHY_getMapModelData)
% vel_y        :   y-velocity in cell centers (= Data.vel_y obtained with EHY_getMapModelData)
%
% Example1:   EHY_quivMapModelData(gridInfo,vel_x,vel_y,'thinning',2)
%             with gridInfo = EHY_getGridInfo(outputfile,{'XYcen'});
%                  Data     = EHY_getMapModelData(outputfile, ... );
%                  vel_x    = Data.vel_x(5,:,7);
%                  vel_y    = Data.vel_y(5,:,7);  % e.g. time_index = 5, layer = 7
%
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl
% created by Julien Groenenboom, October 2019
%
%% Settings
OPT.color    = 'k'; % color of the vectors
OPT.scaling  = [];  % scale factor: default = automatic, otherwise the velocity vectors are multiplied by this factor
OPT.thinning = 1;   % thinning factor, should be integer (velocity vectors are spatially-thinned by this factor)

% if pairs were given as input OPT
if ~isempty(varargin)
    if mod(length(varargin),2)==0
        OPT = setproperty(OPT,varargin);
    else
        error('Additional input arguments must be given in pairs.')
    end
end

%% check input
OPT.thinning = round(OPT.thinning);
if ~isnumeric(OPT.scaling);  OPT.scaling  = str2num(OPT.scaling);  end
if ~isnumeric(OPT.thinning); OPT.thinning = str2num(OPT.thinning); end

vel_x = squeeze(vel_x);
vel_y = squeeze(vel_y);

if ~all([exist('gridInfo','var') exist('vel_x','var') exist('vel_y','var')])
    error('input arguments gridInfo, vel_x and vel_y are required')
end

% make sure we have cell center coordinates
if ~all(ismember({'Xcen','Ycen'},fieldnames(gridInfo)))
    disp('Taking nanmean of face_nodes_x/y to get the (approximated) cell center coordinates')
    gridInfo.Xcen = nanmean(gridInfo.face_nodes_x,1);
    gridInfo.Ycen = nanmean(gridInfo.face_nodes_y,1);
end


if size(gridInfo.Xcen,2) == 1
    gridInfo.Xcen = gridInfo.Xcen';
end
if size(gridInfo.Ycen,2) == 1
    gridInfo.Ycen = gridInfo.Ycen';
end


if any(size(vel_x)~=size(vel_y))
    error('size(vel_x) should be equal to size(vel_y)')
elseif isfield(gridInfo,'face_nodes_x') && size(gridInfo.face_nodes_x,2)~=numel(vel_x)
    error('size(gridInfo.face_nodes_x,2) should be the same as  prod(size(zData))')
elseif isfield(gridInfo,'Xcen') && any(size(gridInfo.Xcen)~=size(vel_x))
    error('size(gridInfo.Xcor) and size(vel_x) should be the same')
end

%% quiver

% thinning
if ndims(vel_x) == 2 && min(size(vel_x)) == 1
    vel_x = vel_x(1:OPT.thinning:end);
    vel_y = vel_y(1:OPT.thinning:end);
    gridInfo.Xcen = gridInfo.Xcen(1:OPT.thinning:end);
    gridInfo.Ycen = gridInfo.Ycen(1:OPT.thinning:end);
elseif ndims(vel_x) == 2 && min(size(vel_x)) > 1
    vel_x = vel_x(1:OPT.thinning:end,1:OPT.thinning:end);
    vel_y = vel_y(1:OPT.thinning:end,1:OPT.thinning:end);
    gridInfo.Xcen = gridInfo.Xcen(1:OPT.thinning:end,1:OPT.thinning:end);
    gridInfo.Ycen = gridInfo.Ycen(1:OPT.thinning:end,1:OPT.thinning:end);
end


% quiver
if ~isempty(OPT.scaling)
    hQuiver = quiver(gridInfo.Xcen,gridInfo.Ycen,vel_x,vel_y,OPT.scaling);
else
    hQuiver = quiver(gridInfo.Xcen,gridInfo.Ycen,vel_x,vel_y);
end

% color
set(hQuiver,'color',OPT.color);

if nargout==1
    varargout{1}=hQuiver;
end

end