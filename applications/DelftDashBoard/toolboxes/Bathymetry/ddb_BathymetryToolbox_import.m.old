function ddb_BathymetryToolbox_import(varargin)
%DDB_BATHYMETRYTOOLBOX_IMPORT  IMPORT BATHY DATA INTO D3D Tiled format
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_BathymetryToolbox_import(varargin)
%
%   Input:
%   varargin = option1, option2
%
%
%
%   Example
%   ddb_BathymetryToolbox_import
%
%   See also ddb_BathymetryToolbox_export, ddb_BathymetryToolbox_merge

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
    % show the new bathy import panel
    
    % turn off the zoom button (if necessary)
    ddb_zoomOff;
    
    % refresh the Screen so that the new panel is showing
    ddb_refreshScreen;
%     selectDataset;

    % setUIElements('bathymetrypanel.import');
    ddb_plotBathymetry('activate');
else
    %Options selected
    % to get here, a user interface control was selected or modified
    % (uicontrol object)
    
    opt=lower(varargin{1});
    switch opt
        case{'getbathyfile'}
            % browse for bathy data
            getbathyfile(varargin{2});
        case{'editoutputname'}
            % modify the name of the new bathy data set
            % this value will be appear in the Bathymetry uimenu once
            % importing is complete
            editoutputname
        
        case{'editresolution'}
            % set the resolution of the data to import.
            setresolution
                
        case{'import'}
            % execute the actual importing of the data
            importData;
        case{'preppctidesbathy'}
            preppctidesbathy
    end
end

return

% browsse for a Bathy Data set
%
% Currently supports XYZ, ADCIRC, and NC data*
%
% NC data won't update the vertical datum type attribute!
function getbathyfile(selection_idx)

if nargin<1
    selection_idx=0;
end

if selection_idx
    % find the selection type
end

global handles

tmp = get(gcbo,'Callback');

exp_typ = regexprep(tmp{4}(1).fileExtension{selection_idx,1},'^.*\.','');

tb_name = lower(handles.Toolbox(tb).name);

% get the bathymetry toolbox structure:
idx = strcmpi({handles.Toolbox.name},tb_name);
% handles.Toolbox(idx)
% handles.Toolbox(idx).GUI
% handles.Toolbox(idx).GUI.elements
% handles.Toolbox(idx).GUI.elements.tabs
% handles.Toolbox(idx).GUI.elements.tabs.tabname

% get the import bathymetry tab structure:
% tb_idx = (strcmp({handles.Toolbox(idx).GUI.elements.tabs.tabname},'import'));

set(findobj('Tag',[tb_name,'panel.import.import']),'UserData',exp_typ);
% handles.Toolbox(idx).GUI.elements.tabs.tabname(tb_idx)
% handles.Toolbox(idx).GUI.elements.tabs(tb_idx)
% handles.Toolbox(idx).GUI.elements.tabs(tb_idx).elements
% handles.Toolbox(idx).GUI.elements.tabs(tb_idx).elements.tag
% handles.Toolbox(idx).GUI.elements.tabs(tb_idx).elements(3)
% handles.Toolbox(idx).Input

% obj_idx = find(strcmp({handles.Toolbox(idx).GUI.elements.tabs(tb_idx).elements.tag},'bathymetrypanel.import.editoutputname'));

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

obj_hndl_name = findobj('Tag',[tb_name,'panel.import.editoutputname']);
obj_hndl_res = findobj('Tag',[tb_name,'panel.import.setresolution']);

if isempty(obj_hndl_name)
    obj_hndl_name = findobj('Tag',[tb_name,'panel.import.editoutputname']);
    obj_hndl_res = findobj('Tag',[tb_name,'panel.import.setresolution']);
    
end

% reset the resolution to 3 seconds.
handles.Toolbox(tb).Input.newbathyName = output_name;
handles.Toolbox(tb).Input.newbathyresolution = 3;
if ishandle(obj_hndl_name)
    set(obj_hndl_name,'String',output_name)
    set(obj_hndl_res,'String',num2str(handles.Toolbox(tb).Input.newbathyresolution))
end


return

% find the object where we will put the name:

function editoutputname
% no action required here

% % global handles
% % 
% % % get the bathymetry toolbox structure:
% % idx = find(strcmp({handles.Toolbox.name},'Bathymetry'));
% % 
% % 
% % % get the import bathymetry tab structure:
% % tb_idx = (strcmp({handles.Toolbox(idx).GUI.elements.tabs.tabname},'import'));
% % 
% % obj_idx = find(strcmp({handles.Toolbox(idx).GUI.elements.tabs(tb_idx).elements.tag},'bathymetrypanel.import.editoutputname'));
% % 
% % 
% % % get the bathymetry file (just selected by user):
% % file = handles.Toolbox(idx).Input.bathyFile;
% % 
% % 
% % fprintf(1,'%s\n',handles.Toolbox(tb).Input.newbathyName)
% % % if ishandle(obj_hndl)
% % %     set(obj_hndl,'String',output_name)
% % % end

return

function setresolution
% no action required here

% % global handles

% % obj_hndl_res = findobj('Tag','bathymetrypanel.import.setresolution');

% handles.Toolbox(tb).Input.newbathyresolution;

% % 
% % % get the bathymetry toolbox structure:
% % idx = find(strcmp({handles.Toolbox.name},'Bathymetry'));
% % 
% % 
% % % get the import bathymetry tab structure:
% % tb_idx = (strcmp({handles.Toolbox(idx).GUI.elements.tabs.tabname},'import'));
% % 
% % obj_idx = find(strcmp({handles.Toolbox(idx).GUI.elements.tabs(tb_idx).elements.tag},'bathymetrypanel.import.setresolution'));
% % 
% % 
% % % get the bathymetry file (just selected by user):
% % file = handles.Toolbox(idx).Input.bathyFile;
% % 
% % 
% % fprintf(1,'%s\n',handles.Toolbox(tb).Input.newbathyName)
% % % if ishandle(obj_hndl)
% % %     set(obj_hndl,'String',output_name)
% % % end

return

%
% IMPORT THE DATA HERE:
%
function importData

global handles

% get the bathymetry toolbox structure:
% idx = find(strcmp({handles.Toolbox.name},'Bathymetry'));
idx = tb;

% get the offet from MSL and the datum type
msl_offset = handles.Toolbox(tb).Input.offset_value;
datum_type = handles.Toolbox(tb).Input.datum_type;

% get the extension of the data o be imported
ext_typ = get(gcbo,'UserData');

% get the import bathymetry tab structure:
tb_idx = strcmp({handles.Toolbox(idx).GUI.elements.tabs.tabname},'import');

obj_idx = find(strcmp({handles.Toolbox(idx).GUI.elements.tabs(tb_idx).elements.tag},'bathymetrypanel.import.editoutputname'));


% get the bathymetry file (just selected by user):
file = handles.Toolbox(idx).Input.bathyFile;

bathy_dir = handles.bathymetry.dir;


res_val = handles.Toolbox(tb).Input.newbathyresolution;

switch ext_typ
    case 'grd'
        % adcirc data selected:
        output_name = regexprep(handles.Toolbox(tb).Input.newbathyName,' ','_');
        output_dir = [bathy_dir,output_name,filesep];

        out_file = [output_dir,output_name];
        
        % import the adcict data
        fprintf(1,'trying to import grid data from ADCIRC\n');
        convert_adcirc2D3Dgrid(file,out_file,res_val,datum_type,msl_offset);
        
    case 'nc'
        % get the name of the NC tiles (already in the right format)
        if ispc
            output_dir = regexprep(file,'[^\\]*$','');
            output_name = regexprep(file,'^.*\\','');
        else
            output_dir = regexprep(file,'[^/]*$','');
            output_name = regexprep(file,'^.*/','');
        end
        output_name = regexprep(output_name,'\.nc','');
        
        disp('Adding bathy NC files to GUI')
    case 'xyz'
        % though I have software to do this, I haven't put it into function
        % form and imported it into the GUI yet. I have misplaced the one
        % xyz file I have for testing this. When I find it, I will
        % implement this here.
        return
    otherwise
        msgbox('Unknown Data format. You must edit %s subroutine "importData" to handle this format.')
        return
end

% update initialization file

% update GUI ::

%bathymetrydataset

% update the GUI

% add a dataset to the Bathyemetry options:
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

% update the tile definition file so that the GUI will remember this data
% next time:

% update tiledbathymetry.def file (for future use in GUI)
fid = fopen([handles.bathymetry.dir,'tiledbathymetries.def'],'at+');

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
            
            
% save the data in the GUI to let it find the new bathy data
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
    iav = cell(1,length(x0));
    jav = cell(1,length(x0));
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
    catch ME
        fprintf('Warning: %s\n',ME);
        handles.bathymetry.dataset(k).verticalCoordinateSystem.name='unknown';
    end
    
    try
        handles.bathymetry.dataset(k).verticalCoordinateSystem.level=nc_attget(fname,'crs','difference_with_msl');
    catch ME
        fprintf('Warning: %s\n',ME);
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




% change the display to have the new BATHY data as the selected source
ddb_menuBathymetry(handles.GUIHandles.Menu.Bathymetry.(new_field))

return



% Prepare PC Tides Bathy
function preppctidesbathy

txt = {};
nerror = 0;

handles = getHandles();
disp('  Prepping PCTides high-res. bathy....');
disp(['Mode is now: ' int2str(handles.Model(md).Input(ad).enablePCTides)]);
if (handles.Model(md).Input(ad).enablePCTides == 1)
    if (~isfield(handles.Toolbox(tb).Input, 'bathyFile') || isempty(handles.Toolbox(tb).Input.bathyFile))
        nerror = nerror + 1;
        txt{nerror} = 'Enter a PCTides high-res. bathy grid file name.';
    end
    if (~isfield(handles.Toolbox(tb).Input, 'gridHiResName') || isempty(handles.Toolbox(tb).Input.gridHiResName))
        nerror = nerror + 1;
        txt{nerror} = 'Enter a PCTides high-res. bathy grid name.';
    end
    if (~isfield(handles.Toolbox(tb).Input, 'gridHiResSouthLat') || isempty(handles.Toolbox(tb).Input.gridHiResSouthLat))
        nerror = nerror + 1;
        txt{nerror} = 'Enter a PCTides high-res. bathy grid southern latitude.';
    end
    if (~isfield(handles.Toolbox(tb).Input, 'gridHiResNorthLat') || isempty(handles.Toolbox(tb).Input.gridHiResNorthLat))
        nerror = nerror + 1;
        txt{nerror} = 'Enter a PCTides high-res. bathy grid northern latitude.';
    end
    if (~isfield(handles.Toolbox(tb).Input, 'gridHiResNY') || isempty(handles.Toolbox(tb).Input.gridHiResNY))
        nerror = nerror + 1;
        txt{nerror} = 'Enter a PCTides high-res. bathy grid number of latitude grid points.';
    end
    if (~isfield(handles.Toolbox(tb).Input, 'gridHiResWestLon') || isempty(handles.Toolbox(tb).Input.gridHiResWestLon))
        nerror = nerror + 1;
        txt{nerror} = 'Enter a PCTides high-res. bathy grid western longitude.';
    end
    if (~isfield(handles.Toolbox(tb).Input, 'gridHiResEastLon') || isempty(handles.Toolbox(tb).Input.gridHiResEastLon))
        nerror = nerror + 1;
        txt{nerror} = 'Enter a PCTides high-res. bathy grid eastern longitude.';
    end
    if (~isfield(handles.Toolbox(tb).Input, 'gridHiResNX') || isempty(handles.Toolbox(tb).Input.gridHiResNX))
        nerror = nerror + 1;
        txt{nerror} = 'Enter a PCTides high-res. bathy grid number of longitude grid points.';
    end
    if (nerror == 0)
        %  Create the prep file.
    else
        %txt = {'WARNING: One or more errors was found:'; txt};
        warndlg(txt,'BATHY IMPORT ERROR','modal');
    end
else
    ddb_giveWarning('Warning','Please select the PCTides checkbox in the Init Mode tab.');
end

return;
