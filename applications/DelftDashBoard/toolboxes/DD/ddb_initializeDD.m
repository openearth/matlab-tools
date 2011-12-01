function handles = ddb_initializeDD(handles, varargin)
%DDB_INITIALIZEDD  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeDD(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeDD
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
ii=strmatch('DD',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).longName='Domain Decomposition';
            return
    end
end

handles.Toolbox(ii).Input.mRefinement=5;
handles.Toolbox(ii).Input.nRefinement=5;
handles.Toolbox(ii).Input.firstCornerPointM=NaN;
handles.Toolbox(ii).Input.firstCornerPointN=NaN;
handles.Toolbox(ii).Input.secondCornerPointM=NaN;
handles.Toolbox(ii).Input.secondCornerPointN=NaN;
handles.Toolbox(ii).Input.domains={''};
handles.Toolbox(ii).Input.newRunid='new';
handles.Toolbox(ii).Input.attributeName='new';
handles.Toolbox(ii).Input.DDBoundaries=[];
handles.Toolbox(ii).Input.cornerPointHandles=[];
handles.Toolbox(ii).Input.adjustBathymetry=1;
%handles.Toolbox(ii).Input.ddFile='test.ddb';

