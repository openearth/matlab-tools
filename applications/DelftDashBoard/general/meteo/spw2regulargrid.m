function [t,ug,vg,pg,varargout]=spw2regulargrid(spwfile,xg,yg,dt,varargin)
% Interpolates data from spiderweb file onto rectangular grid
% 
% e.g.
% gavprs=101200.0         % background pressure (Pa) - function returns absolute pressure
% interpolation='linear'; % determines locations of intermediate track points, can be either linear or spline
% dt=60;                  % time step in minutes, if left empty, only wind and pressure fields of the original track will be created 
% mergefrac=0.5;          % merge fraction 
% [xg,yg]=meshgrid(-70:0.1:-50,20:0.1:30);
% [t,ug,vg,pg,frac]=spw2regular('ike.spw',xg,yg,dt,'interpolation',interpolation,'backgroundpressure',backgroundpressure,'mergefrac',mergefrac);

mergefrac=[];
interpmethod='spline';
backgroundpressure=101500;

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'mergefrac'}
                mergefrac=varargin{ii+1};
            case{'interpolation'}
                interpmethod=varargin{ii+1};
            case{'backgroundpressure'}
                backgroundpressure=varargin{ii+1};
        end
    end
end                

% Read data
info=asciiwind('open',spwfile);
quantity={'wind_speed'  'wind_from_direction'  'p_drop'};
rows=1:info.Header.n_rows;
cols=1:info.Header.n_cols;
dx=info.Header.spw_radius/info.Header.n_rows;
dphi=360/info.Header.n_cols;
nt0=length(info.Data);
for it=1:nt0
    t0(it)=info.Data(it).time;
end

% Data
wvel0=asciiwind('read',info,quantity{1},1:nt0,rows,cols);
wdir0=asciiwind('read',info,quantity{2},1:nt0,rows,cols);
pdrp0=asciiwind('read',info,quantity{3},1:nt0,rows,cols);

for it=1:nt0
    xeye(it)=info.Data(it).x_spw_eye;
    yeye(it)=info.Data(it).y_spw_eye;
end

if ~isempty(dt)
    t=t0(1):dt/1440:t0(end);
    nt=length(t);
    switch lower(interpmethod)
        case{'spline'}
            xeye=spline(t0,xeye,t);
            yeye=spline(t0,yeye,t);
        case{'linear'}
            xeye=interp1(t0,xeye,t);
            yeye=interp1(t0,yeye,t);
    end
else
    t=t0;
    nt=nt0;
end

% Allocate array
ug=zeros(nt,size(xg,1),size(xg,2));
ug(ug==0)=NaN;
vg=ug;
pg=ug;
frac=ug;

for it=1:nt

    if ~isempty(dt)
        [it1,it2,tfrac1,tfrac2]=find_time_indices_and_factors(t0,t(it));
    else
        it1=it;
        it2=0;
    end
        
    if it2==0
        % Just read one time
        wvel=squeeze(wvel0(it1,:,:));
        wdir=0.5*pi-pi*squeeze(wdir0(it1,:,:))/180; % Convert to cartesian (but still where the winds are coming from)
        pdrp=squeeze(pdrp0(it1,:,:));
    else
        wvel1=squeeze(wvel0(it1,:,:));
        wdir1=0.5*pi-pi*squeeze(wdir0(it1,:,:))/180; % Convert to cartesian (but still where the winds are coming from)
        pdrp1=squeeze(pdrp0(it1,:,:));
        wvel2=squeeze(wvel0(it2,:,:));
        wdir2=0.5*pi-pi*squeeze(wdir0(it2,:,:))/180; % Convert to cartesian (but still where the winds are coming from)
        pdrp2=squeeze(pdrp0(it2,:,:));
        wvel=tfrac1*wvel1+tfrac2*wvel2;
        wdir=tfrac1*wdir1+tfrac2*wdir2;
        pdrp=tfrac1*pdrp1+tfrac2*pdrp2;
    end
    
    wvel(:,end+1)=wvel(:,1);
    wdir(:,end+1)=wdir(:,1);
    pdrp(:,end+1)=pdrp(:,1);
    
    % Convert to coming from
    u=-wvel.*cos(wdir);
    v=-wvel.*sin(wdir);

    % Interpolate
    if isempty(mergefrac)
        ug(it,:,:)=radial2regular(xg,yg,xeye(it),yeye(it),dx,dphi,u,'nautical');
    else
        [ug(it,:,:),frac0]=radial2regular(xg,yg,xeye(it),yeye(it),dx,dphi,u,'nautical','mergefrac',mergefrac);
        frac(it,:,:)=frac0;
    end
    vg(it,:,:)=radial2regular(xg,yg,xeye(it),yeye(it),dx,dphi,v,'nautical');
    pg(it,:,:)=backgroundpressure-radial2regular(xg,yg,xeye(it),yeye(it),dx,dphi,pdrp,'nautical');
    
end

varargout{1}=frac;

