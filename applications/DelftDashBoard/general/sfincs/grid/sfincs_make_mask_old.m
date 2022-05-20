function msk=sfincs_make_mask(x,y,z,zlev,varargin)

% Leijnse april 18: included option to exclude points via polygon input
xy_in=[];
xy_ex=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'includepolygon'}
                xy_in=varargin{ii+1};
            case{'excludepolygon'}
                xy_ex=varargin{ii+1};
                
        end
    end
end

% include and exclude polygons can come in as structure or matrix
% if matrix, first convert to structure

% Include polygons
if isempty(xy_in)
    xy_in(1).x=[];
    xy_in(1).y=[];
elseif ~isstruct(xy_in)   
    % Matrix convert to structure
    xtmp=xy_in(:,1);
    ytmp=xy_in(:,2);
    xy_in=[];
    xy_in(1).x=xtmp;
    xy_in(1).y=ytmp;
end

% Exclude polygons
if isempty(xy_ex)
    xy_ex(1).x=[];
    xy_ex(1).y=[];
elseif ~isstruct(xy_ex)
    % Matrix convert to structure
    xtmp=xy_ex(:,1);
    ytmp=xy_ex(:,2);
    xy_ex=[];
    xy_ex(1).x=xtmp;
    xy_ex(1).y=ytmp;
end

if ~isempty(xy_in(1).x)
    % Throw away points below zlev(1), but not points within polygon
    % Do this by temporarily raising these points to zlev(1)+0.01
    for ip=1:length(xy_in)
        xp=xy_in(ip).x;
        yp=xy_in(ip).y;
        inp=inpolygon(x,y,xp,yp);
        z(inp)=max(z(inp),zlev(1)+0.01);
    end
end

if ~isempty(xy_ex(1).x)
    % Throw away points below zlev(1), but not points within polygon
    % Do this by temporarily raising these points to zlev(1)+0.01
    for ip=1:length(xy_ex)
        xp=xy_ex(ip).x;
        yp=xy_ex(ip).y;
        inp=inpolygon(x,y,xp,yp);
        z(inp)=zlev(2)+0.01;
    end
end

z(z<zlev(1))=NaN;

% iabove=z>zlev(2);
%z(z>zlev(2))=NaN;

msk=zeros(size(z));

msk(~isnan(z))=1;

imax=size(msk,1);
jmax=size(msk,2);

% Find any surrounding points that have a NaN value

% Left
iside=1;
ii1a(iside)=1;
ii2a(iside)=imax;
jj1a(iside)=1;
jj2a(iside)=jmax-1;
ii1b(iside)=1;
ii2b(iside)=imax;
jj1b(iside)=2;
jj2b(iside)=jmax;
% Right
iside=2;
ii1a(iside)=1;
ii2a(iside)=imax;
jj1a(iside)=2;
jj2a(iside)=jmax;
ii1b(iside)=1;
ii2b(iside)=imax;
jj1b(iside)=1;
jj2b(iside)=jmax-1;
% Bottom
iside=3;
ii1a(iside)=1;
ii2a(iside)=imax-1;
jj1a(iside)=1;
jj2a(iside)=jmax;
ii1b(iside)=2;
ii2b(iside)=imax;
jj1b(iside)=1;
jj2b(iside)=jmax;
% Top
iside=4;
ii1a(iside)=2;
ii2a(iside)=imax;
jj1a(iside)=1;
jj2a(iside)=jmax;
ii1b(iside)=1;
ii2b(iside)=imax-1;
jj1b(iside)=1;
jj2b(iside)=jmax;

msk(1,:)=2;
msk(end,:)=2;
msk(:,1)=2;
msk(:,end)=2;

for iside=1:4
    if iside==3
        shite=1
    end
    zb=z(ii1a(iside):ii2a(iside),jj1a(iside):jj2a(iside));
    zc=z(ii1b(iside):ii2b(iside),jj1b(iside):jj2b(iside));
    mskc=msk(ii1b(iside):ii2b(iside),jj1b(iside):jj2b(iside));
    ibnd= isnan(zb) & ~isnan(zc); % NaN next to a real point
    mskc(ibnd)=2;
    msk(ii1b(iside):ii2b(iside),jj1b(iside):jj2b(iside))=mskc;
end
msk(z>zlev(2))=0;
msk(isnan(z))=0;
