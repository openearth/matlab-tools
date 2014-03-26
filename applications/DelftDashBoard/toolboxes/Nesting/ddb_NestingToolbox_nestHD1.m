function ddb_NestingToolbox_nestHD1(varargin)
%DDB_NESTINGTOOLBOX_NESTHD1  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_NestingToolbox_nestHD1(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_NestingToolbox_nestHD1
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setInstructions({'','Click Make Observation Points in order to generate observation points in the overall grid', ...
                'The overall model domain must be selected!'});
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'nesthd1'}
            nestHD1;
        case{'selectcs'}
            selectCS;
    end
end

%%
function nestHD1

handles=getHandles;

switch handles.toolbox.nesting.detailmodeltype

    case{'delft3dflow'}
        
        if isempty(handles.toolbox.nesting.grdFile)
            ddb_giveWarning('text','Please first load grid file of nested model!');
            return
        end
        
        if isempty(handles.toolbox.nesting.encFile)
            ddb_giveWarning('text','Please first load enclosure file of nested model!');
            return
        end
        
        if isempty(handles.toolbox.nesting.bndFile)
            ddb_giveWarning('text','Please first load boundary file of nested model!');
            return
        end
        
        if isempty(handles.model.delft3dflow.domain(ad).gridX)
            ddb_giveWarning('text','Please first load or create model grid!');
            return
        end
        
        fid=fopen('nesthd1.inp','wt');
        fprintf(fid,'%s\n',handles.model.delft3dflow.domain(ad).grdFile);
        fprintf(fid,'%s\n',handles.model.delft3dflow.domain(ad).encFile);
        fprintf(fid,'%s\n',handles.toolbox.nesting.grdFile);
        fprintf(fid,'%s\n',handles.toolbox.nesting.encFile);
        fprintf(fid,'%s\n',handles.toolbox.nesting.bndFile);
        fprintf(fid,'%s\n',handles.toolbox.nesting.admFile);
        fprintf(fid,'%s\n','ddtemp.obs');
        fclose(fid);
        
        %system(['"' handles.toolbox.nesting.dataDir 'nesthd1" < nesthd1.inp']);
        % Should use the nesthd1 compiled for this system if that is
        % available
        if exist([handles.model.delft3dflow.exedir,'nesthd1.exe'],'file'),
            system(['"' handles.model.delft3dflow.exedir 'nesthd1" < nesthd1.inp']);
        else
            system(['"' handles.toolbox.nesting.dataDir 'nesthd1" < nesthd1.inp']);
        end
        
        [name,m,n] = textread('ddtemp.obs','%21c%f%f');
        
        k=handles.model.delft3dflow.domain(ad).nrObservationPoints;
        for i=1:length(m)
            % Check if observation point already exists
            nm=deblank(name(i,:));
            ii=strmatch(nm,handles.model.delft3dflow.domain(ad).observationPointNames,'exact');
            if isempty(ii)
                % Observation point does not yet exist
                k=k+1;
                handles.model.delft3dflow.domain(ad).observationPoints(k).name=nm;
                handles.model.delft3dflow.domain(ad).observationPoints(k).M=m(i);
                handles.model.delft3dflow.domain(ad).observationPoints(k).N=n(i);
                handles.model.delft3dflow.domain(ad).observationPoints(k).x=handles.model.delft3dflow.domain(ad).gridXZ(m(i),n(i));
                handles.model.delft3dflow.domain(ad).observationPoints(k).y=handles.model.delft3dflow.domain(ad).gridYZ(m(i),n(i));
                handles.model.delft3dflow.domain(ad).observationPointNames{k}=handles.model.delft3dflow.domain(ad).observationPoints(k).name;
            end
        end
        delete('nesthd1.inp');
        try
            delete('ddtemp.obs');
        end
        handles.model.delft3dflow.domain(ad).nrObservationPoints=length(handles.model.delft3dflow.domain(ad).observationPoints);
        
        handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints','domain',ad,'visible',1,'active',0);
        
        setHandles(handles);
        
    case{'dflowfm'}

        if isempty(handles.toolbox.nesting.extfile)
            ddb_giveWarning('text','Please first load external forcing file of nested model!');
            return
        end
        
        cs.name=handles.toolbox.nesting.detailmodelcsname;
        cs.type=handles.toolbox.nesting.detailmodelcstype;

        newpoints=ddb_nesthd1_dflowfm_in_delft3dflow('admfile',handles.toolbox.nesting.admFile,'extfile',handles.toolbox.nesting.extfile, ...
            'grdfile',handles.model.delft3dflow.domain(ad).grdFile,'encfile',handles.model.delft3dflow.domain(ad).encFile, ...
            'csoverall',handles.screenParameters.coordinateSystem,'csdetail',cs);        
        
        if ~isempty(newpoints)            
            k=handles.model.delft3dflow.domain(ad).nrObservationPoints;
            for ip=1:length(newpoints)
                % Check if observation point already exists
                nm=deblank(newpoints(ip).name);
                ii=strmatch(nm,handles.model.delft3dflow.domain(ad).observationPointNames,'exact');
                if isempty(ii)
                    % Observation point does not yet exist
                    k=k+1;
                    handles.model.delft3dflow.domain(ad).observationPoints(k).name=nm;
                    handles.model.delft3dflow.domain(ad).observationPoints(k).M=newpoints(ip).m;
                    handles.model.delft3dflow.domain(ad).observationPoints(k).N=newpoints(ip).n;
                    handles.model.delft3dflow.domain(ad).observationPoints(k).x=handles.model.delft3dflow.domain(ad).gridXZ(newpoints(ip).m,newpoints(ip).n);
                    handles.model.delft3dflow.domain(ad).observationPoints(k).y=handles.model.delft3dflow.domain(ad).gridYZ(newpoints(ip).m,newpoints(ip).n);
                    handles.model.delft3dflow.domain(ad).observationPointNames{k}=handles.model.delft3dflow.domain(ad).observationPoints(k).name;
                end
            end
            handles.model.delft3dflow.domain(ad).activeObservationPoint=1;
            handles.model.delft3dflow.domain(ad).nrObservationPoints=k;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints','domain',ad,'visible',1,'active',0);        
            setHandles(handles);
        end
        
end

%%
function selectCS

handles=getHandles;

% Open GUI to select data set

[cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default','WGS 84','type','both','defaulttype','geographic');

if ok
    handles.toolbox.nesting.detailmodelcsname=cs;
    handles.toolbox.nesting.detailmodelcstype=type;    
    setHandles(handles);
end

gui_updateActiveTab;

