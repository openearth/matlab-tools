function nesthd(varargin)
% NESTHD  nesting of curvi-linear hydrodynamic models (Delft3D-Flow & Rijkswaterstaat SIMONA(WAQUA/TRIWAQ)
%
% nesthd() launches GUI
% nesthd(keyword) runs in batch mode
%
% Help is available as Windows help file: NestHD.chm
%
% Unlike the Delft3D fortran nesth programs, nest_matlab has
% support for Neumann boundaries, Riemann boundaries, and
% tangential velocity components (parallel to open boundary),
%
%See also: delft3d

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 www.Deltares.nl
%       Theo van der Kaaij
%
%       theo.vanderkaaij@deltares.nl
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% set additional paths
%  is already taken care of by oetsettings: then setproperty is on path (most important OET function)

if ~isdeployed && any(which('setproperty'))
   addpath(genpath('..\..\..\..\matlab'));
end

%% Check if nesthd_path is set

if isempty (getenv('nesthd_path'))
   h = warndlg({'Please set the environment variable "nesthd_path"';'See the Release Notes ("Release Notes.chm")'},'NestHD Warning');
   PutInCentre (h);
   uiwait(h);
end

%% Display a warning, administration file has changed
Gen_inf    = {'Nesthd Version 2.0:'                                                                                 ;
              ' '                                                                                                  ;
              'In addition to nesting Delft3D-Flow models and SIMONA models,'                                      ;
              'This version also support nesting of DFLOWFM models'                                                ;
              'To allow for nesting of DFLOWFM models the administration file'                                     ;
              'had to be adjusted (string based in stead of (M,N) based)'                                          ;
              'This means that old, version 1, adminstration files do not work anymore'                            ;
              ' '                                                                                                  ;
              'Hence, old adminstration files will have to be re-generated'                                        ;
              ' '                                                                                                  ;
              'If you encounter problems, please do not hesitate to contact me'                                    ;  
              'Theo.vanderkaaij@deltares.nl'                                                                      };

simona2mdf_message(Gen_inf,'n_sec',10,'Window','NESTHD Message','Close',true);

%% Initialize

handles  = [];

%% run

if ~isempty(varargin)

    % Batch

    [handles] = nesthd_ini_ui(handles);
    [handles] = nesthd_read_ini(handles,varargin{1});
    OPT.check = false;
    if length(varargin)>= 2
        OPT = setproperty(OPT,varargin(2:end));
    end
    nesthd_run_now(handles,'check',OPT.check);
else

    % Stand alone
    nesthd_nest_ui;
end
