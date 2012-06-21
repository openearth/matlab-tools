function ddb_Delft3DFLOW_wind(varargin)
%DDB_DELFT3DFLOW_WIND  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_wind(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_wind
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    % setUIElements('delft3dflow.physicalparameters.physicalparameterspanel.wind');
else
    handles=getHandles;
    opt=varargin{1};
    switch lower(opt)
        case{'openwndfile'}
            handles=ddb_readWndFile(handles,ad);
            setHandles(handles);
            % setUIElement('delft3dflow.physicalparameters.physicalparameterspanel.wind.timeseriestable');
        case{'savewndfile'}
            ddb_saveWndFile(handles,ad);
        case{'changewinddrag'}
            %             nrp=handles.Model(md).Input(ad).nrWindStressBreakpoints;
            %             coef=handles.Model(md).Input(ad).windStressCoefficients;
            %             spds=handles.Model(md).Input(ad).windStressSpeeds;
            % %             if nrp==2
            % %                 handles.Model(md).Input(ad).windStress(1:4)=[coef(1) spds(1) coef(2) spds(2)];
            % %             else
            % %                 handles.Model(md).Input(ad).windStress=[coef(1) spds(1) coef(2) spds(2) coef(3) spds(3)];
            % %             end
            %             setHandles(handles);
            %             % setUIElement('delft3dflow.physicalparameters.physicalparameterspanel.wind.dragcoeftable');
        case{'changenrbreakpoints'}
            nrp=handles.Model(md).Input(ad).nrWindStressBreakpoints;
            if nrp==2
                handles.Model(md).Input(ad).windStressCoefficients=handles.Model(md).Input(ad).windStressCoefficients(1:2);
                handles.Model(md).Input(ad).windStressSpeeds=handles.Model(md).Input(ad).windStressSpeeds(1:2);
            else
                handles.Model(md).Input(ad).windStressCoefficients(3)=handles.Model(md).Input(ad).windStressCoefficients(2);
                handles.Model(md).Input(ad).windStressSpeeds(3)=handles.Model(md).Input(ad).windStressSpeeds(2);
            end
            setHandles(handles);
            % setUIElement('delft3dflow.physicalparameters.physicalparameterspanel.wind.dragcoeftable');
    end
end

