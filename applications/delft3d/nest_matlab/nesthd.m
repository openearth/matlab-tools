function nesthd(varargin)
% NESTHD  nesting of hydrodynamic models (Delft3D-Flow and WAQUA/TRIWAQ)

%
% set additional paths
%

if ~isdeployed
   oetsettings ('quiet','searchdb',false);
   addpath(genpath('../nest_ui'));
   addpath(genpath('../nesthd1'));
   addpath(genpath('../nesthd2'));
   addpath(genpath('../general'));
   addpath(genpath('../reawri'));
end

%
% Check if nesthd_path is set
%

if isempty (getenv('nesthd_path'))
   h = warndlg({'Please set the environment variable "nesthd_path"';'See the Release Notes in the documents directory'},'NestHD Warning');
   PutInCentre (h);
   uiwait(h);
end

%
% Initialize
%

handles  = [];

%
% run
%

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
