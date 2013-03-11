function handles = ddb_readMorFile(handles, id)
%DDB_READMORFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readMorFile(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_readMorFile
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

%% Reads Delft3D mor file into structure

if ~exist(handles.Model(md).Input(id).morFile,'file')
    ddb_giveWarning('text',['Mor file ' handles.Model(md).Input(id).morFile ' does not exist!']);
    return
end

s=ddb_readDelft3D_keyWordFile(handles.Model(md).Input(id).morFile);

handles=ddb_Delft3DFLOW_initializeMorphology(handles,id);

if isfield(s.morphology,'epspar')
    handles.Model(md).Input(id).morphology.epsPar=s.morphology.epspar;
end
if isfield(s.morphology,'iopkcw')
    handles.Model(md).Input(id).morphology.iOpKcw=s.morphology.iopkcw;
end
if isfield(s.morphology,'rdc')
    handles.Model(md).Input(id).morphology.rdc=s.morphology.rdc;
end
if isfield(s.morphology,'rdw')
    handles.Model(md).Input(id).morphology.rdw=s.morphology.rdw;
end
if isfield(s.morphology,'morfac')
    handles.Model(md).Input(id).morphology.morFac=s.morphology.morfac;
end
if isfield(s.morphology,'morstt')
    handles.Model(md).Input(id).morphology.morStt=s.morphology.morstt;
end
if isfield(s.morphology,'thresh')
    handles.Model(md).Input(id).morphology.thresh=s.morphology.thresh;
end
if isfield(s.morphology,'morupd')
    handles.Model(md).Input(id).morphology.morUpd=s.morphology.morupd;
end
if isfield(s.morphology,'eqmbc')
    handles.Model(md).Input(id).morphology.eqmBc=s.morphology.eqmbc;
end
if isfield(s.morphology,'densin')
    handles.Model(md).Input(id).morphology.densIn=s.morphology.densin;
end
if isfield(s.morphology,'aksfac')
    handles.Model(md).Input(id).morphology.aksFac=s.morphology.aksfac;
end
if isfield(s.morphology,'rwave')
    handles.Model(md).Input(id).morphology.rWave=s.morphology.rwave;
end
if isfield(s.morphology,'alfabs')
    handles.Model(md).Input(id).morphology.alphaBs=s.morphology.alfabs;
end
if isfield(s.morphology,'alfabn')
    handles.Model(md).Input(id).morphology.alphaBn=s.morphology.alfabn;
end
if isfield(s.morphology,'sus')
    handles.Model(md).Input(id).morphology.sus=s.morphology.sus;
end
if isfield(s.morphology,'bed')
    handles.Model(md).Input(id).morphology.bed=s.morphology.bed;
end
if isfield(s.morphology,'susw')
    handles.Model(md).Input(id).morphology.susW=s.morphology.susw;
end
if isfield(s.morphology,'bedw')
    handles.Model(md).Input(id).morphology.bedW=s.morphology.bedw;
end
if isfield(s.morphology,'sedthr')
    handles.Model(md).Input(id).morphology.sedThr=s.morphology.sedthr;
end
if isfield(s.morphology,'thetsd')
    handles.Model(md).Input(id).morphology.thetSd=s.morphology.thetsd;
end
if isfield(s.morphology,'hmaxth')
    handles.Model(md).Input(id).morphology.hMaxTh=s.morphology.hmaxth;
end
if isfield(s.morphology,'fwfac')
    handles.Model(md).Input(id).morphology.fwFac=s.morphology.fwfac;
end

