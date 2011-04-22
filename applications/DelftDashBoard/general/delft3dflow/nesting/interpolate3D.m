function s=interpolate3D(x,y,dplayer,d,it,varargin)
% Interpolate 4d matrix d onto vertical profiles
% If KMax==1, take depth averaged values

tp='data';

if ~isempty(varargin)
    if strcmpi(varargin{1},'u') || strcmpi(varargin{1},'v')
        tp=varargin{1};
    end
end    

nlevels=length(d.levels);
levels=d.levels';

if ndims(dplayer)==3
    kmax=size(dplayer,3);
elseif ndims(dplayer)==2
    % Two boundary points
    kmax=1;
else
    kmax=length(dplayer);
end

xd=d.lon;
yd=d.lat;
[xd,yd]=meshgrid(xd,yd);

x(isnan(x))=1e9;
y(isnan(y))=1e9;

if kmax>1
    % 3D
    for k=1:nlevels
        vald=squeeze(d.data(:,:,k,it));
        switch lower(tp(1))
            case{'u','v'}
                % Do NOT apply diffusion for velocities
                vald=internaldiffusion(vald,'nst',10);
            otherwise
                vald=internaldiffusion(vald,'nst',10);
        end       
        vals(:,:,k)=interp2(xd,yd,vald,x,y);
        vals(isnan(vals))=-9999;
    end
else
    for k=1:nlevels
        vald=squeeze(d.data(:,:,k,it));
        switch lower(tp(1))
            case{'u','v'}
                % Do NOT apply diffusion for velocities
                vald=internaldiffusion(vald,'nst',10);
            otherwise
                vald=internaldiffusion(vald,'nst',10);
        end
        vals(:,:,k)=vald;
    end
    vals=dptavg(squeeze(vals),levels);
    vals=interp2(xd,yd,vals,x,y);
end

if kmax>1
    % 3D
    for i=1:size(vals,1)
        for j=1:size(vals,2)
            val=squeeze(vals(i,j,:));
            ii=find(val>-9000);
            if ~isempty(ii)
                i1=min(ii);
                i2=max(ii);
                depths=levels(i1:i2);
                temps=val(i1:i2);
                
                if size(depths,2)>1
                    depths=depths';
                end
                
                switch lower(tp(1))
                    case{'u','v'}
                        % Set velocities to 0 below where they are not available
                        ddep=depths(end)-depths(end-1);
                        ddep=1;
                        depths=[-100000;depths;depths(end)+ddep;100000];
                        temps =[temps(1);temps;0;0];
                    otherwise
                        depths=[-100000;depths;100000];
                        temps =[temps(1);temps;temps(end)];
                end
                s(i,j,:)=interp1(depths,temps,squeeze(dplayer(i,j,:)));
            else
                s(i,j,1:kmax)=0;
            end
        end
    end
else
    % 2D, compute depth averaged values
    s=vals;
end

%% Depth-averaging
function davg=dptavg(d,levels)
kmax=length(levels);
thck=zeros(kmax,1);
thck(1)=0.5*levels(1);
for i=2:kmax-1
    thck(i)=0.5*(levels(i)-levels(i-1))+0.5*(levels(i+1)-levels(i));
end
thck(kmax)=thck(kmax-1);
thckm=zeros(size(d));
for k=1:kmax
    dtmp=squeeze(d(:,:,k));
    thckt=zeros(size(dtmp))+thck(k);
    thckt(isnan(dtmp))=NaN;
    thckm(:,:,k)=thckt;
end
davg=d.*thckm;
davg=nansum(davg,3);
davg=davg./nansum(thckm,3);

