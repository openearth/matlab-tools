function z = DurosPlusLimitStateFunction(varargin)
%DUROSPLUSLIMITSTATEFUNCTION  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = DurosPlusLimitStateFunction(varargin)
%
%   Input: For <keyword,value> pairs call DurosPlusLimitStateFunction() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   DurosPlusLimitStateFunction
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 24 Feb 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Settings
OPT = struct(...
    'h', [],...
    'Hm0', [], ...
    'Tp', [],...
    'D50', 225e-6,...
    'tstop', 5*3600, ...
    'MaxErosionPoint', -351, ...
    'ModelSetupDir', 'd:\ADIS_XB_testing\ModelSetup\ReferenceProfile',...
    'ModelRunDir', 'd:\ADIS_XB_testing\TestRuns');

OPT = setproperty(OPT, varargin{:});

%% Check whether run already exists

FolderName          = ['h' num2str(OPT.h) '_H' num2str(OPT.Hm0) '_Tp' num2str(OPT.Tp)];
ModelOutputDir      = fullfile(OPT.ModelRunDir, FolderName);

if ~isdir(ModelOutputDir)
    %% Setup & run LimitStateFunction
    [z ErosionVolume result] = x2z_DUROS(...
        'Resistance', OPT.MaxErosionPoint, ...
        'xInitial',[], ...
        'zInitial', [], ...
        'WL_t', OPT.h, ...
        'Hsig_t', OPT.Hm0, ...
        'TP_t', OPT.Tp, ...
        'D50', OPT.D50, ...
        'Duration', 0, ...
        'Accuracy', [], ...
        'zRef', min(zInitial) ...
        );
end

%% Dummy Limit State Function
% 
% MaxErosionPoint = OPT.MaxErosionPoint;
% 
% zsize       = nc_varsize(fullfile(ModelOutputDir,'xboutput.nc'),'zb');
% xi          = nc_varget(fullfile(ModelOutputDir,'xboutput.nc'), 'globalx');
% zi          = nc_varget(fullfile(ModelOutputDir,'xboutput.nc'), 'zb',[0 0 0], [1 -1 -1]);
% xe          = xi;
% ze          = nc_varget(fullfile(ModelOutputDir,'xboutput.nc'), 'zb',[zsize(1)-1 0 0], [1 -1 -1]);
% 
% [TargetVolume, ~, ~] = getVolume('x',xi,'z',zi,'x2',xe,'z2',ze,'LowerBoundary',OPT.h);
% ErosionResult = getAdditionalErosion(xi, zi, ... 
%     'TargetVolume', TargetVolume, ... 
%     'x0min', min(xi), ... 
%     'x0max', max(findCrossings(xi,zi,[min(xi),max(xi)],ones(1,2)*OPT.h)), ... 
%     'zmin',OPT.h);
% 
% if ~isempty(ErosionResult.VTVinfo.Xr)
%     ErosionPoint    = ErosionResult.VTVinfo.Xr;
% else
%     ErosionPoint    = min(findCrossings(xi,zi,[min(xi),max(xi)],ones(1,2)*OPT.h));
% end
% 
% z           = MaxErosionPoint - ErosionPoint;
display(['The current exact Z-value is ' num2str(z) '(h = ' num2str(OPT.h), ...
    ', Hm0 = ' num2str(OPT.Hm0) ', Tp = ' num2str(OPT.Tp) ')']) %DEBUG

[z ErosionVolume result] = x2z_DUROS(...
        'Resistance', 50, ...
        'xInitial',x, ...
        'zInitial', bed, ...
        'WL_t', 5.5, ...
        'Hsig_t', 6, ...
        'Tp_t',13, ...
        'D50', 225e-6, ...
        'Duration', 0, ...
        'Accuracy', 10, ...
        'zRef', min(bed) ...
        );