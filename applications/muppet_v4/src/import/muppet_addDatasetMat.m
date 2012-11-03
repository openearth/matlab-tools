function varargout=muppet_addDatasetMat(varargin)

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'read'}
                % Read file data
                dataset=varargin{ii+1};
                parameter=[];
                if length(varargin)==3
                    parameter=varargin{ii+1};
                end
                dataset=read(dataset,parameter);
                varargout{1}=dataset;
            case{'import'}
                % Import data
                dataset=varargin{ii+1};
                dataset=import(dataset);
                varargout{1}=dataset;
        end
    end
end

%%
function dataset=read(dataset,parameter)

% Set for each dataset:
% parametertimesequal
% parameterstationsequal
% adjustname
%
% Reads for dataset:
% nrparameters
% parameternames;
%
% Reads for each parameter:
% name
% type
% active
% dimensions (nrm,nrn,nrk,nrt,nrstations,stations,nrdomains,domains,nrsubfields,subfields,parametername,active)
% times (if not a time series), stations

% Should move to xml file

dataset.parametertimesequal=1;
dataset.parameterstationsequal=0;
dataset.parameterxequal=1;
dataset.parameteryequal=1;
dataset.parameterzequal=1;
dataset.adjustname=1;

s=load(dataset.filename);

dataset.data=s;

for j=1:length(s.parameters)
    dataset.parameternames{j}=s.parameters(j).parameter.name;
end

% Coordinate System
dataset.coordinatesystem.name='undefined';
dataset.coordinatesystem.type='projected';
if isfield(s,'coordinatesystem')
    dataset.coordinatesystem=s.coordinatesystem;
end
cs=dataset.coordinatesystem;

for ii=1:length(s.parameters)
    
    % Set default parameter properties
    par=[];
    
    par.coordinatesystem=cs;
    
    par.parametername=s.parameters(ii).parameter.name;
    
    if isfield(s.parameters(ii).parameter,'size')
        par.size=s.parameters(ii).parameter.size;
    else
        par.size(1)=length(s.parameters(ii).parameter.time);
        par.size(2)=0;
        par.size(3)=size(s.parameters(ii).parameter.x,1);
        par.size(4)=size(s.parameters(ii).parameter.x,2);
        par.size(5)=0;
    end

    par.times=[];
    
    par.nrstations=0;
    par.stations={''};
    
    par.nrdomains=0;
    par.domains={''};
    
    par.nrsubfields=0;
    par.subfields={''};
    
    par.nrblocks=0;
    
    par.nrquantities=1;
    
    if isfield(s.parameters(ii).parameter,'time')
        par.times=s.parameters(ii).parameter.time;
    end
    
    if isfield(s.parameters(ii).parameter,'stations')
        par.stations=s.parameters(ii).parameter.stations;
        par.nrstations=length(par.stations);
    end

    par.quantity='vector2d';
    if isfield(s.parameters(ii).parameter,'quantity')
        par.quantity=s.parameters(ii).parameter.quantity;
    end
    
    dataset.parameters(ii).parameter=par;
    dataset.parameters(ii).parameter.active=1;

end

dataset.nrparameters=length(s.parameters);
dataset.nrquantities=2;

%%
function dataset=import(dataset)
%
%s=load(dataset.filename);
s=dataset.data;

for ipar=1:length(s.parameters)
    if strcmpi(s.parameters(ipar).parameter.name,dataset.parametername)
        parameter=s.parameters(ipar).parameter;
        break
    end
end

m=dataset.m;
n=dataset.n;
k=dataset.k;
timestep=dataset.timestep;

if m==0
    m=[];
end
if n==0
    n=[];
end

if isempty(m)
    if dataset.size(3)>0
        m=1:dataset.size(3);
    else
        m=1;
    end
end
if isempty(n)
    if dataset.size(4)>0
        n=1:dataset.size(4);
    else
        n=1;
    end
end
if isempty(k)
    if dataset.size(5)>0
        k=1:dataset.size(5);
    else
        k=1;
    end
end
if isempty(timestep) || dataset.timestep==0
    if dataset.size(1)>0
        timestep=1:dataset.size(1);
    else
        timestep=1;
    end
end


% Find out the shape of data that is required
if dataset.size(2)>0
    % Data from station
    if length(timestep)>1
        % Time varying
        if length(k)>1
            shp='timestackstation';
        else
            shp='timeseriesstation';
        end
    else
        % Profile
        shp='profilestation';
    end
else
    % Data from matrix
    if timestep==0 || length(timestep)>1
        % Time-varying
        if m==0 || length(m)>1
            shp='timestackm';
        elseif n==0 || length(n)>1
            shp='timestackn';
        elseif k==0 || length(k)>1
            shp='timestackk';
        else
            shp='timeseries';
        end
    else
        % Constant
        if length(m)>1
            if length(n)>1
                shp='map2d';
            elseif length(k)>1
                shp='crossection2dm';
            else
                shp='crossection1dm';
            end
        elseif length(n)>1
            if length(k)>1
                shp='crossection2dn';
            else
                shp='crossection1dn';
            end
        else
            shp='profile';
        end
    end
end

% Find station number
istation=0;
if isfield(dataset,'station')
    if ~isempty(dataset.station)
        istation=strmatch(dataset.station,parameter.stations,'exact');
    else
        istation=1:dataset.size(2);
    end    
end

xname='x';
yname='y';
uname='u';
vname='v';
valname='val';

switch shp
    case{'polyline'}
                dataset.x=parameter.x;
                dataset.y=parameter.y;
                dataset.type='polyline2d';
                dataset.tc='c';
        
    case{'timestackstation'}
        
    case{'timeseriesstation'}
        switch dataset.quantity
            case{'location'}
                timestep=1:length(parameter.time);
                dataset.x=parameter.(xname)(timestep,istation);
                dataset.y=parameter.(yname)(timestep,istation);
                dataset.times=parameter.time;
                dataset.type='track';
                dataset.tc='c';
            case{'vector'}
                dataset.x=parameter.time;
                dataset.u=parameter.(uname)(istation,timestep);
                dataset.v=parameter.(vname)(istation,timestep);
                dataset.type='timeseriesvector';
                dataset.tc='c';
            otherwise
                % scalar
                dataset.x=parameter.time;
                dataset.y=parameter.(valname)(istation,timestep);
                dataset.type='timeseriesscalar';
                dataset.tc='c';
        end
    case{'profilestation'}
    case{'timestackm'}
    case{'timestackn'}
    case{'timestackk'}
    case{'timeseries'}
    case{'map2d'}
        switch dataset.quantity
            case{'scalar'}
                dataset.x=parameter.x;
                dataset.y=parameter.y;
                dataset.z=parameter.val;
                dataset.zz=parameter.val;
                dataset.type='map2dscalar';
                dataset.tc='t';
            case{'vector2d'}
                dataset.x=parameter.x;
                dataset.y=parameter.y;
                dataset.u=squeeze(parameter.u(timestep,:,:));
                dataset.v=squeeze(parameter.v(timestep,:,:));
                dataset.type='map2dvector2d';
                dataset.tc='t';
        end
    case{'crossection1dm'}
        switch dataset.quantity
            case{'location'}
                dataset.x=parameter.x;
                dataset.y=parameter.y;
                dataset.type='polyline2d';
                dataset.tc='c';
            otherwise
                % scalar
                dataset.x=parameter.time;
                dataset.y=parameter.(valname)(istation,timestep);
                dataset.type='timeseriesscalar';
                dataset.tc='c';
        end
    case{'crossection1dn'}
    case{'crossection2dm'}
    case{'crossection2dn'}
    case{'profile'}        
end


% % Determine component
% switch dataset.quantity
%     case{'vector2d','vector3d'}
%         if isempty(dataset.component)
%             dataset.component='vector';
%         end
%         % Vector, compute components if necessary
%         switch lower(dataset.component)
%             case('magnitude')
%                 d.Val=sqrt(d.XComp.^2+d.YComp.^2);
%                 dataset.quantity='scalar';
%             case('angle (radians)')
%                 d.Val=mod(0.5*pi-atan2(d.YComp,d.XComp),2*pi);
%                 dataset.quantity='scalar';
%             case('angle (degrees)')
%                 d.Val=mod(0.5*pi-atan2(d.YComp,d.XComp),2*pi)*180/pi;
%                 dataset.quantity='scalar';
%             case('m-component')
%                 d.Val=d.XComp;
%                 dataset.quantity='scalar';
%             case('n-component')
%                 d.Val=d.YComp;
%                 dataset.quantity='scalar';
%             case('x-component')
%                 d.Val=d.XComp;
%                 dataset.quantity='scalar';
%             case('y-component')
%                 d.Val=d.YComp;
%                 dataset.quantity='scalar';
%         end
% end
%
% % Compute y value for cross sections
% plotcoordinate=[];
% switch tp
%     case{'timestackm','timestackn','crossection2dm','crossection1dm','crossection2dn','crossection1dn'}
%         switch(lower(dataset.plotcoordinate))
%             case{'x'}
%                 x=squeeze(d.X);
%             case{'y'}
%                 x=squeeze(d.Y);
%             case{'pathdistance'}
%                 x=pathdistance(squeeze(d.X),squeeze(d.Y));
%             case{'revpathdistance'}
%                 x=pathdistance(squeeze(d.X),squeeze(d.Y));
%                 x=x(end:-1:1);
%         end
%         plotcoordinate=x;
% end
%
% % Set empty values
% dataset.x=[];
% dataset.x=[];
% dataset.y=[];
% dataset.z=[];
% dataset.xz=[];
% dataset.yz=[];
% dataset.zz=[];
% dataset.u=[];
% dataset.v=[];
% dataset.w=[];
%
% switch tp
%     case{'timeseriesstation','timeseries'}
%         dataset.type='timeseries';
%         dataset.x=d.Time;
%         switch dataset.quantity
%             case{'scalar'}
%                 dataset.y=d.Val;
%             case{'vector2d'}
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%             case{'vector3d'}
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%         end
%     case{'timestackstation','timestackk'}
%         dataset.type='timestack';
%         dataset.x=d.Time;
%         dataset.y=d.Z;
%         switch dataset.quantity
%             case{'scalar'}
%                 dataset.y=d.Val;
%             case{'vector2d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%             case{'vector3d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.ZComp;
%         end
%     case{'profilestation','profile'}
%         dataset.type='xy';
%         dataset.y=d.Z;
%         switch dataset.quantity
%             case{'scalar'}
%                 dataset.x=d.Val;
%             case{'vector2d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%             case{'vector3d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.ZComp;
%         end
%     case{'timestackm','timestackn'}
%         dataset.type='timestack';
%         dataset.x=d.Time;
%         dataset.y=plotcoordinate;
%         switch dataset.quantity
%             case{'scalar'}
%                 dataset.y=d.Val;
%             case{'vector2d'}
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%         end
%     case{'map2d'}
%         dataset.type='map2d';
%         dataset.x=d.X;
%         dataset.y=d.Y;
%         switch dataset.quantity
%             case{'scalar','boolean'}
%                 dataset.z=d.Val;
%             case{'grid'}
%                 dataset.xdam=d.XDam;
%                 dataset.ydam=d.YDam;
%             case{'vector2d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%             case{'vector3d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%         end
%     case{'crossection2dm','crossection2dn'}
%         dataset.type='crossection2d';
%         dataset.x=plotcoordinate;
%         dataset.y=d.Z;
%         switch dataset.quantity
%             case{'scalar'}
%                 dataset.z=d.Val;
%             case{'vector2d'}
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%             case{'vector3d'}
%                 dataset.u=d.XComp;
%                 dataset.v=d.ZComp;
%         end
%     case{'crossection1dm','crossection1dn'}
%         dataset.type='crossection1d';
%         dataset.x=plotcoordinate;
%         switch dataset.quantity
%             case{'scalar'}
%                 dataset.y=d.Val;
%             case{'vector2d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.YComp;
%             case{'vector3d'}
%                 % Why would you want this ?
%                 dataset.u=d.XComp;
%                 dataset.v=d.ZComp;
%         end
% end
%
% dataset.xz=dataset.x;
% dataset.yz=dataset.y;
% dataset.zz=dataset.z;
%
% dataset.type=[dataset.type dataset.quantity];
%
% if isempty(dataset.time) || dataset.size(1)<=1
%     dataset.tc='c';
% else
%     dataset.tc='t';
%     dataset.availabletimes=times;
% %    dataset.availablemorphtimes=data.morphtimes;
% end
%
% if isfield(dataset,'time')
%     if isfield(dataset,'timestep')
%         dataset=rmfield(dataset,'timestep');
%     end
% end
