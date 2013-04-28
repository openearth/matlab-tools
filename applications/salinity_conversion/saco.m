function saco

% SACO set of functions for salinity density chlorinity conversions

%
% set additional paths
%

if ~isdeployed
   oetsettings ('quiet','searchdb',false);
   addpath(genpath('saco_ui'));
   addpath(genpath('general'));
end

%
% Check if nesthd_path is set
%

if isempty (getenv('saco_pat'))
   h = warndlg({'Please set the environment variable "saco"';'See the installation chapter in the manual'},'SACO Warning');
   PutInCentre (h);
   uiwait(h);
end

%
% run
%

saco_ui;
