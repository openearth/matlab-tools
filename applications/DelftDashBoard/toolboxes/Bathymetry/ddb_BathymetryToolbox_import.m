function ddb_BathymetryToolbox_import(varargin)
%DDB_BATHYMETRYTOOLBOX_EXPORT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_BathymetryToolbox_export(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_BathymetryToolbox_export
%
%   See also

% This addition to the DeltDashBoard GUI was designed by David Sitton
%
% This tool is integrated into a function that is 
% part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.

% THE NEXT SECTION OF COMMENTS MAY BE NONSENSE FOR NOW:

% Created: Jan 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_BathymetryToolbox_Import.m 30 2011-12-07 16:07:05Z Sitton, David
% $Author: Sitton, David

%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
%     selectDataset;
    setUIElements('bathymetrypanel.import');
    ddb_plotBathymetry('activate');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'getbathyfile'}
            getbathyfile;
        case{'editoutputname'}
            editoutputname
                
        case{'import'}
            importData;
    end
end

return

function getbathyfile

global handles

% get the bathymetry toolbox structure:
idx = find(strcmp({handles.Toolbox.name},'Bathymetry'));
% handles.Toolbox(idx)
% handles.Toolbox(idx).GUI
% handles.Toolbox(idx).GUI.elements
% handles.Toolbox(idx).GUI.elements.tabs
% handles.Toolbox(idx).GUI.elements.tabs.tabname

% get the import bathymetry tab structure:
tb_idx = (strcmp({handles.Toolbox(idx).GUI.elements.tabs.tabname},'import'));
% handles.Toolbox(idx).GUI.elements.tabs.tabname(tb_idx)
% handles.Toolbox(idx).GUI.elements.tabs(tb_idx)
% handles.Toolbox(idx).GUI.elements.tabs(tb_idx).elements
% handles.Toolbox(idx).GUI.elements.tabs(tb_idx).elements.tag
% handles.Toolbox(idx).GUI.elements.tabs(tb_idx).elements(3)
% handles.Toolbox(idx).Input

obj_idx = find(strcmp({handles.Toolbox(idx).GUI.elements.tabs(tb_idx).elements.tag},'bathymetrypanel.import.editoutputname'));

% TAGS:
% % % bathymetrypanel.import.getbathyfile
% % % bathymetrypanel.import.import
% % % bathymetrypanel.import.editoutputname
% % % bathymetrypanel.import.selectpositivedirection

% get the bathymetry file (just selected by user):
file = handles.Toolbox(idx).Input.bathyFile;

if ispc
    output_name = regexprep(file,'^.*\\','');
else
    output_name = regexprep(file,'^.*/','');
end

output_name = regexprep(output_name,'\.[^\.]*$','');

obj_hndl = findobj('Tag','bathymetrypanel.import.editoutputname');

handles.Toolbox(tb).Input.newbathyName = output_name;
if ishandle(obj_hndl)
    set(obj_hndl,'String',output_name)
end
return

% find the object where we will put the name:

function editoutputname

global handles

% get the bathymetry toolbox structure:
idx = find(strcmp({handles.Toolbox.name},'Bathymetry'));


% get the import bathymetry tab structure:
tb_idx = (strcmp({handles.Toolbox(idx).GUI.elements.tabs.tabname},'import'));

obj_idx = find(strcmp({handles.Toolbox(idx).GUI.elements.tabs(tb_idx).elements.tag},'bathymetrypanel.import.editoutputname'));


% get the bathymetry file (just selected by user):
file = handles.Toolbox(idx).Input.bathyFile;


fprintf(1,'%s\n',handles.Toolbox(tb).Input.newbathyName)
% if ishandle(obj_hndl)
%     set(obj_hndl,'String',output_name)
% end



return

function importData

global handles

% get the bathymetry toolbox structure:
idx = find(strcmp({handles.Toolbox.name},'Bathymetry'));


% get the import bathymetry tab structure:
tb_idx = find(strcmp({handles.Toolbox(idx).GUI.elements.tabs.tabname},'import'));

obj_idx = find(strcmp({handles.Toolbox(idx).GUI.elements.tabs(tb_idx).elements.tag},'bathymetrypanel.import.editoutputname'));


% get the bathymetry file (just selected by user):
file = handles.Toolbox(idx).Input.bathyFile;

bathy_dir = handles.bathyDir;

output_name = regexprep(handles.Toolbox(tb).Input.newbathyName,' ','_');
output_dir = [bathy_dir,output_name,filesep];



out_file = [output_dir,output_name];

fprintf(1,'trying to import grid data from ADCIRC\n');
convert_adcirc2D3Dgrid(file,out_file);

% update initialization file

% update GUI ::

%bathymetrydataset

k=handles.bathymetry.nrDatasets+1;

handles.bathymetry.nrDatasets=k;
handles.bathymetry.datasets{k}=handles.Toolbox(tb).Input.newbathyName;
handles.bathymetry.dataset(k).longName=handles.Toolbox(tb).Input.newbathyName;
handles.bathymetry.dataset(k).type='tiles';
handles.bathymetry.dataset(k).edit=0;
%type
handles.bathymetry.dataset(k).type='netCDFtiles';
% name
handles.bathymetry.dataset(k).name=output_name;
% url
if output_dir(end) == filesep
    handles.bathymetry.dataset(k).URL=output_dir(1:end-1);
else
    handles.bathymetry.dataset(k).URL=output_dir;
end
% usecache
handles.bathymetry.dataset(k).useCache=0;


% update tiledbathymetry.def file (for future use in GUI)
fid = fopen([handles.bathyDir,'tiledbathymetries.def'],'at+');

fprintf(fid,'\n\n');

fprintf(fid,'BathymetryDataset "%s"\n\n',handles.bathymetry.datasets{k})

fprintf(fid,'\tType "netCDFtiles"\n');
fprintf(fid,'\tName "%s"\n',output_name);
fprintf(fid,'\tURL "%s"\n',handles.bathymetry.dataset(k).URL);
fprintf(fid,'\tuseCache no\n\n');

fprintf(fid,'EndBathymetryDataset\n');

fclose(fid);

% finish updating the data in the GUI:
% netcdftiles
            
            
% Local
fname=[handles.bathymetry.dataset(k).URL filesep handles.bathymetry.dataset(k).name '.nc'];
if exist(fname,'file')
    % File already exists, continue
    handles.bathymetry.dataset(k).isAvailable = 1;
else
    % File does not exist, this should produce a
    % warning
    disp(['Bathymetry dataset ' handles.bathymetry.dataset(k).longName ' not available!']);
    handles.bathymetry.dataset(k).isAvailable=0;
end
            
if handles.bathymetry.dataset(k).isAvailable
    
    x0=nc_varget(fname,'x0');
    y0=nc_varget(fname,'y0');
    nx=nc_varget(fname,'nx');
    ny=nc_varget(fname,'ny');
    ntilesx=nc_varget(fname,'ntilesx');
    ntilesy=nc_varget(fname,'ntilesy');
    dx=nc_varget(fname,'grid_size_x');
    dy=nc_varget(fname,'grid_size_y');
    for nn=1:length(x0)
        iav{nn}=nc_varget(fname,['iavailable' num2str(nn)]);
        jav{nn}=nc_varget(fname,['javailable' num2str(nn)]);
    end
    
    handles.bathymetry.dataset(k).horizontalCoordinateSystem.name=nc_attget(fname,'crs','coord_ref_sys_name');
    tp=nc_attget(fname,'crs','coord_ref_sys_kind');
    switch lower(tp)
        case{'projected','proj','projection','xy','cartesian','cart'}
            handles.bathymetry.dataset(k).horizontalCoordinateSystem.type='Cartesian';
        case{'geographic','geographic 2d','geographic 3d','latlon','spherical'}
            handles.bathymetry.dataset(k).horizontalCoordinateSystem.type='Geographic';
    end
    
    try
        handles.bathymetry.dataset(k).verticalCoordinateSystem.name=nc_attget(fname,'crs','vertical_reference_level');
    catch
        handles.bathymetry.dataset(k).verticalCoordinateSystem.name='unknown';
    end
    
    try
        handles.bathymetry.dataset(k).verticalCoordinateSystem.level=nc_attget(fname,'crs','difference_with_msl');
    catch
        handles.bathymetry.dataset(k).verticalCoordinateSystem.level=0;
    end
    
    handles.bathymetry.dataset(k).refinementFactor=round(dx(2)/dx(1));
    
    handles.bathymetry.dataset(k).nrZoomLevels=length(x0);
    for nn=1:handles.bathymetry.dataset(k).nrZoomLevels
        handles.bathymetry.dataset(k).zoomLevel(nn).x0=double(x0(nn));
        handles.bathymetry.dataset(k).zoomLevel(nn).y0=double(y0(nn));
        handles.bathymetry.dataset(k).zoomLevel(nn).nx=double(nx(nn));
        handles.bathymetry.dataset(k).zoomLevel(nn).ny=double(ny(nn));
        handles.bathymetry.dataset(k).zoomLevel(nn).ntilesx=double(ntilesx(nn));
        handles.bathymetry.dataset(k).zoomLevel(nn).ntilesy=double(ntilesy(nn));
        handles.bathymetry.dataset(k).zoomLevel(nn).dx=double(dx(nn));
        handles.bathymetry.dataset(k).zoomLevel(nn).dy=double(dy(nn));
        handles.bathymetry.dataset(k).zoomLevel(nn).iAvailable=double(iav{nn});
        handles.bathymetry.dataset(k).zoomLevel(nn).jAvailable=double(jav{nn});
    end
    
    handles.bathymetry.dataset(k).refinementFactor=round(double(dx(2))/double(dx(1)));
    
end


% place the new data set in the menu:
bathy_hndl = handles.GUIHandles.Menu.Bathymetry.Main;
new_field = regexprep(handles.Toolbox(tb).Input.newbathyName,'\s','');
handles.GUIHandles.Menu.Bathymetry.(new_field) = uimenu(bathy_hndl,...
    'Label',handles.Toolbox(tb).Input.newbathyName,...
    'Tag',['menuBathymetry',new_field],...
    'Callback',@ddb_menuBathymetry);




% change to the new dataset:
ddb_menuBathymetry(handles.GUIHandles.Menu.Bathymetry.(new_field))

return


%
% function selectDataset
% handles=getHandles;
% handles.Toolbox(tb).Input.activeZoomLevel=1;
% % handles=setResolutionText(handles);
% handles.Toolbox(tb).Input.zoomLevelText=[];
% for i=1:length(handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).zoomLevel)
%     handles.Toolbox(tb).Input.zoomLevelText{i}=num2str(i);
% end
% setHandles(handles);
% setUIElements('bathymetrypanel.import');
% 
% % function selectZoomLevel
% handles=getHandles;
% % handles=setResolutionText(handles);
% setHandles(handles);
% setUIElements('bathymetrypanel.import');


%
% function handles=setResolutionText(handles)
% 
% cellSize=handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).zoomLevel(handles.Toolbox(tb).Input.activeZoomLevel).dx;
% %     cellSize=dms2degrees([dg mn sc]);
% if strcmpi(handles.bathymetry.dataset(handles.Toolbox(tb).Input.activeDataset).horizontalCoordinateSystem.type,'Geographic')
%     cellSize=cellSize*111111;
%     handles.Toolbox(tb).Input.resolutionText=['Cell Size : ~ ' num2str(cellSize,'%10.0f') ' m'];
% else
%     handles.Toolbox(tb).Input.resolutionText=['Cell Size : ' num2str(cellSize,'%10.0f') ' m'];
% end
