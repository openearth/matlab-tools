function varargout = readTideModel(fname,varargin)

xp=[];
yp=[];
xl=[];
yl=[];
tp='h';
getd=0;
constituent='all';
incldep=0;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'x'}
                xp=varargin{i+1};
                if size(xp,1)==1 || size(xp,2)==1
                    if size(xp,2)==1
                        xp=xp';
                    end
                    inptp='vector';
                else
                    inptp='matrix';
                end
                opt = 'interp';
            case{'y'}
                yp=varargin{i+1};
                if size(yp,1)==1 || size(yp,2)==1
                    if size(yp,2)==1
                        yp=yp';
                    end
                    inptp='vector';
                else
                    inptp='matrix';
                end
                opt = 'interp';
            case{'xlim'}
                xl=varargin{i+1};
                opt = 'limits';
            case{'ylim'}
                yl=varargin{i+1};
                opt = 'limits';
            case{'type'}
                tp=varargin{i+1};
            case{'constituent'}
                constituent=varargin{i+1};
            case{'includedepth'}
                incldep=1;
                getd=1;
        end
    end
end

gt=[];
switch lower(tp)
    case{'h','z'}
        gt(1).ampstr='tidal_amplitude_h';
        gt(1).phistr='tidal_phase_h';
    case{'vel'}
        gt(1).ampstr='tidal_amplitude_u';
        gt(1).phistr='tidal_phase_u';
        gt(2).ampstr='tidal_amplitude_v';
        gt(2).phistr='tidal_phase_v';
    case{'q'}
        gt(1).ampstr='tidal_amplitude_U';
        gt(1).phistr='tidal_phase_U';
        gt(2).ampstr='tidal_amplitude_V';
        gt(2).phistr='tidal_phase_V';
    case{'u'}
        gt(1).ampstr='tidal_amplitude_u';
        gt(1).phistr='tidal_phase_u';
    case{'v'}
        gt(1).ampstr='tidal_amplitude_v';
        gt(1).phistr='tidal_phase_v';
    case{'all'}
        gt(1).ampstr='tidal_amplitude_h';
        gt(1).phistr='tidal_phase_h';
        gt(2).ampstr='tidal_amplitude_u';
        gt(2).phistr='tidal_phase_u';
        gt(3).ampstr='tidal_amplitude_v';
        gt(3).phistr='tidal_phase_v';
end

% Get limits
switch opt
    case{'interp'}
        xmin=min(min(xp));
        ymin=min(min(yp));
        xmax=max(max(xp));
        ymax=max(max(yp));
    case{'limits'}
        xmin=xl(1);
        ymin=yl(1);
        xmax=xl(2);
        ymax=yl(2);
end

% Get dimensions
x=nc_varget(fname,'lon');
y=nc_varget(fname,'lat');
xu=nc_varget(fname,'lon_u');
yu=nc_varget(fname,'lat_u');
xv=nc_varget(fname,'lon_v');
yv=nc_varget(fname,'lat_v');

cl=nc_varget(fname,'tidal_constituents');

for i=1:size(cl,1)
    cons{i}=upper(deblank(cl(i,:)));
end

nrcons=length(cons);

constituent=lower(constituent);
if strcmpi(constituent,'all')
    ic1=1;
    ic2=nrcons;
else
    ic1=strmatch(constituent,lower(cons),'exact');
    ic2=1;
end

dy=(ymax-ymin)/10;

iy1=find(y<=ymin-dy,1,'last');
iy2=find(y>=ymax+dy,1,'first');

dx=(xmax-xmin)/10;

iok=0;
% Assuming global dataset
% First check situation
if xmin>=x(1) && xmax<=x(end)
    % No problems
    iok=1;
    ix1=find(x<=xmin-dx,1,'last');
    ix2=find(x>=xmax+dx,1,'first');
elseif xmin<x(1) && xmax<x(1)
    % Both to the left of the data
    % Check if moving the data 360 deg to the left helps
    xtmp=x-360;
    xutmp=xu-360;
    xvtmp=xv-360;
elseif xmin>x(1) && xmax>x(1)
    % Both to the right of the data
    % Check if moving the data 360 deg to the right helps
    xtmp=x+360;
    xutmp=xu+360;
    xvtmp=xv+360;
else
    % Probably pasting necessary
    xtmp=x;
end


if ~iok
    % Check again
    if xmin>=xtmp(1) && xmax<=xtmp(end)
        % No problems now, keep new x value
        iok=1;
        x=xtmp;
        xu=xutmp;
        xv=xvtmp;
        ix1=find(x<=xmin-dx,1,'last');
        ix2=find(x>=xmax+dx,1,'first');
    end
end

if ~iok
    % Needs pasting

    % Left hand side
    if xmin<x(1)
        xtmp=x-360;
    else
        xtmp=x;
    end
    ix1left=find(xtmp<=xmin,1,'last');
    ix2left=length(x);

    lonleft=xtmp(ix1left:ix2left);
    
    % Right hand side
    if xmax>x(end)
        xtmp=x+360;
    else
        xtmp=x;
    end
    ix1right=1;
    ix2right=find(xtmp>=xmax,1,'first');    

    lonright=xtmp(ix1right:ix2right);

end

for i=1:length(gt)
    
    if ~iok
        % Pasting needed
        ampleft  = nc_varget(fname,gt(i).ampstr,[ix1left-1 iy1-1 ic1-1],[ix2left-ix1left+1 iy2-iy1+1 ic2]);
        phileft  = nc_varget(fname,gt(i).phistr,[ix1left-1 iy1-1 ic1-1],[ix2left-ix1left+1 iy2-iy1+1 ic2]);
        if getd
            dpleft   = nc_varget(fname,'depth',[ix1left-1 iy1-1],[ix2left-ix1left+1 iy2-iy1+1]);
        end
        ampright = nc_varget(fname,gt(i).ampstr,[ix1right-1 iy1-1 ic1-1],[ix2right-ix1right+1 iy2-iy1+1 ic2]);
        phiright = nc_varget(fname,gt(i).phistr,[ix1right-1 iy1-1 ic1-1],[ix2right-ix1right+1 iy2-iy1+1 ic2]);
        if getd
            dpright  = nc_varget(fname,'depth',[ix1right-1 iy1-1],[ix2right-ix1right+1 iy2-iy1+1]);
        end
        
        % Now paste
        gt(i).amp   = permute([permute(ampleft,[2 1 3]) permute(ampright,[2 1 3])],[2 1 3]);
        gt(i).phi   = permute([permute(phileft,[2 1 3]) permute(phiright,[2 1 3])],[2 1 3]);
        if getd
            depth = [dpleft' dpright'];
        end
        lon = [lonleft;lonright];
        lat=y(iy1:iy2);
    else
        gt(i).amp   = nc_varget(fname,gt(i).ampstr,[ix1-1 iy1-1 ic1-1],[ix2-ix1+1 iy2-iy1+1 ic2]);
        gt(i).phi   = nc_varget(fname,gt(i).phistr,[ix1-1 iy1-1 ic1-1],[ix2-ix1+1 iy2-iy1+1 ic2]);
        if getd
            depth = nc_varget(fname,'depth',[ix1-1 iy1-1],[ix2-ix1+1 iy2-iy1+1]);
            depth = depth';
        end
        lonz=x(ix1:ix2);
        latz=y(iy1:iy2);
        lonu=xu(ix1:ix2);
        latu=yu(iy1:iy2);
        lonv=xv(ix1:ix2);
        latv=yv(iy1:iy2);
    end
    gt(i).amp(gt(i).amp>100)=NaN;
    gt(i).amp=permute(gt(i).amp,[2 1 3]);
    gt(i).phi=permute(gt(i).phi,[2 1 3]);
    gt(i).phi(gt(i).amp==0)=NaN;
    gt(i).amp(gt(i).amp==0)=NaN;
end

switch opt
    case{'interp'}
        xp(isnan(xp))=1e9;
        yp(isnan(yp))=1e9;
        for i=1:length(gt)
            a=[];
            p=[];
            switch gt(i).ampstr
                case{'tidal_amplitude_h'}
                    lon=lonz;
                    lat=latz;
                case{'tidal_amplitude_u','tidal_amplitude_U'}
                    lon=lonu;
                    lat=latu;
                case{'tidal_amplitude_v','tidal_amplitude_v'}
                    lon=lonv;
                    lat=latv;
            end

            for k=1:size(gt(i).phi,3)
                % Amplitude
%                a=internaldiffusion(squeeze(gt(i).amp(:,:,k)));
%                b=interp2(lon,lat,internaldiffusion(squeeze(gt(i).amp(:,:,k))),xp,yp);
                if strcmpi(inptp,'matrix')
                    a(k,:,:)=interp2(lon,lat,internaldiffusion(squeeze(gt(i).amp(:,:,k))),xp,yp);
                else
                    a(k,:)=interp2(lon,lat,internaldiffusion(squeeze(gt(i).amp(:,:,k))),xp,yp);
                end
                % Phase (bit more difficult)
                sinp=sin(squeeze(gt(i).phi(:,:,k))*pi/180);
                cosp=cos(squeeze(gt(i).phi(:,:,k))*pi/180);
                sinp=internaldiffusion(sinp);
                cosp=internaldiffusion(cosp);
                sinpi=interp2(lon,lat,sinp,xp,yp);
                cospi=interp2(lon,lat,cosp,xp,yp);
                if strcmpi(inptp,'matrix')
                    p(k,:,:)=mod(180*atan2(sinpi,cospi)/pi,360);
                else
                    p(k,:)=mod(180*atan2(sinpi,cospi)/pi,360);
                end
            end
            varargout{2*i-1}=a;
            varargout{2*i}=p;
            if incldep
                varargout{2*length(gt)+1}=interp2(lon,lat,depth,xp,yp);
                varargout{2*length(gt)+2}=cons;
            else
                varargout{2*length(gt)+1}=cons;
            end
        end
        
    case{'limits'}
        varargout{1}=lon;
        varargout{2}=lat;
        for i=1:length(gt)
            varargout{2*i+1}=gt(i).amp;
            varargout{2*i+2}=gt(i).phi;
        end
        if incldep
            varargout{2*length(gt)+3}=depth;
            varargout{2*length(gt)+4}=cons;
        else
            varargout{2*length(gt)+3}=cons;
        end
end
