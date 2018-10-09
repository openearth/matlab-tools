function msk=sfincs_make_mask(x,y,z,zlev,varargin)
% Leijnse april 18: included option to exclude points via polygon input

xy=[];
xy_ex=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'includepolygon'}
                xy=varargin{ii+1};
            case{'excludepolygon'}
                xy_ex=varargin{ii+1};
                
        end
    end
end


if ~isempty(xy)
    % Throw away points below zlev(1), but not points within polygon
    % Do this by temporarily raising these points to zlev(1)+0.01
    xp=xy(:,1);
    yp=xy(:,2);
    inp=inpolygon(x,y,xp,yp);
    z(inp)=max(z(inp),zlev(1)+0.01);
end

if ~isempty(xy_ex)
    % Throw away points within polygon
    xp_ex=xy_ex(:,1);
    yp_ex=xy_ex(:,2);
    inp_ex=inpolygon(x,y,xp_ex,yp_ex);
    z(inp_ex)=NaN; %max(z(inp),zlev(1)+0.01);
end

z(z<zlev(1))=NaN;

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

for iside=1:4
    zb=z(ii1a(iside):ii2a(iside),jj1a(iside):jj2a(iside));
    zc=z(ii1b(iside):ii2b(iside),jj1b(iside):jj2b(iside));
    mskc=msk(ii1b(iside):ii2b(iside),jj1b(iside):jj2b(iside));
    ibnd= isnan(zb) & ~isnan(zc);
    mskc(ibnd)=2;
    msk(ii1b(iside):ii2b(iside),jj1b(iside):jj2b(iside))=mskc;
end

msk(z>zlev(2))=0;
