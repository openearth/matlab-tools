function nesthd(varargin)

% nesthd : nesting of hydrodynamic models (Delft3D-Flow and WAQUA/TRIWAQ)

if isempty (getenv('nesthd_pah'))
   h = warndlg({'Please set the environment variable "nesthd_path"';'See the Release Notes in the documents directory'},'NestHD Warning');
   PutInCentre (h);
   uiwait(h);
end

nesthd_add;
handles  = [];

if ~isempty(varargin)

    %
    % Batch
    %

    [handles] = nesthd_ini_ui(handles);
    [handles] = nesthd_read_ini(handles,varargin{1});
    nesthd_run_now(handles);
else
    %
    % Stand alone
    %
    nesthd_nest_ui;
end
