function ddb_BathymetryToolbox_merge(varargin)
%DDB_BATHYMETRYTOOLBOX_MERGE  Mergeg bathymetry data here
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

% .

% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    
    % setUIElements('bathymetrypanel.merge');
    ddb_plotBathymetry('activate');
else
    %Options selected
    if ischar(varargin{1})
        opt=lower(varargin{1});
    elseif ishandle(varargin{1})
        opt=lower(get(varargin{1},'Tag'));
        opt=regexprep(opt,'bathymetrypanel\.merge\.','');
    else
        opt = '';
    end
    switch opt
        case{'selectdatasettoadd'}
            selectdatasettoadd;
        case{'addbathytolist'}
            addbathytolist;
        case{'deletefromlist'}
            deletefromlist;
        case{'moveselection'}
            moveselection;
        case{'textresolution'}
            textresolution;
        case{'mergedata'}
            mergedata;
    end
end

%%
function selectdatasettoadd

%%
function addbathytolist

handles=getHandles;

val=handles.Toolbox(tb).Input.activeDataset;

if ~isempty(val)    
    selected_file = handles.bathymetry.datasets{val};
    if ~any(strcmp(selected_file,handles.Toolbox(tb).Input.add_list))
        nf = handles.Toolbox(tb).Input.num_merge+1;
        handles.Toolbox(tb).Input.num_merge = nf;
        handles.Toolbox(tb).Input.add_list{nf} = selected_file;
        handles.Toolbox(tb).Input.add_list_idx(nf) = val;
        handles.Toolbox(tb).Input.bathy_to_cut = nf;
        setHandles(handles);
    end
end

%%
function handles=deletefromlist

handles=getHandles;
val = handles.Toolbox(tb).Input.bathy_to_cut;
nf = handles.Toolbox(tb).Input.num_merge;

if nf>0
    
    keep_idx = true(1,nf);

    keep_idx(val)= false;
    
    handles.Toolbox(tb).Input.num_merge = nf-length(val);

    handles.Toolbox(tb).Input.add_list = handles.Toolbox(tb).Input.add_list(keep_idx);
    handles.Toolbox(tb).Input.add_list_idx = handles.Toolbox(tb).Input.add_list_idx(keep_idx);
    
    handles.Toolbox(tb).Input.bathy_to_cut=max(min(handles.Toolbox(tb).Input.num_merge,nf),1);

    setHandles(handles);
end
    
%%
function handles=moveselection

handles=getHandles;

val = handles.Toolbox(tb).Input.bathy_to_cut;
nf = handles.Toolbox(tb).Input.num_merge;

if nf>1

    if val>1        
        tmp_str = handles.Toolbox(tb).Input.add_list(val);
        old_str = handles.Toolbox(tb).Input.add_list(val-1);
        handles.Toolbox(tb).Input.add_list(val) = old_str;
        handles.Toolbox(tb).Input.add_list(val-1) = tmp_str;
        
        tmp_idx = handles.Toolbox(tb).Input.add_list_idx(val);
        old_idx = handles.Toolbox(tb).Input.add_list_idx(val-1);
        
        handles.Toolbox(tb).Input.add_list_idx(val) = old_idx;
        handles.Toolbox(tb).Input.add_list_idx(val-1) = tmp_idx;
        
        
        handles.Toolbox(tb).Input.bathy_to_cut = val-1;
        
        setHandles(handles);
    end
end

%%
function mergedata

handles=getHandles;

file_list_idx = handles.Toolbox(tb).Input.add_list_idx;
file_list = handles.Toolbox(tb).Input.add_list;

nf = handles.Toolbox(tb).Input.num_merge;

total_max_x = -inf;
total_min_x =  inf;
total_max_y = -inf;
total_min_y =  inf;
min_dx = inf;
min_dy = inf;
for c=nf:-1:1
    cur_idx = file_list_idx(c);
    disp(handles.bathymetry.dataset(cur_idx).URL);
    min_x = handles.bathymetry.dataset(cur_idx).zoomLevel(1).x0;
    min_y = handles.bathymetry.dataset(cur_idx).zoomLevel(1).y0;
    nx = handles.bathymetry.dataset(cur_idx).zoomLevel(1).nx;
    ny = handles.bathymetry.dataset(cur_idx).zoomLevel(1).ny;
    dx = handles.bathymetry.dataset(cur_idx).zoomLevel(1).dx;
    dy = handles.bathymetry.dataset(cur_idx).zoomLevel(1).dy;
    n_tiles_x = handles.bathymetry.dataset(cur_idx).zoomLevel(1).ntilesx;
    n_tiles_y = handles.bathymetry.dataset(cur_idx).zoomLevel(1).ntilesy;
    
    max_x = min_x + (nx*n_tiles_x - 1)*dx;
    max_y = min_y + (ny*n_tiles_y - 1)*dy;
    if min_dx > 0;
        min_dx = min(dx,min_dx);
    end
    if min_dy > 0;
        min_dy = min(dy,min_dy);
    end
    total_max_x = max(total_max_x,max_x);
    total_min_x = min(total_min_x,min_x);
    total_max_y = max(total_max_y,max_y);
    total_min_y = min(total_min_y,min_y);
    fprintf('X Range: (%.1f , %.1f)\nY Range: (%.1f , %.1f)\n',...
    min_x,max_x,min_y,max_y);
    
end

[bathy,out_msg] = merge_bathy_data(handles,file_list,...
    [min_y,max_y],[min_x,max_x],dy,dx);

fprintf('X Range: (%.1f , %.1f)\nY Range: (%.1f , %.1f)\n',...
    total_min_x,total_max_x,total_min_y,total_max_y);
fprintf('dx %.5f\tdy %.5f\n',min_dx,min_dy);

