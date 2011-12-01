function handles = ddb_removeDDModelAttributes(handles, id)
%DDB_REMOVEDDMODELATTRIBUTES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_removeDDModelAttributes(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_removeDDModelAttributes
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
x=handles.Model(md).Input(id).gridX;

% Observation points
k=0;
iRemove=[];
if handles.Model(md).Input(id).nrObservationPoints>0
    % Check which points need to be removed
    for i=1:handles.Model(md).Input(id).nrObservationPoints
        m=handles.Model(md).Input(id).observationPoints(i).M;
        n=handles.Model(md).Input(id).observationPoints(i).N;
        if isnan(x(m,n))
            k=k+1;
            iRemove(k)=i;
        end
    end
    if ~isempty(iRemove)
        % And now remove them
        iRemove=sort(iRemove,'descend');
        for j=1:length(iRemove)
            i=iRemove(j);
            handles.Model(md).Input(id).observationPoints=removeFromStruc(handles.Model(md).Input(id).observationPoints,i);
            handles.Model(md).Input(id).observationPointNames=removeFromCellArray(handles.Model(md).Input(id).observationPointNames,i);
        end
        handles.Model(md).Input(id).nrObservationPoints=handles.Model(md).Input(id).nrObservationPoints-length(iRemove);
        handles.Model(md).Input(id).activeObservationPoint=1;
        if handles.Model(md).Input(id).nrObservationPoints==0
            handles.Model(md).Input(id).observationPointNames={''};
            handles.Model(md).Input(id).activeObservationPoint=1;
            handles.Model(md).Input(id).observationPoints(1).M=[];
            handles.Model(md).Input(id).observationPoints(1).N=[];
        end
    end
end

% Cross sections
k=0;
iRemove=[];
if handles.Model(md).Input(id).nrCrossSections>0
    % Check which points need to be removed
    for i=1:handles.Model(md).Input(id).nrCrossSections
        m1=handles.Model(md).Input(id).crossSections(i).M1;
        n1=handles.Model(md).Input(id).crossSections(i).N1;
        m2=handles.Model(md).Input(id).crossSections(i).M2;
        n2=handles.Model(md).Input(id).crossSections(i).N2;
        if isnan(x(m1,n1)) || isnan(x(m2,n2))
            k=k+1;
            iRemove(k)=i;
        end
    end
    if ~isempty(iRemove)
        % And now remove them
        iRemove=sort(iRemove,'descend');
        for j=1:length(iRemove)
            i=iRemove(j);
            handles.Model(md).Input(id).crossSections=removeFromStruc(handles.Model(md).Input(id).crossSections,i);
            handles.Model(md).Input(id).crossSectionNames=removeFromCellArray(handles.Model(md).Input(id).crossSectionNames,i);
        end
        handles.Model(md).Input(id).nrCrossSections=handles.Model(md).Input(id).nrCrossSections-length(iRemove);
        handles.Model(md).Input(id).activeCrossSection=1;
        if handles.Model(md).Input(id).nrCrossSections==0
            handles.Model(md).Input(id).crossSectionNames={''};
            handles.Model(md).Input(id).crossSections(1).M1=[];
            handles.Model(md).Input(id).crossSections(1).M2=[];
            handles.Model(md).Input(id).crossSections(1).N1=[];
            handles.Model(md).Input(id).crossSections(1).N2=[];
            handles.Model(md).Input(id).crossSections(1).name='';
        end
    end
end

%% TODO
% drogues and open boundaries

% Dry points
k=0;
iRemove=[];
if handles.Model(md).Input(id).nrDryPoints>0
    % Check which points need to be removed
    for i=1:handles.Model(md).Input(id).nrDryPoints
        m1=handles.Model(md).Input(id).dryPoints(i).M1;
        n1=handles.Model(md).Input(id).dryPoints(i).N1;
        m2=handles.Model(md).Input(id).dryPoints(i).M2;
        n2=handles.Model(md).Input(id).dryPoints(i).N2;
        if isnan(x(m1,n1)) || isnan(x(m2,n2))
            k=k+1;
            iRemove(k)=i;
        end
    end
    if ~isempty(iRemove)
        % And now remove them
        iRemove=sort(iRemove,'descend');
        for j=1:length(iRemove)
            i=iRemove(j);
            handles.Model(md).Input(id).dryPoints=removeFromStruc(handles.Model(md).Input(id).dryPoints,i);
            handles.Model(md).Input(id).dryPointNames=removeFromCellArray(handles.Model(md).Input(id).dryPointNames,i);
        end
        handles.Model(md).Input(id).nrDryPoints=handles.Model(md).Input(id).nrDryPoints-length(iRemove);
        handles.Model(md).Input(id).activeDryPoint=1;
        if handles.Model(md).Input(id).nrDryPoints==0
            handles.Model(md).Input(id).dryPointNames={''};
            handles.Model(md).Input(id).dryPoints(1).M1=[];
            handles.Model(md).Input(id).dryPoints(1).M2=[];
            handles.Model(md).Input(id).dryPoints(1).N1=[];
            handles.Model(md).Input(id).dryPoints(1).N2=[];
        end
    end
end

% Thin dams
k=0;
iRemove=[];
if handles.Model(md).Input(id).nrThinDams>0
    % Check which points need to be removed
    for i=1:handles.Model(md).Input(id).nrThinDams
        m1=handles.Model(md).Input(id).thinDams(i).M1;
        n1=handles.Model(md).Input(id).thinDams(i).N1;
        m2=handles.Model(md).Input(id).thinDams(i).M2;
        n2=handles.Model(md).Input(id).thinDams(i).N2;
        if isnan(x(m1,n1)) || isnan(x(m2,n2))
            k=k+1;
            iRemove(k)=i;
        end
    end
    if ~isempty(iRemove)
        % And now remove them
        iRemove=sort(iRemove,'descend');
        for j=1:length(iRemove)
            i=iRemove(j);
            handles.Model(md).Input(id).thinDams=removeFromStruc(handles.Model(md).Input(id).thinDams,i);
            handles.Model(md).Input(id).thinDamNames=removeFromCellArray(handles.Model(md).Input(id).thinDamNames,i);
        end
        handles.Model(md).Input(id).nrThinDams=handles.Model(md).Input(id).nrThinDams-length(iRemove);
        handles.Model(md).Input(id).activeThinDam=1;
        if handles.Model(md).Input(id).nrThinDams==0
            handles.Model(md).Input(id).thinDamNames={''};
            handles.Model(md).Input(id).thinDams(1).M1=[];
            handles.Model(md).Input(id).thinDams(1).M2=[];
            handles.Model(md).Input(id).thinDams(1).N1=[];
            handles.Model(md).Input(id).thinDams(1).N2=[];
            handles.Model(md).Input(id).thinDams(1).UV=[];
        end
    end
end

% Discharges
k=0;
iRemove=[];
if handles.Model(md).Input(id).nrDischarges>0
    % Check which points need to be removed
    for i=1:handles.Model(md).Input(id).nrDischarges
        m=handles.Model(md).Input(id).discharges(i).M;
        n=handles.Model(md).Input(id).discharges(i).N;
        if isnan(x(m,n))
            k=k+1;
            iRemove(k)=i;
        end
    end
    if ~isempty(iRemove)
        % And now remove them
        iRemove=sort(iRemove,'descend');
        for j=1:length(iRemove)
            i=iRemove(j);
            handles.Model(md).Input(id).discharges=removeFromStruc(handles.Model(md).Input(id).discharges,i);
            handles.Model(md).Input(id).dischargeNames=removeFromCellArray(handles.Model(md).Input(id).dischargeNames,i);
        end
        handles.Model(md).Input(id).nrDischarges=handles.Model(md).Input(id).nrDischarges-length(iRemove);
        handles.Model(md).Input(id).activeDischarge=1;
        if handles.Model(md).Input(id).nrDischarges==0
            handles.Model(md).Input(id).dischargeNames={''};
            handles.Model(md).Input(id).discharges(1).M=[];
            handles.Model(md).Input(id).discharges(1).N=[];
            handles.Model(md).Input(id).discharges(1).type='normal';
        end
    end
end

