function msk=sfincs_make_mask(x,y,z,zlev,varargin)
% Leijnse april 18: included option to exclude points via polygon input

xy_in=[];
xy_ex=[];
xy_bnd_wl=[];
xy_bnd_out=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'includepolygon'}
                xy_in=varargin{ii+1};
            case{'excludepolygon'}
                xy_ex=varargin{ii+1};
            case{'waterlevelboundarypolygon'}
                xy_bnd_wl=varargin{ii+1};
            case{'outflowboundarypolygon'}
                xy_bnd_out=varargin{ii+1};
        end
    end
end

% Set some defaults
if ~isempty(xy_in)
    if ~isfield(xy_in,'zmin')
        xy_in(1).zmin=[];
    end    
    if ~isfield(xy_in,'zmax')
        xy_in(1).zmax=[];
    end    
    for ip=1:length(xy_in)
        if isempty(xy_in(ip).zmin)
            xy_in(ip).zmin=-99999.0;
        end
        if isempty(xy_in(ip).zmax)
            xy_in(ip).zmax=99999.0;
        end
    end
end
if ~isempty(xy_ex)
    if ~isfield(xy_ex,'zmin')
        xy_ex(1).zmin=[];
    end    
    if ~isfield(xy_ex,'zmax')
        xy_ex(1).zmin=[];
    end    
    for ip=1:length(xy_ex)
        if isempty(xy_ex(ip).zmin)
            xy_ex(ip).zmin=-99999.0;
        end
        if isempty(xy_ex(ip).zmax)
            xy_ex(ip).zmax=99999.0;
        end
    end
end
if ~isempty(xy_bnd_wl)
    if ~isfield(xy_bnd_wl,'zmin')
        xy_bnd_wl(1).zmin=[];
    end    
    if ~isfield(xy_bnd_wl,'zmax')
        xy_bnd_wl(1).zmin=[];
    end    
    for ip=1:length(xy_bnd_wl)
        if isempty(xy_bnd_wl(ip).zmin)
            xy_bnd_wl(ip).zmin=-99999.0;
        end
        if isempty(xy_bnd_wl(ip).zmax)
            xy_bnd_wl(ip).zmax=99999.0;
        end
    end
end
if ~isempty(xy_bnd_out)
    if ~isfield(xy_bnd_out,'zmin')
        xy_bnd_out(1).zmin=[];
    end    
    if ~isfield(xy_bnd_out,'zmax')
        xy_bnd_out(1).zmin=[];
    end    
    for ip=1:length(xy_bnd_out)
        if isempty(xy_bnd_out(ip).zmin)
            xy_bnd_out(ip).zmin=-99999.0;
        end
        if isempty(xy_bnd_out(ip).zmax)
            xy_bnd_out(ip).zmax=99999.0;
        end
    end
end



% Global
msk=zeros(size(z))+1;
msk(z<zlev(1))=0;
msk(z>zlev(2))=0;
msk(isnan(z))=0;

% Include polygons
if ~isempty(xy_in)
    % Add points within polygon
    for ip=1:length(xy_in)
        if length(xy_in(ip).x)>1
            xp=xy_in(ip).x;
            yp=xy_in(ip).y;
            inp=inpolygon(x,y,xp,yp) & z>=xy_in(ip).zmin & z<=xy_in(ip).zmax;
            msk(inp)=1;
        end
    end
end

% Exclude polygons
if ~isempty(xy_ex)
    % Throw away points within polygons
    for ip=1:length(xy_ex)
        if length(xy_ex(ip).x)>1
            xp=xy_ex(ip).x;
            yp=xy_ex(ip).y;
            inp=inpolygon(x,y,xp,yp) & z>=xy_ex(ip).zmin & z<=xy_ex(ip).zmax;
            msk(inp)=0;
        end
    end
end

if ~isempty(xy_bnd_wl) || ~isempty(xy_bnd_out)
    
    % Now first find cells that are potential boundary cells (i.e. any point that is active and has at least one inactive neighbor)
    msk2=zeros(size(x,1)+2,size(x,2)+2);
    msk2(2:end-1,2:end-1)=msk;
    msk4=zeros(4,size(x,1),size(x,2));
    msk4(1,:,:)=msk2(1:end-2,2:end-1);
    msk4(2,:,:)=msk2(3:end,  2:end-1);
    msk4(3,:,:)=msk2(2:end-1,1:end-2);
    msk4(4,:,:)=msk2(2:end-1,3:end  );
    msk4=squeeze(min(msk4,[],1)); % msk4 is now an nmax*mmax array with zeros for cells that have an inactive neighbor
    mskbnd=zeros(size(x));
    mskbnd(msk==1 & msk4==0)=1; % array with potential boundary cells
    
    % Water level boundaries
    if ~isempty(xy_bnd_wl)
        % Add points within polygon
        for ip=1:length(xy_bnd_wl)
            if length(xy_bnd_wl(ip).x)>1
                xp=xy_bnd_wl(ip).x;
                yp=xy_bnd_wl(ip).y;
                inp=inpolygon(x,y,xp,yp) & mskbnd==1 & z>=xy_bnd_wl(ip).zmin & z<=xy_bnd_wl(ip).zmax;
                msk(inp)=2;
            end
        end
    end
    
    % Outflow boundaries
    if ~isempty(xy_bnd_out)
        % Add points within polygon
        for ip=1:length(xy_bnd_out)
            if length(xy_bnd_out(ip).x)>1
                xp=xy_bnd_out(ip).x;
                yp=xy_bnd_out(ip).y;
                inp=inpolygon(x,y,xp,yp) & mskbnd==1 & z>=xy_bnd_out(ip).zmin & z<=xy_bnd_out(ip).zmax;
                msk(inp)=3;
            end
        end
    end
    
end
