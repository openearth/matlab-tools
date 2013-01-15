function varargout=muppet_addDatasetMat(varargin)

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'read'}
                % Read file data
                dataset=varargin{ii+1};
                dataset=read(dataset);
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
function dataset=read(dataset)

% Set for each dataset:
% adjustname
%
% Reads for dataset:
%
% Reads for each parameter:
% name
% type
% active
% dimensions (size,stations,nrdomains,domains,nrsubfields,subfields,active)
% times (if not a time series), stations

% Should move to xml file

dataset.adjustname=1;

s=load(dataset.filename);

dataset.data=s;

% Coordinate System
dataset.coordinatesystem.name='undefined';
dataset.coordinatesystem.type='projected';
if isfield(s,'coordinatesystem')
    dataset.coordinatesystem=s.coordinatesystem;
end
cs=dataset.coordinatesystem;

for ii=1:length(s.parameters)
    
    % Set default parameter properties
    dataset.parameters(ii).parameter=[];
    dataset.parameters(ii).parameter=muppet_setDefaultParameterProperties(dataset.parameters(ii).parameter);
    dataset.parameters(ii).parameter.name=s.parameters(ii).parameter.name;
    
    dataset.parameters(ii).parameter.coordinatesystem=cs;
    
    % Determine size (if not available in parameter structure)
    if isfield(s.parameters(ii).parameter,'size')
        dataset.parameters(ii).parameter.size=s.parameters(ii).parameter.size;
    else
        dataset.parameters(ii).parameter.size(1)=length(s.parameters(ii).parameter.time);
        dataset.parameters(ii).parameter.size(2)=0;
        dataset.parameters(ii).parameter.size(3)=size(s.parameters(ii).parameter.x,1);
        dataset.parameters(ii).parameter.size(4)=size(s.parameters(ii).parameter.x,2);
        dataset.parameters(ii).parameter.size(5)=0;
    end
    
    % Time
    if isfield(s.parameters(ii).parameter,'time')
        dataset.parameters(ii).parameter.times=s.parameters(ii).parameter.time;
    end

    % Stations
    if isfield(s.parameters(ii).parameter,'stations')
        dataset.parameters(ii).parameter.stations=s.parameters(ii).parameter.stations;
    end

    % Quantity
    if isfield(s.parameters(ii).parameter,'quantity')
        dataset.parameters(ii).parameter.quantity=s.parameters(ii).parameter.quantity;
    end

end

%%
function dataset=import(dataset)

% File has already been loaded in read function
s=dataset.data;

% Find parameter to be read
for ipar=1:length(s.parameters)
    if strcmpi(s.parameters(ipar).parameter.name,dataset.parameter)
        parameter=s.parameters(ipar).parameter;
        break
    end
end

[timestep,istation,m,n,k]=muppet_findDataIndices(dataset);
orishp=muppet_findRawDataShape(dataset.size);
shp=muppet_findDataShape(dataset.size,timestep,istation,m,n,k);

if isfield(parameter,dataset.timename)
    t=parameter.(dataset.timename)(timestep);
end
if isfield(parameter,dataset.xname)
    switch dataset.quantity
        case{'location'}
            x=parameter.(dataset.xname)(timestep,m);
        otherwise
            x=parameter.(dataset.xname)(m,n);
    end
end
if isfield(parameter,dataset.yname)
    switch dataset.quantity
        case{'location'}
            y=parameter.(dataset.yname)(timestep,m);
        otherwise
            y=parameter.(dataset.yname)(m,n);
    end
end
if isfield(parameter,dataset.zname)
    z=parameter.(dataset.zname)(m,n);
end

% Get values
val=extractmatrix(parameter,dataset.valname,orishp,timestep,istation,m,n,k);
u=extractmatrix(parameter,dataset.uname,orishp,timestep,istation,m,n,k);
v=extractmatrix(parameter,dataset.vname,orishp,timestep,istation,m,n,k);
w=extractmatrix(parameter,dataset.wname,orishp,timestep,istation,m,n,k);
uamplitude=extractmatrix(parameter,dataset.uamplitudename,orishp,timestep,istation,m,n,k);
vamplitude=extractmatrix(parameter,dataset.vamplitudename,orishp,timestep,istation,m,n,k);
uphase=extractmatrix(parameter,dataset.uphasename,orishp,timestep,istation,m,n,k);
vphase=extractmatrix(parameter,dataset.vphasename,orishp,timestep,istation,m,n,k);

dataset.val=val;
dataset.u=u;
dataset.v=v;
dataset.w=w;
dataset.uamplitude=uamplitude;
dataset.vamplitude=vamplitude;
dataset.uphase=uphase;
dataset.vphase=vphase;

if strcmpi(dataset.quantity,'vector')
    dataset.quantity='vector2d';
end

% Determine component
switch dataset.quantity
    case{'vector2d','vector3d'}
        if isempty(dataset.component)
            dataset.component='vector';
        end
        % Vector, compute components if necessary
        switch lower(dataset.component)
            case('magnitude')
                val=sqrt(u.^2+v.^2);
                dataset.quantity='scalar';
            case('angle (radians)')
                val=mod(0.5*pi-atan2(v,u),2*pi);
                dataset.quantity='scalar';
            case('angle (degrees)')
                val=mod(0.5*pi-atan2(v,u),2*pi)*180/pi;
                dataset.quantity='scalar';
            case('m-component')
                val=u;
                dataset.quantity='scalar';
            case('n-component')
                val=v;
                dataset.quantity='scalar';
            case('x-component')
                val=u;
                dataset.quantity='scalar';
            case('y-component')
                val=v;
                dataset.quantity='scalar';
        end
end

%dataset.times=parameter.(dataset.timename);

% Compute y value for cross sections
plotcoordinate=[];
switch shp
    case{'timestackm','timestackn','crossection2dm','crossection1dm','crossection2dn','crossection1dn'}
        switch(lower(dataset.xcoordinate))
            case{'x'}
                x=squeeze(x);
            case{'y'}
                x=squeeze(y);
            case{'pathdistance'}
                x=pathdistance(squeeze(x),squeeze(y));
            case{'revpathdistance'}
                x=pathdistance(squeeze(x),squeeze(y));
                x=x(end:-1:1);
        end
        plotcoordinate=x;
end

% Determine coordinates
switch shp
    case{'polyline'}
        dataset.x=x;
        dataset.y=y;
        tp='polyline2d';
        tc='c';
        dataset.quantity='';
    case{'timestackstation'}
        dataset.x=t;
        dataset.y=z;
        dataset.z=val;
        tp='timestack';
        tc='t';
    case{'timeseriesstation'}
        switch dataset.quantity
            case{'location'}
                dataset.x=x;
                dataset.y=y;
                tp='track';
                tc='c';
                dataset.quantity='';
            otherwise
                dataset.x=t;
                dataset.y=val;
                tp='timeseries';
                tc='t';
        end
    case{'profilestation'}
        dataset.x=val;
        dataset.y=z;
        tp='xy';
        tc='c';
    case{'timestackm','timestackn'}
        dataset.x=t;
        dataset.y=plotcoordinate;        
        dataset.z=val;
        tp='timestack';
        tc='t';
    case{'timestackk'}
        dataset.x=t;
        dataset.y=z;        
        dataset.z=val;
        tp='timestack';
        tc='t';
    case{'timeseries'}
        dataset.x=t;
        dataset.y=val;
        tp='timeseries';
        tc='t';
    case{'map2d'}
        dataset.x=x;
        dataset.y=y;
        dataset.z=val;
        tp='map2d';
        tc='c';
    case{'crossection1dm','crossection1dn'}
        dataset.x=plotcoordinate;
        dataset.y=val;
        tp='xy';
        tc='c';
    case{'crossection2dm','crossection2dn'}
        dataset.x=plotcoordinate;
        dataset.y=z;
        dataset.z=val;
        tp='crosssection2d';
        tc='c';
    case{'profile'}        
        dataset.x=val;
        dataset.y=z;
        tp='xy';
        tc='c';
end

dataset.type=[tp dataset.quantity];

% Exceptions
switch dataset.quantity
    case{'tidalellipse'}
        dataset.type='tidalellipse';
end

switch tc
    case{'t'}
        dataset.tc='c';
    case{'c'}
%         if orishp(1)=='1'
%             dataset.tc='t';
%         else
            dataset.tc='c';
%         end
end

% switch shp
%     case{'polyline'}
%         dataset.x=parameter.(dataset.xname);
%         dataset.y=parameter.(dataset.yname);
%         dataset.type='polyline2d';
%         dataset.tc='c';
%     case{'timestackstation'}        
%     case{'timeseriesstation'}
%         switch dataset.quantity
%             case{'location'}
%                 timestep=1:length(parameter.(dataset.timename));
%                 dataset.x=parameter.(dataset.xname)(timestep,istation);
%                 dataset.y=parameter.(dataset.yname)(timestep,istation);
%                 dataset.times=parameter.(dataset.timename);
%                 dataset.type='track';
%                 dataset.tc='c';
%             case{'vector'}
%                 dataset.x=parameter.(dataset.timename);
%                 dataset.u=parameter.(dataset.uname)(timestep,istation);
%                 dataset.v=parameter.(dataset.vname)(timestep,istation);
%                 dataset.type='timeseriesvector';
%                 dataset.tc='c';
%             otherwise
%                 % scalar
%                 dataset.x=parameter.(dataset.timename);
%                 dataset.y=parameter.(dataset.valname)(timestep,istation);
%                 dataset.type='timeseriesscalar';
%                 dataset.tc='c';
%         end
%     case{'profilestation'}
%     case{'timestackm'}
%     case{'timestackn'}
%     case{'timestackk'}
%     case{'timeseries'}
%     case{'map2d'}
%         dataset.x=parameter.(dataset.xname)(m,n);
%         dataset.y=parameter.(dataset.yname)(m,n);
%         switch orishp
%             case{'00110','00111'}
%                 switch dataset.quantity
%                     case{'scalar'}
%                         dataset.z=squeeze(parameter.(dataset.valname)(m,n));
%                         dataset.type='map2dscalar';
%                         dataset.tc='c';
%                     case{'vector2d'}
%                         dataset.u=squeeze(parameter.(dataset.uname)(m,n));
%                         dataset.v=squeeze(parameter.(dataset.vname)(m,n));
%                         dataset.type='map2dvector2d';
%                         dataset.tc='c';
%                 end
%             case{'10110'}
%                 switch dataset.quantity
%                     case{'scalar'}
%                         dataset.z=parameter.(dataset.valname)(timestep,m,n);
%                         dataset.type='map2dscalar';
%                         dataset.tc='t';
%                     case{'vector2d'}
%                         dataset.u=squeeze(parameter.(dataset.uname)(timestep,m,n));
%                         dataset.v=squeeze(parameter.(dataset.vname)(timestep,m,n));
%                         dataset.type='map2dvector2d';
%                         dataset.tc='t';
%                 end
%             case{'10111'}
%                 switch dataset.quantity
%                     case{'scalar'}
%                         dataset.z=parameter.(dataset.valname)(timestep,m,n,k);
%                         dataset.type='map2dscalar';
%                         dataset.tc='t';
%                     case{'vector2d'}
%                         dataset.u=squeeze(parameter.(dataset.uname)(timestep,m,n,k));
%                         dataset.v=squeeze(parameter.(dataset.vname)(timestep,m,n,k));
%                         dataset.type='map2dvector2d';
%                         dataset.tc='t';
%                 end
%         end
%     case{'crossection1dm'}
%         switch dataset.quantity
%             case{'location'}
%                 dataset.x=parameter.(dataset.xname);
%                 dataset.y=parameter.(dataset.yname);
%                 dataset.type='polyline2d';
%                 dataset.tc='c';
%             case{'vector2d'}
%                 dataset.x=parameter.(dataset.xname);
%                 dataset.y=parameter.(dataset.yname);
%                 dataset.x=parameter.(dataset.timename);
%                 dataset.y=parameter.(dataset.valname)(istation,timestep);
%                 dataset.type='timeseriesscalar';
%                 dataset.tc='t';
%             case{'scalar'}
%                 dataset.x=parameter.(dataset.timename);
%                 dataset.y=parameter.(dataset.valname)(istation,timestep);
%                 dataset.type='timeseriesscalar';
%                 dataset.tc='t';
%             otherwise
%                 % scalar
%         end
%     case{'crossection1dn'}
%     case{'crossection2dm'}
%     case{'crossection2dn'}
%     case{'profile'}        
% end


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

% function parameter=expandmatrix(parameter,fld,orishp)
% 
% if isfield(parameter,fld)
%     if ~isempty(parameter.(fld))
%         
%         p=parameter.(fld);
%         parameter.(fld)=[];
%         
%         for ii=1:length(orishp)
%             switch orishp(ii)
%                 case{'1'}
%                     s{ii}=':';
%                 otherwise
%                     s{ii}='1';
%             end
%         end
%         
%         evalstr=['parameter.(fld)(' s{1} ',' s{2} ',' s{3} ',' s{4} ',' s{5} ')=p;'];
%         eval(evalstr);
%         
%     end
% end

function val=extractmatrix(parameter,fld,orishp,timestep,istation,m,n,k)

nind=0;
val=[];
if isfield(parameter,fld)
    if ~isempty(parameter.(fld))
            if orishp(1)=='1'
                nind=nind+1;
                str{nind}='timestep';
            end
            if orishp(2)=='1'
                nind=nind+1;
                str{nind}='istation';
            end
            if orishp(3)=='1'
                nind=nind+1;
                str{nind}='m';
            end
            if orishp(4)=='1'
                nind=nind+1;
                str{nind}='n';
            end
            if orishp(5)=='1'
                nind=nind+1;
                str{nind}='k';
            end
            sind='';
            for ii=1:nind
                sind=[sind str{ii} ','];
            end
            sind=sind(1:end-1);
            evalstr=['val=squeeze(parameter.(fld)(' sind '));'];
            eval(evalstr);
    end
end
