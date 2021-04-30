function ddb_read_configuration_xml

% Read in delftdashboard xml file to determine which models,
% toolboxes etc. to include. Store data in handles.configuration

handles=getHandles;

xmldir=handles.xmlConfigDir;
xmlfile=handles.xml_config_file;

% Read xml file
xml=xml2struct([xmldir xmlfile],'structuretype','long');

% First check which models to include
handles.configuration.include_models={'all'};
if isfield(xml,'include_models')
    for j=1:length(xml.include_models.include_models.model)
        handles.configuration.include_models{j}=xml.include_models.include_models.model(j).model.value;
    end
end

% First check which toolboxes to include
handles.configuration.include_toolboxes={'all'};
if isfield(xml,'include_toolboxes')
    for j=1:length(xml.include_toolboxes.include_toolboxes.toolbox)
        handles.configuration.include_toolboxes{j}=xml.include_toolboxes.include_toolboxes.toolbox(j).toolbox.value;
    end
end

% First check which toolboxes to include
handles.configuration.include_bathymetry={'all'};
if isfield(xml,'include_bathymetry')
    for j=1:length(xml.include_bathymetry.include_bathymetry.bathymetry)
        handles.configuration.include_bathymetry{j}=xml.include_bathymetry.include_bathymetry.bathymetry(j).bathymetry.value;
    end
end

% Default coordinate system
handles.configuration.cs.name='WGS 84';
handles.configuration.cs.type='geographic';
if isfield(xml,'coordinate_system')
    handles.configuration.cs.name=xml.coordinate_system.coordinate_system.name.name.value;
    tp=xml.coordinate_system.coordinate_system.type.type.value;
    switch lower(tp(1:3))
        case{'pro','car'}
            handles.configuration.cs.type='cartesian';
        otherwise
            handles.configuration.cs.type='geographic';
    end
end

if isfield(xml,'xlim') && isfield(xml,'ylim')
    handles.configuration.xlim=str2num(xml.xlim.xlim.value);
    handles.configuration.ylim=str2num(xml.ylim.ylim.value);   
else
    handles.configuration.xlim=[];
    handles.configuration.ylim=[];
end


% Default bathymetry
handles.configuration.bathymetry='';
if isfield(xml,'bathymetry')
    handles.configuration.bathymetry=xml.bathymetry.bathymetry.value;
end

handles.configuration.include_tide_models=1;
if isfield(xml,'include_tide_models')
    if lower(xml.include_tide_models.include_tide_models.value(1))=='n'
        handles.configuration.include_tide_models=0;
    end
end

setHandles(handles);
