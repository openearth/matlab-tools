function ddb_Delft3DFLOW_openBoundaries(varargin)
%DDB_DELFT3DFLOW_OPENBOUNDARIES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_openBoundaries(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_openBoundaries
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
handles=getHandles;

ddb_zoomOff;
ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;

if isempty(varargin)
    ddb_refreshScreen;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','openboundaries');
    setHandles(handles);
else
    opt=varargin{1};
    if length(varargin)>1
        opt2=varargin{2};
    end
    
    switch(lower(opt))
        
        case{'add'}
            handles.Model(md).Input(ad).selectOpenBoundary=0;
            handles.Model(md).Input(ad).changeOpenBoundary=0;
            handles.Model(md).Input(ad).deleteOpenBoundary=0;
            if handles.Model(md).Input(ad).addOpenBoundary
                handles.editMode='add';
                ddb_dragLine(@addOpenBoundary,'method','alonggridline','x',handles.Model(md).Input(ad).gridX,'y',handles.Model(md).Input(ad).gridY);
                setInstructions({'','','Drag line on map for new open boundary'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            
        case{'delete'}
            handles.Model(md).Input(ad).addOpenBoundary=0;
            handles.Model(md).Input(ad).selectOpenBoundary=0;
            handles.Model(md).Input(ad).changeOpenBoundary=0;
            ddb_clickObject('tag','openboundary','callback',@deleteOpenBoundaryFromMap);
            setInstructions({'','','Select open boundary from map to delete'});
            setHandles(handles);
            if handles.Model(md).Input(ad).deleteOpenBoundary
                % Delete open boundary selected from list
                deleteOpenBoundaries;
            end
            
        case{'select'}
            handles.Model(md).Input(ad).addOpenBoundary=0;
            handles.Model(md).Input(ad).deleteOpenBoundary=0;
            handles.Model(md).Input(ad).changeOpenBoundary=0;
            if handles.Model(md).Input(ad).selectOpenBoundary
                ddb_clickObject('tag','openboundary','callback',@selectOpenBoundaryFromMap);
                setInstructions({'','','Select open boundary from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            
        case{'change'}
            handles.Model(md).Input(ad).addOpenBoundary=0;
            handles.Model(md).Input(ad).selectOpenBoundary=0;
            handles.Model(md).Input(ad).deleteOpenBoundary=0;
            if handles.Model(md).Input(ad).changeOpenBoundary
                ddb_clickObject('tag','openboundary','callback',@changeOpenBoundaryFromMap);
                setInstructions({'','','Select open boundary to change from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
            
        case{'editindices'}
            handles.Model(md).Input(ad).addOpenBoundary=0;
            handles.Model(md).Input(ad).selectOpenBoundary=0;
            handles.Model(md).Input(ad).changeOpenBoundary=0;
            handles.Model(md).Input(ad).deleteOpenBoundary=0;
            handles.editMode='edit';
            n=handles.Model(md).Input(ad).activeOpenBoundary;
            xg=handles.Model(md).Input(ad).gridX;
            yg=handles.Model(md).Input(ad).gridY;
            zg=handles.Model(md).Input(ad).depthZ;
            kcs=handles.Model(md).Input(ad).kcs;
            [xb,yb,zb,alphau,alphav,side,orientation]=delft3dflow_getBoundaryCoordinates(handles.Model(md).Input(ad).openBoundaries(n),xg,yg,zg,kcs);
            handles.Model(md).Input(ad).openBoundaries(n).x=xb;
            handles.Model(md).Input(ad).openBoundaries(n).y=yb;
            handles.Model(md).Input(ad).openBoundaries(n).depth=zb;
            handles.Model(md).Input(ad).openBoundaries(n).side=side;
            handles.Model(md).Input(ad).openBoundaries(n).orientation=orientation;
            handles.Model(md).Input(ad).openBoundaries(n).alphau=alphau;
            handles.Model(md).Input(ad).openBoundaries(n).alphav=alphav;
            m1str=num2str(handles.Model(md).Input(ad).openBoundaries(n).M1);
            m2str=num2str(handles.Model(md).Input(ad).openBoundaries(n).M2);
            n1str=num2str(handles.Model(md).Input(ad).openBoundaries(n).N1);
            n2str=num2str(handles.Model(md).Input(ad).openBoundaries(n).N2);
            name=['('  m1str ',' n1str ')...(' m2str ',' n2str ')'];
            if strcmpi(handles.Model(md).Input(ad).openBoundaries(n).name(1),'(') && ...
                    strcmpi(handles.Model(md).Input(ad).openBoundaries(n).name(end),')')
                handles.Model(md).Input(ad).openBoundaries(n).name=name;
                handles.Model(md).Input(ad).openBoundaryNames{n}=name;
            end
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries');
            clearInstructions;
            setHandles(handles);
            refreshOpenBoundaries;
            
        case{'editname'}
            handles.Model(md).Input(ad).addOpenBoundary=0;
            handles.Model(md).Input(ad).selectOpenBoundary=0;
            handles.Model(md).Input(ad).changeOpenBoundary=0;
            handles.Model(md).Input(ad).deleteOpenBoundary=0;
            n=handles.Model(md).Input(ad).activeOpenBoundary;
            handles.Model(md).Input(ad).openBoundaryNames{n}=handles.Model(md).Input(ad).openBoundaries(n).name;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries');
            setHandles(handles);
            % setUIElement('delft3dflow.openboundaries.listopenboundaries');
            clearInstructions;
            refreshOpenBoundaries;
            
        case{'selectfromlist'}
            handles.Model(md).Input(ad).addOpenBoundary=0;
            handles.Model(md).Input(ad).selectOpenBoundary=0;
            handles.Model(md).Input(ad).changeOpenBoundary=0;
            % Delete selected open boundary next time delete is clicked
            handles.Model(md).Input(ad).deleteOpenBoundary=1;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','openboundaries');
            clearInstructions;
            setHandles(handles);
            refreshOpenBoundaries;
            
        case{'selecttype'}
            tp=handles.Model(md).Input(ad).openBoundaries(handles.Model(md).Input(ad).activeOpenBoundary).type;
            iac=handles.Model(md).Input(ad).activeOpenBoundaries;
            for ii=1:length(iac)
                n=iac(ii);
                handles.Model(md).Input(ad).openBoundaries(n).type=tp;
                if handles.Model(md).Input(ad).KMax>1
                    switch lower(handles.Model(md).Input(ad).openBoundaries(n).type)
                        case{'z','n'}
                            handles.Model(md).Input(ad).openBoundaries(n).profile='uniform';
                        case{'q','t'}
                            if strcmpi(handles.Model(md).Input(ad).openBoundaries(n).profile,'3d-profile')
                                handles.Model(md).Input(ad).openBoundaries(n).profile='uniform';
                            end
                        case{'r'}
                            if strcmpi(handles.Model(md).Input(ad).openBoundaries(n).profile,'logarithmic')
                                handles.Model(md).Input(ad).openBoundaries(n).profile='uniform';
                            end
                    end
                else
                    handles.Model(md).Input(ad).openBoundaries(n).profile='uniform';
                end
            end
            setHandles(handles);
            refreshOpenBoundaries;
            
        case{'selectforcing'}
            fc=handles.Model(md).Input(ad).openBoundaries(handles.Model(md).Input(ad).activeOpenBoundary).forcing;
            iac=handles.Model(md).Input(ad).activeOpenBoundaries;
            for ii=1:length(iac)
                n=iac(ii);
                handles.Model(md).Input(ad).openBoundaries(n).forcing=fc;
            end
            handles=ddb_countOpenBoundaries(handles,ad);
            setHandles(handles);
            refreshOpenBoundaries;
            
        case{'editalpha'}
            alp=handles.Model(md).Input(ad).openBoundaries(handles.Model(md).Input(ad).activeOpenBoundary).alpha;
            iac=handles.Model(md).Input(ad).activeOpenBoundaries;
            for ii=1:length(iac)
                n=iac(ii);
                handles.Model(md).Input(ad).openBoundaries(n).alpha=alp;
            end
            handles=ddb_countOpenBoundaries(handles,ad);
            setHandles(handles);
            refreshOpenBoundaries;
            
        case{'selectprofile'}
            prf=handles.Model(md).Input(ad).openBoundaries(handles.Model(md).Input(ad).activeOpenBoundary).profile;
            iac=handles.Model(md).Input(ad).activeOpenBoundaries;
            for ii=1:length(iac)
                n=iac(ii);
                handles.Model(md).Input(ad).openBoundaries(n).profile=prf;
                switch lower(handles.Model(md).Input(ad).openBoundaries(n).type)
                    case{'z','n'}
                        handles.Model(md).Input(ad).openBoundaries(n).profile='uniform';
                    case{'q','t'}
                        if strcmpi(handles.Model(md).Input(ad).openBoundaries(n).profile,'3d-profile')
                            handles.Model(md).Input(ad).openBoundaries(n).profile='uniform';
                        end
                    case{'r'}
                        if strcmpi(handles.Model(md).Input(ad).openBoundaries(n).profile,'logarithmic')
                            handles.Model(md).Input(ad).openBoundaries(n).profile='uniform';
                        end
                end
                if size(handles.Model(md).Input(ad).openBoundaries(n).timeSeriesA,2)<handles.Model(md).Input(ad).KMax
                    for k=2:handles.Model(md).Input(ad).KMax
                        handles.Model(md).Input(ad).openBoundaries(n).timeSeriesA(:,k)=handles.Model(md).Input(ad).openBoundaries(n).timeSeriesA(:,1);
                        handles.Model(md).Input(ad).openBoundaries(n).timeSeriesB(:,k)=handles.Model(md).Input(ad).openBoundaries(n).timeSeriesB(:,1);
                    end
                end
            end
            setHandles(handles);
            refreshOpenBoundaries;
            
        case{'flowconditions'}
            ddb_zoomOff;
            set(gcf, 'windowbuttondownfcn',   []);
            i=handles.Model(md).Input(ad).activeOpenBoundary;
            frc=handles.Model(md).Input(ad).openBoundaries(i).forcing;
            switch frc,
                case{'A'}
                    ddb_editD3DFlowConditionsAstronomic;
                case{'H'}
                    ddb_editD3DFlowConditionsHarmonic;
                case{'T'}
%                     if ~handles.Model(md).Input(ad).bctFileLoaded
%                         handles=ddb_readBctFile(handles,ad);
%                         setHandles(handles);
%                     end
                    ddb_editD3DFlowConditionsTimeSeries;
                case{'Q'}
                    EditD3DFlowConditionsQHRelation;
            end
            
        case{'transportconditions'}
            ddb_zoomOff;
            set(gcf, 'windowbuttondownfcn',   []);
            ddb_editD3DFlowTransportConditionsTimeSeries;
            
        case{'open'}
            handles.Model(md).Input(ad).addOpenBoundary=0;
            handles.Model(md).Input(ad).selectOpenBoundary=0;
            handles.Model(md).Input(ad).changeOpenBoundary=0;
            handles.Model(md).Input(ad).deleteOpenBoundary=0;
            switch lower(opt2)
                case{'bnd'}
                    tp='*.bnd';
                    txt='Select Boundary Definition File';
                case{'bca'}
                    tp='*.bca';
                    txt='Select Astronomical Conditions File';
                case{'cor'}
                    tp='*.cor';
                    txt='Select Astronomical Corrections File';
                case{'bch'}
                    tp='*.bch';
                    txt='Select Harmonic Conditions File';
                case{'bct'}
                    tp='*.bct';
                    txt='Select Time Series Conditions File';
                case{'bcc'}
                    tp='*.bcc';
                    txt='Select Harmonic Conditions File';
            end
            [filename, pathname, filterindex] = uigetfile(tp,txt);
            if pathname~=0
                curdir=[lower(cd) '\'];
                if ~strcmpi(curdir,pathname)
                    filename=[pathname filename];
                end
                switch lower(opt2)
                    case{'bnd'}
                        handles.Model(md).Input(ad).bndFile=filename;
                        handles=ddb_readBndFile(handles,ad);
                        handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries');
                    case{'bca'}
                        handles.Model(md).Input(ad).bcaFile=filename;
                        handles=ddb_readBcaFile(handles,ad);
                    case{'cor'}
                        handles.Model(md).Input(ad).corFile=filename;
                        handles=ddb_readCorFile(handles,ad);
                    case{'bch'}
                        handles.Model(md).Input(ad).bchFile=filename;
                        handles=ddb_readBchFile(handles,ad);
                    case{'bct'}
                        handles.Model(md).Input(ad).bctFile=filename;
                        handles=ddb_readBctFile(handles,ad);
                    case{'bcc'}
                        handles.Model(md).Input(ad).bccFile=filename;
                        handles=ddb_readBccFile(handles,ad);
                end
                clearInstructions;
                setHandles(handles);
                refreshOpenBoundaries;
            end
            
        case{'save'}
            handles.Model(md).Input(ad).addOpenBoundary=0;
            handles.Model(md).Input(ad).selectOpenBoundary=0;
            handles.Model(md).Input(ad).changeOpenBoundary=0;
            handles.Model(md).Input(ad).deleteOpenBoundary=0;
            switch lower(opt2)
                case{'bnd'}
                    tp='*.bnd';
                    txt='Select Boundary Definition File';
                case{'bca'}
                    tp='*.bca';
                    txt='Select Astronomical Conditions File';
                case{'cor'}
                    tp='*.cor';
                    txt='Select Astronomical Corrections File';
                case{'bch'}
                    tp='*.bch';
                    txt='Select Harmonic Conditions File';
                case{'bct'}
                    tp='*.bct';
                    txt='Select Time Series Conditions File';
                case{'bcc'}
                    tp='*.bcc';
                    txt='Select Transport Conditions File';
            end
            [filename, pathname, filterindex] = uiputfile(tp,txt);
            if pathname~=0
                curdir=[lower(cd) '\'];
                if ~strcmpi(curdir,pathname)
                    filename=[pathname filename];
                end
                switch lower(opt2)
                    case{'bnd'}
                        handles.Model(md).Input(ad).bndFile=filename;
                        ddb_saveBndFile(handles.Model(md).Input(ad).openBoundaries,handles.Model(md).Input(ad).bndFile);
                    case{'bca'}
                        handles.Model(md).Input(ad).bcaFile=filename;
                        handles=ddb_saveBcaFile(handles,ad);
                    case{'cor'}
                        handles.Model(md).Input(ad).corFile=filename;
                        handles=ddb_saveCorFile(handles,ad);
                    case{'bch'}
                        handles.Model(md).Input(ad).bchFile=filename;
                        handles=ddb_saveBchFile(handles,ad);
                    case{'bct'}
                        handles.Model(md).Input(ad).bctFile=filename;
                        ddb_saveBctFile(handles,ad);
                    case{'bcc'}
                        handles.Model(md).Input(ad).bccFile=filename;
                        ddb_saveBccFile(handles,ad);
                end
                clearInstructions;
                setHandles(handles);
                refreshOpenBoundaryFiles;
            end
            
    end
end


%%
function addOpenBoundary(x,y)

x1=x(1);x2=x(2);
y1=y(1);y2=y(2);
handles=getHandles;
id=ad;
[m1,n1]=findcornerpoint(x1,y1,handles.Model(md).Input(id).gridX,handles.Model(md).Input(id).gridY);
[m2,n2]=findcornerpoint(x2,y2,handles.Model(md).Input(id).gridX,handles.Model(md).Input(id).gridY);
[m1,n1,m2,n2,ok]=checkBoundaryPoints(m1,n1,m2,n2,1);

if ok==1
    
    if handles.Model(md).Input(ad).changeOpenBoundary
        iac=handles.Model(md).Input(ad).activeOpenBoundary;
    else
        % Add mode
        handles.Model(md).Input(ad).nrOpenBoundaries=handles.Model(md).Input(ad).nrOpenBoundaries+1;
        iac=handles.Model(md).Input(ad).nrOpenBoundaries;
    end
    
    handles.Model(md).Input(ad).openBoundaries(iac).M1=m1;
    handles.Model(md).Input(ad).openBoundaries(iac).N1=n1;
    handles.Model(md).Input(ad).openBoundaries(iac).M2=m2;
    handles.Model(md).Input(ad).openBoundaries(iac).N2=n2;
    
    handles.Model(md).Input(ad).openBoundaries=delft3dflow_setDefaultBoundaryType(handles.Model(md).Input(ad).openBoundaries,iac);
    
    t0=handles.Model(md).Input(ad).startTime;
    t1=handles.Model(md).Input(ad).stopTime;
    nrsed=handles.Model(md).Input(ad).nrSediments;
    nrtrac=handles.Model(md).Input(ad).nrTracers;
    nrharmo=handles.Model(md).Input(ad).nrHarmonicComponents;
    x=handles.Model(md).Input(ad).gridX;
    y=handles.Model(md).Input(ad).gridY;
    depthZ=handles.Model(md).Input(ad).depthZ;
    kcs=handles.Model(md).Input(ad).kcs;
    kmax=handles.Model(md).Input(ad).KMax;
    
    handles.Model(md).Input(ad).openBoundaries=delft3dflow_initializeOpenBoundary(handles.Model(md).Input(ad).openBoundaries,iac, ...
        t0,t1,nrsed,nrtrac,nrharmo,x,y,depthZ,kcs,kmax);
    
    handles.Model(md).Input(ad).openBoundaries(iac).name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.Model(md).Input(ad).openBoundaryNames{iac}=handles.Model(md).Input(ad).openBoundaries(iac).name;
    handles.Model(md).Input(ad).activeOpenBoundary=iac;
    handles.Model(md).Input(ad).activeOpenBoundaries=iac;
    
    handles=ddb_countOpenBoundaries(handles,ad);
    
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries');
    
    if handles.Model(md).Input(ad).changeOpenBoundary
        ddb_clickObject('tag','openboundary','callback',@changeOpenBoundaryFromMap);
        setInstructions({'','','Select open boundary'});
    else
        ddb_dragLine(@addOpenBoundary,'method','alonggridline','x',handles.Model(md).Input(ad).gridX,'y',handles.Model(md).Input(ad).gridY);
        setInstructions({'','','Drag line on map for new open boundary'});
    end
end
setHandles(handles);
refreshOpenBoundaries;

%%
function deleteOpenBoundaries
handles=getHandles;
iac=handles.Model(md).Input(ad).activeOpenBoundaries;
for ii=length(iac):-1:1
    handles.Model(md).Input(ad).activeOpenBoundary=iac(ii);
    setHandles(handles);
    deleteOpenBoundary;    
    handles=getHandles;
end

%%
function deleteOpenBoundary

handles=getHandles;

nrbnd=handles.Model(md).Input(ad).nrOpenBoundaries;

if nrbnd>0
    iac=handles.Model(md).Input(ad).activeOpenBoundary;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','openboundaries');
    if nrbnd>1
        handles.Model(md).Input(ad).openBoundaries=removeFromStruc(handles.Model(md).Input(ad).openBoundaries,iac);
        handles.Model(md).Input(ad).openBoundaryNames=removeFromCellArray(handles.Model(md).Input(ad).openBoundaryNames,iac);
    else
        handles.Model(md).Input(ad).openBoundaryNames={''};
        handles.Model(md).Input(ad).activeOpenBoundary=1;
        handles.Model(md).Input(ad).openBoundaries(1).name='';
        handles.Model(md).Input(ad).openBoundaries(1).M1=[];
        handles.Model(md).Input(ad).openBoundaries(1).M2=[];
        handles.Model(md).Input(ad).openBoundaries(1).N1=[];
        handles.Model(md).Input(ad).openBoundaries(1).N2=[];
        handles.Model(md).Input(ad).openBoundaries(1).type='Z';
        handles.Model(md).Input(ad).openBoundaries(1).forcing='A';
        handles.Model(md).Input(ad).openBoundaries(1).profile='uniform';
        handles.Model(md).Input(ad).openBoundaries(1).alpha=0;
        clearInstructions;
    end
    if iac==nrbnd
        iac=nrbnd-1;
    end
    handles.Model(md).Input(ad).nrOpenBoundaries=nrbnd-1;
    handles.Model(md).Input(ad).activeOpenBoundary=max(iac,1);
    handles.Model(md).Input(ad).activeOpenBoundaries=handles.Model(md).Input(ad).activeOpenBoundary;
    
    handles=ddb_countOpenBoundaries(handles,ad);
    
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries');
    setHandles(handles);
    refreshOpenBoundaries;
    %    refreshOpenBoundaryFiles;
end

%%
function deleteOpenBoundaryFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeOpenBoundary=iac;
setHandles(handles);
deleteOpenBoundary;

%%
function selectOpenBoundaryFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeOpenBoundary=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','openboundaries');
setHandles(handles);
refreshOpenBoundaries;

%%
function changeOpenBoundaryFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeOpenBoundary=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','openboundaries');
setHandles(handles);
refreshOpenBoundaries;
ddb_dragLine(@addOpenBoundary,'free');
setInstructions({'','','Drag new open boundary'});

%%
function refreshOpenBoundaries

handles=getHandles;

iac=handles.Model(md).Input(ad).activeOpenBoundary;

if handles.Model(md).Input(ad).KMax>1
    switch lower(handles.Model(md).Input(ad).openBoundaries(iac).type)
        case{'z','n'}
            handles.Model(md).Input(ad).profileTexts={'Uniform'};
            handles.Model(md).Input(ad).profileOptions={'uniform'};
        case{'c'}
            handles.Model(md).Input(ad).profileTexts={'Uniform','Logarithmic','Per Layer'};
            handles.Model(md).Input(ad).profileOptions={'uniform','logarithmic','3d-profile'};
        case{'r'}
            handles.Model(md).Input(ad).profileTexts={'Uniform','Per Layer'};
            handles.Model(md).Input(ad).profileOptions={'uniform','3d-profile'};
        case{'t','q'}
            handles.Model(md).Input(ad).profileTexts={'Uniform','Logarithmic'};
            handles.Model(md).Input(ad).profileOptions={'uniform','logarithmic'};
    end
else
    handles.Model(md).Input(ad).profileTexts={'Uniform'};
    handles.Model(md).Input(ad).profileOptions={'uniform'};
end

setHandles(handles);

gui_updateActiveTab;

refreshOpenBoundaryFiles;

%%
function refreshOpenBoundaryFiles
gui_updateActiveTab;

%%
function [m1,n1,m2,n2,ok]=checkBoundaryPoints(m1,n1,m2,n2,icp)

handles=getHandles;

kcs=handles.Model(md).Input(ad).kcs;

ok=0;

if m1~=m2 && n1~=n2
    return
end

if icp==1
    
    if m1==m2 && n1==n2
        return
    end
    
    if m2~=m1
        if m2>m1
            m1=m1+1;
            mm1=m1;
            mm2=m2;
        else
            m2=m2+1;
            mm1=m2;
            mm2=m1;
        end
        sumkcs1=sum(kcs(mm1:mm2,n1));
        sumkcs2=sum(kcs(mm1:mm2,n1+1));
        if sumkcs1==mm2-mm1+1 && sumkcs2==0
            % upper
            ok=1;
            n1=n1+1;
            n2=n1;
        elseif sumkcs2==mm2-mm1+1 && sumkcs1==0
            % lower
            ok=1;
        else
            ok=0;
        end
        if mm2==mm1 && (kcs(mm2+1,n1)==1 || kcs(mm2-1,n1)==1)
            ok=0;
        end
    else
        if n2>n1
            n1=n1+1;
            nn1=n1;
            nn2=n2;
        else
            n2=n2+1;
            nn1=n2;
            nn2=n1;
        end
        sumkcs1=sum(kcs(m1,nn1:nn2));
        sumkcs2=sum(kcs(m1+1,nn1:nn2));
        if sumkcs1==nn2-nn1+1 && sumkcs2==0
            % right
            ok=1;
            m1=m1+1;
            m2=m1;
        elseif sumkcs2==nn2-nn1+1 && sumkcs1==0
            % left
            ok=1;
        else
            ok=0;
        end
        if nn2==nn1 && (kcs(m1,nn2+1)==1 || kcs(m1,nn2-1)==1)
            ok=0;
        end
    end
end
