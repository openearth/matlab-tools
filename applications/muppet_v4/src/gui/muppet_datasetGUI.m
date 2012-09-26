function muppet_datasetGUI(varargin)

makewindow=0;
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'makewindow'}
                makewindow=1;
            case{'filename'}
                filename=varargin{ii+1};
            case{'filetype'}
                filetype=varargin{ii+1};
            case{'adddataset'}
                addDataset;
            case{'selectparameter'}
                selectParameter;
            case{'selectcomponent'}
                selectComponent;
            case{'selectxcoordinate'}
                selectXCoordinate;
            case{'editstation'}
                editStation(varargin{ii+1});
            case{'edittime'}
                editTime(varargin{ii+1});
            case{'editm'}
                editM(varargin{ii+1});
            case{'editn'}
                editN(varargin{ii+1});
            case{'editk'}
                editK(varargin{ii+1});
        end
    end
end

if makewindow
    makeGUI(filetype,filename)
end

%%
function makeGUI(filetype,filename)

handles=getHandles;

dataset=[];

% Do not make parameters structure yet
dataset=muppet_setDefaultDatasetProperties(dataset);

dataset.filetype=filetype;
dataset.filename=filename;
dataset.name='';

% Find file type
ift=muppet_findIndex(handles.filetype,'filetype','name',filetype);
options=handles.filetype(ift).filetype.option;
dataset.callback=str2func(handles.filetype(ift).filetype.callback);
dataset.filetypelongname=handles.filetype(ift).filetype.longname;

% Get info from file
dataset=feval(dataset.callback,'read',dataset);

% Set default GUI options
dataset=setDefaultGUIOptions(dataset);

height=0;
width=0;
% First determine width and height of gui
for ii=1:length(options)
    % Find corresponding gui element
    id=muppet_findIndex(handles.dataproperty,'dataproperty','name',options(ii).option.name);
    if ~isempty(id)
        % Include in gui
        height=height+handles.dataproperty(id).dataproperty.height+10;
        width=max(handles.dataproperty(id).dataproperty.width,width);
    end
end

width=width+40;
height=height+140;

width=max(width,350);

% And now build the elements
posy=height-10;
nelm=0;

for ii=1:length(options)
  % Find corresponding gui element
  id=muppet_findIndex(handles.dataproperty,'dataproperty','name',options(ii).option.name);
  if ~isempty(id)
    % Include in gui
    posy=posy-handles.dataproperty(id).dataproperty.height-10;
    if isfield(handles.dataproperty(id).dataproperty,'element')
      for jj=1:length(handles.dataproperty(id).dataproperty.element)
        nelm=nelm+1;
        el=handles.dataproperty(id).dataproperty.element(jj).element;
        pos=str2num(el.position);
        el.position=[pos(1)+20 posy+pos(2) pos(3) pos(4)];
        element(nelm).element=el;
      end
    end
  end
end

% Dataset name
nelm=nelm+1;
element(nelm).element.style='edit';
element(nelm).element.position=[60 60 width-80 20];
element(nelm).element.variable='name';
element(nelm).element.text='Name';
element(nelm).element.dependency.dependency.action='enable';
element(nelm).element.dependency.dependency.checkfor='all';
element(nelm).element.dependency.dependency.checks.check.variable='parameters(s.activeparameter).parameter.active';
element(nelm).element.dependency.dependency.checks.check.value='1';
element(nelm).element.dependency.dependency.checks.check.operator='eq';

% Cancel
nelm=nelm+1;
element(nelm).element.style='pushcancel';
element(nelm).element.position=[width-250 20 70 25];

% Add
nelm=nelm+1;
element(nelm).element.style='pushbutton';
element(nelm).element.position=[width-170 20 70 25];
element(nelm).element.text='Add';
element(nelm).element.callback='muppet_datasetGUI';
element(nelm).element.option1='adddataset';
element(nelm).element.dependency.dependency.action='enable';
element(nelm).element.dependency.dependency.checkfor='all';
element(nelm).element.dependency.dependency.check.check.variable='parameters(s.activeparameter).parameter.active';
element(nelm).element.dependency.dependency.check.check.value='1';
element(nelm).element.dependency.dependency.check.check.operator='eq';

% OK
nelm=nelm+1;
element(nelm).element.style='pushok';
element(nelm).element.position=[width-90 20 70 25];

xml.element=element;

xml=gui_fillXMLvalues(xml);

[dataset,ok]=gui_newWindow(dataset,'element',xml.element,'tag','uifigure','width',width,'height',height, ...
    'createcallback',@selectParameter,'title',dataset.filetypelongname,'modal',0);
% gui_newWindow(dataset,'element',xml.element,'tag','uifigure','width',width,'height',height, ...
%     'createcallback',@selectParameter,'title',dataset.filetypelongname,'modal',0);

%%
function selectParameter(varargin)

dataset=gui_getUserData;
ipar=dataset.activeparameter;

if isfield(dataset.parameters(ipar).parameter,'dimensions')
    if dataset.parameters(ipar).parameter.dimensions.nrt>0
        dataset.timelist=dataset.parameters(ipar).parameter.gui.timelist;
    else
        dataset.timelist={''};
    end
end

gui_setUserData(dataset);

updateDimensions;

refreshDatasetName;

%%
function selectComponent(varargin)

dataset=gui_getUserData;

% Find other parameters with same quantity
for ii=1:dataset.nrparameters
    if strcmpi(dataset.parameters(ii).parameter.quantity,dataset.parameters(dataset.activeparameter).parameter.quantity)
        dataset.parameters(ii).parameter.component=dataset.parameters(dataset.activeparameter).parameter.component;
    end
end

gui_setUserData(dataset);

refreshDatasetName;

%%
function selectXCoordinate(varargin)

dataset=gui_getUserData;

parameter=dataset.parameters(dataset.activeparameter).parameter;

dataset.parameters(dataset.activeparameter).parameter.gui.previousxcoordinate=parameter.xcoordinate;

% Find other parameters with same shape
for ii=1:dataset.nrparameters
    if dataset.parameters(ii).parameter.dimensions.nrt==parameter.dimensions.nrt && dataset.parameters(ii).parameter.dimensions.nrm==parameter.dimensions.nrm && ...
        dataset.parameters(ii).parameter.dimensions.nrn==parameter.dimensions.nrn && dataset.parameters(ii).parameter.dimensions.nrk==parameter.dimensions.nrk
      dataset.parameters(ii).parameter.xcoordinate=parameter.xcoordinate;
      dataset.parameters(ii).parameter.gui.previousxcoordinate=parameter.xcoordinate;
    end
end

gui_setUserData(dataset);

refreshDatasetName;

%%
function editStation(opt)

dataset=gui_getUserData;
ip=dataset.activeparameter;
parameter=dataset.parameters(ip).parameter;

switch opt
    case{'select'}
        parameter.station=parameter.dimensions.stations{parameter.gui.stationfromlist};
        parameter.gui.stationnumber=parameter.gui.stationfromlist;
        parameter.gui.previousstationnumber=parameter.gui.stationnumber;
    case{'selectall'}
        if parameter.gui.selectallstations
            parameter.gui.stationnumber=0;
            parameter.station='';
        else
            parameter.gui.stationnumber=parameter.gui.previousstationnumber;
            parameter.station=parameter.dimensions.stations{parameter.gui.stationnumber};
        end
end

% Find other parameters with same dimensions and set values the same
for ii=1:dataset.nrparameters
    if dataset.parameters(ii).parameter.dimensions.nrstations==parameter.dimensions.nrstations
        dataset.parameters(ii).parameter.station=parameter.station;
        dataset.parameters(ii).parameter.gui.stationnumber=parameter.gui.stationnumber;
        dataset.parameters(ii).parameter.gui.previousstationnumber=parameter.gui.previousstationnumber;
        dataset.parameters(ii).parameter.gui.selectallstations=parameter.gui.selectallstations;
    end
end

dataset.parameters(ip).parameter=parameter;

gui_setUserData(dataset);

refreshDatasetName;


%%
function editTime(opt)

dataset=gui_getUserData;
ip=dataset.activeparameter;
parameter=dataset.parameters(ip).parameter;

switch opt
    case{'edit'}        
        it=indexstring('read',parameter.gui.timesteptext);
        if it>parameter.dimensions.nrt || it<1 || isnan(it)
            parameter.gui.timesteptext=indexstring('write',parameter.timestep);
            it=parameter.timestep;
        end
        parameter.timestep=it;
        parameter.gui.previoustimestep=parameter.timestep;
        parameter.gui.timestepsfromlist=parameter.timestep;
    case{'select'}
        parameter.timestep=parameter.gui.timestepsfromlist;
        parameter.gui.previoustimestep=parameter.timestep;
        parameter.gui.timesteptext=indexstring('write',parameter.timestep);
    case{'selectall'}        
        if parameter.gui.selectalltimes
            parameter.timestep=0;
            parameter.gui.timesteptext=indexstring('write',parameter.gui.previoustimestep);
        else
            parameter.timestep=parameter.gui.previoustimestep;
            parameter.gui.timesteptext=indexstring('write',parameter.timestep);            
        end
    case{'showtimes'}
        if isempty(parameter.dimensions.times)
            times=feval(dataset.callback,'gettimes');
            parameter.dimensions.times=times;
            for it=1:length(times)
                parameter.gui.timelist{it}=datestr(times(it),0);
            end
            dataset.gui.timelist=parameter.gui.timelist;
        end
        % Find other parameters with same dimensions and set values the same
        for ii=1:dataset.nrparameters
            if dataset.parameters(ii).parameter.dimensions.nrt==parameter.dimensions.nrt
                dataset.parameters(ii).parameter.times=parameter.times;
                dataset.parameters(ii).parameter.gui.timelist=parameter.gui.timelist;
            end
        end        
end

% Find other parameters with same dimensions and set values the same
for ii=1:dataset.nrparameters
    if dataset.parameters(ii).parameter.dimensions.nrt==parameter.dimensions.nrt
        dataset.parameters(ii).parameter.timestep=parameter.timestep;
        dataset.parameters(ii).parameter.gui.previoustimestep=parameter.gui.previoustimestep;
        dataset.parameters(ii).parameter.gui.timestepsfromlist=parameter.gui.timestepsfromlist;
        dataset.parameters(ii).parameter.gui.selectalltimes=parameter.gui.selectalltimes;
        dataset.parameters(ii).parameter.gui.showtimes=parameter.gui.showtimes;
        dataset.parameters(ii).parameter.gui.timesteptext=parameter.gui.timesteptext;
    end
end

dataset.parameters(ip).parameter=parameter;

gui_setUserData(dataset);

updateDimensions;

refreshDatasetName;

%%
function editM(opt)

dataset=gui_getUserData;
ip=dataset.activeparameter;
parameter=dataset.parameters(ip).parameter;

switch opt
    case{'edit'}
        parameter.m=indexstring('read',parameter.gui.mtext);
        parameter.gui.previousm=parameter.m;
    case{'selectall'}        
        if parameter.gui.selectallm
            parameter.m=0;
            parameter.gui.mtext=indexstring('write',parameter.gui.previousm);
        else
            parameter.m=parameter.gui.previousm;
            parameter.gui.mtext=indexstring('write',parameter.m);
        end
end

% Find other parameters with same dimensions and set values the same
for ii=1:dataset.nrparameters
    if dataset.parameters(ii).parameter.dimensions.nrm==parameter.dimensions.nrm
        dataset.parameters(ii).parameter.m=parameter.m;
        dataset.parameters(ii).parameter.gui.previousm=parameter.gui.previousm;
        dataset.parameters(ii).parameter.gui.mtext=parameter.gui.mtext;
        dataset.parameters(ii).parameter.gui.selectallm=parameter.gui.selectallm;
    end
end

dataset.parameters(ip).parameter=parameter;

gui_setUserData(dataset);

updateDimensions;

refreshDatasetName;

%%
function editN(opt)

dataset=gui_getUserData;
ip=dataset.activeparameter;
parameter=dataset.parameters(ip).parameter;

switch opt
    case{'edit'}
        parameter.n=indexstring('read',parameter.gui.ntext);
        parameter.gui.previousn=parameter.n;
    case{'selectall'}        
        if parameter.gui.selectalln
            parameter.n=0;
            parameter.gui.ntext=indexstring('write',parameter.gui.previousn);
        else
            parameter.n=parameter.gui.previousn;
            parameter.gui.ntext=indexstring('write',parameter.n);
        end
end

% Find other parameters with same dimensions and set values the same
for ii=1:dataset.nrparameters
    if dataset.parameters(ii).parameter.dimensions.nrn==parameter.dimensions.nrn
        dataset.parameters(ii).parameter.n=parameter.n;
        dataset.parameters(ii).parameter.gui.previousn=parameter.gui.previousn;
        dataset.parameters(ii).parameter.gui.ntext=parameter.gui.ntext;
        dataset.parameters(ii).parameter.gui.selectalln=parameter.gui.selectalln;
    end
end

dataset.parameters(ip).parameter=parameter;

gui_setUserData(dataset);

updateDimensions;

refreshDatasetName;

%%
function editK(opt)

dataset=gui_getUserData;
ip=dataset.activeparameter;
parameter=dataset.parameters(ip).parameter;

switch opt
    case{'edit'}
        parameter.k=indexstring('read',parameter.gui.ktext);
        parameter.gui.previousk=parameter.k;
    case{'selectall'}        
        if parameter.gui.selectalln
            parameter.k=0;
            parameter.gui.ktext=indexstring('write',parameter.gui.previousk);
        else
            parameter.k=parameter.gui.previousk;
            parameter.gui.ktext=indexstring('write',parameter.k);
        end
end

% Find other parameters with same dimensions and set values the same
for ii=1:dataset.nrparameters
    if dataset.parameters(ii).parameter.dimensions.nrk==parameter.dimensions.nrk
        dataset.parameters(ii).parameter.k=parameter.k;
        dataset.parameters(ii).parameter.gui.previousk=parameter.gui.previousk;
        dataset.parameters(ii).parameter.gui.ktext=parameter.gui.ktext;
        dataset.parameters(ii).parameter.gui.selectallk=parameter.gui.selectallk;
    end
end

dataset.parameters(ip).parameter=parameter;

gui_setUserData(dataset);

updateDimensions;

refreshDatasetName;

%%
function updateDimensions

dataset=gui_getUserData;

shp=muppet_findDataShape(dataset.parameters(dataset.activeparameter).parameter);

switch lower(shp)
    case{'crossection1dm','crossection1dn','crossection2dm','crossection2dn'}
        dataset.parameters(dataset.activeparameter).parameter.xcoordinate='pathdistance';
        dataset.parameters(dataset.activeparameter).parameter.xcoordinate=dataset.parameters(dataset.activeparameter).parameter.gui.previousxcoordinate;
    otherwise
        dataset.parameters(dataset.activeparameter).parameter.xcoordinate=[];
end

gui_setUserData(dataset);

%%
function addDataset

handles=getHandles;
dataset=gui_getUserData;

ii=strmatch(lower(dataset.name),lower(handles.datasetnames),'exact');
if ~isempty(ii)
    % Dataset already exists
    muppet_giveWarning('text','A dataset with this name already exists!');
    return
end

% Copy fields from appropriate parameters structure back to dataset structure, do NOT copy
% gui fields and name, but do copy dimensions

fldnames=fieldnames(dataset.parameters(dataset.activeparameter).parameter);
for j=1:length(fldnames)
    switch lower(fldnames{j})
        case{'gui','name'}
        otherwise
            dataset.(fldnames{j})=dataset.parameters(dataset.activeparameter).parameter.(fldnames{j});
    end
end

if isfield(dataset.parameters(dataset.activeparameter).parameter,'dimensions')
    dataset.parameter=dataset.parameters(dataset.activeparameter).parameter.dimensions.parametername;
end

% Remove parameters structure
dataset=rmfield(dataset,'parameters');
dataset=rmfield(dataset,'timelist');

% Check dimensions
dims=[0 0 0 0];
if ~isempty(dataset.m)
    if dataset.m==0 || length(dataset.m)>1
        dims(1)=1;
    end
end
if ~isempty(dataset.n)
    if dataset.n==0 || length(dataset.n)>1
        dims(2)=1;
    end
end
if ~isempty(dataset.k)
    if dataset.k==0 || length(dataset.k)>1
        dims(3)=1;
    end
end
if ~isempty(dataset.timestep)
    if dataset.timestep==0 || length(dataset.timestep)>1
        dims(4)=1;
    end
end

ndims=sum(dims);

if ndims>2
    muppet_giveWarning('text',['It is not possible to import ' num2str(ndims) '-dimensional datasets !']);
    return
end

handles=muppet_addDataset(handles,dataset);

setHandles(handles);

%%
function refreshDatasetName

dataset=gui_getUserData;

if dataset.adjustname
    
    ipar=dataset.activeparameter;
    
    parameter=dataset.parameters(ipar).parameter;
    
    if parameter.active
        
        parstr=parameter.dimensions.parametername;
        compstr='';
        tstr='';
        statstr='';
        mstr='';
        nstr='';
        kstr='';
        runidstr='';
        
        switch parameter.dimensions.quantity
          case{'vector2d','vector3d'}
            if ~isempty(parameter.component)
              if ~strcmpi(parameter.component,'vector')
                switch parameter.component
                  case{'vector'}
                    str='vector';
                  case{'vectorsplitxy'}
                    str='vector (split x,y)';
                  case{'vectorsplitmn'}
                    str='vector (split m,n)';
                  case{'magnitude'}
                    str='magnitude';
                  case{'angleradians'}
                    str='angle (radians)';
                  case{'angledegrees'}
                    str='angle (degrees)';
                  case{'xcomponent'}
                    str='x component';
                  case{'ycomponent'}
                    str='y component';
                  case{'mcomponent'}
                    str='m component';
                  case{'ncomponent'}
                    str='n component';
                end                
                compstr=[ ' - ' str];
              end
            end
        end
        
        if parameter.dimensions.nrt>0
            if parameter.timestep>0
                if ~isempty(parameter.dimensions.times)
                    tstr=[' - ' datestr(parameter.dimensions.times(parameter.timestep),0)];
                end
            end
        end
        
        if ~isempty(parameter.station)
            statstr=[ ' - ' parameter.dimensions.stations{parameter.gui.stationnumber}];
        end
        
        if ~isempty(parameter.m)
            if parameter.m>0
                mstr=[' - M=' num2str(parameter.m)];
            end
        end
        
        if ~isempty(parameter.n)
            if parameter.n>0
                nstr=[' - N=' num2str(parameter.n)];
            end
        end
        
        if ~isempty(parameter.k)
            if parameter.k>0
                kstr=[' - K=' num2str(parameter.k)];
            end
        end
        
        if isfield(parameter,'runid')
            runidstr=[' - ' runid];
        end
        
        dataset.name=[parstr compstr statstr tstr mstr nstr kstr runidstr];
        
    else
        dataset.name='';
    end
    
    gui_setUserData(dataset);
    
end

%%
function v=indexstring(opt,varargin)

switch lower(opt)
    case{'read'}
        str=varargin{1};
        v=str2double(str);
    case{'write'}
        val=varargin{1};
        v=num2str(val);
end

%%
function dataset=setDefaultGUIOptions(dataset)

% Always at least one parameter
dataset.timelist={''};

if dataset.nrparameters==0
    dataset.nrparameters=1;
    dataset.parameters(1).parameter.active=1;
end

for ii=1:dataset.nrparameters
    
    parameter=dataset.parameters(ii).parameter;
        
    % Copy dataset fields to parameter fields, do NOT copy dimensions, as
    % these have been determined in reading of file
    fldnames=fieldnames(dataset);
    for j=1:length(fldnames)
        switch fldnames{j}
            case{'dimensions'}
            case{'parameters'} % Don't copy parameters, this creates an infinite loop that eats memory !!!
            otherwise
                parameter.(fldnames{j})=dataset.(fldnames{j});
        end
    end
    
    if isfield(parameter,'dimensions')
       
        parameter.gui.previousm=1;
        parameter.gui.mtext='';
        parameter.gui.mmaxtext='';
        parameter.gui.selectallm=0;
        parameter.gui.previousn=1;
        parameter.gui.ntext='';
        parameter.gui.nmaxtext='';
        parameter.gui.selectalln=0;
        parameter.gui.previousk=1;
        parameter.gui.ktext='';
        parameter.gui.kmaxtext='';
        parameter.gui.selectallk=0;
        parameter.gui.showtimes=0;
        parameter.gui.selectalltimes=0;
        parameter.gui.previoustimestep=1;
        parameter.gui.timesteptext='';
        parameter.gui.timestepsfromlist=1;
        parameter.gui.tmaxtext='';
        parameter.gui.timelist={''};
        parameter.gui.stationnumber=1;
        parameter.gui.previousstationnumber=1;
        parameter.gui.selectallstations=0;
        parameter.gui.stationsfromlist=1;       
        
        if parameter.dimensions.nrm>0 && parameter.dimensions.nrn>0
            parameter.m=0;
            parameter.gui.previousm=1;
            parameter.gui.mtext='1';
            parameter.gui.mmaxtext=num2str(parameter.dimensions.nrm);
            parameter.gui.selectallm=1;
            parameter.n=0;
            parameter.gui.previousn=1;
            parameter.gui.ntext='1';
            parameter.gui.nmaxtext=num2str(parameter.dimensions.nrn);
            parameter.gui.selectalln=1;
        end
        
        if parameter.dimensions.nrt>0
            parameter.gui.tmaxtext=num2str(parameter.dimensions.nrt);
            if ~isempty(parameter.dimensions.times)
                parameter.gui.showtimes=1;
            else
                parameter.gui.showtimes=0;
            end
            if parameter.dimensions.nrm==0 && parameter.dimensions.nrn==0
                % Time series
                parameter.timestep=0;
                parameter.gui.previoustimestep=1;
                parameter.gui.timesteptext='1';
                parameter.gui.selectalltimes=1;
            else
                % Map
                parameter.timestep=1;
                parameter.gui.previoustimestep=1;
                parameter.gui.timesteptext='1';
                parameter.gui.selectalltimes=0;
            end
            if parameter.dimensions.nrt>0
                if ~isempty(parameter.dimensions.times)
                    if dataset.parametertimesequal
                        % Make timelist just once
                        if isempty(dataset.timelist{1})
                            % Time list was not yet made
                            for it=1:length(parameter.dimensions.times)
                                parameter.gui.timelist{it}=datestr(parameter.dimensions.times(it),0);
                            end
                            dataset.timelist=parameter.gui.timelist;
                        else
                            % Time list has already been made
                            parameter.gui.timelist=dataset.timelist;
                        end
                    else
                        % Make timelist for each parameter once
                        for it=1:length(parameter.dimensions.times)
                            parameter.gui.timelist{it}=datestr(parameter.dimensions.times(it),0);
                        end
                        dataset.timelist=parameter.gui.timelist;
                    end
                end
            end
        end
        
        if parameter.dimensions.nrk>0
            parameter.k=1;
            parameter.gui.previousk=1;
            parameter.gui.ktext='1';
            parameter.gui.kmaxtext=num2str(parameter.dimensions.nrk);
            parameter.gui.selectallk=0;
        end
        
        if parameter.dimensions.nrstations>0
            parameter.gui.stationnumber=1;
            parameter.gui.previousstationnumber=1;
            parameter.gui.selectallstations=0;
            parameter.station=parameter.dimensions.stations{1};
            parameter.gui.stationfromlist=1;
        end
        
        if isfield(parameter.dimensions,'quantity')
            switch lower(parameter.dimensions.quantity)
                case{'vector2d','vector3d'}
                    parameter.component='vector';
                otherwise
                    parameter.component=[];
            end
        end
        
    end
    
    parameter.gui.previousxcoordinate='pathdistance';
    
    dataset.parameters(ii).parameter=parameter;

end

dataset.activeparameter=1;

