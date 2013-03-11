function ddb_TsunamiToolbox_okada(varargin)
%DDB_TSUNAMITOOLBOX_OKADA  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_TsunamiToolbox_okada(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_TsunamiToolbox_okada
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    handles=getHandles;
    h=findobj(gca,'Tag','Plates');
    if isempty(h)
        dr=handles.Toolbox(tb).dataDir;
        load([dr 'plates.mat']);
        cs1=handles.screenParameters.coordinateSystem;
        if ~strcmpi(cs1.type,'geographic')
            cs0.name='WGS 84';
            cs0.type='geographic';
            [platesx,platesy]=ddb_coordConvert(platesx,platesy,cs0,cs1);
        end
        h=plot(platesx,platesy);
        set(h,'Color',[1.0 0.5 0.00]);
        set(h,'Tag','Plates');
        set(h,'LineWidth',1.5);
        set(h,'HitTest','off');
    end
    ddb_plotTsunami('activate');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'editmw'}
            editMw;
        case{'drawfaultline'}
            drawFaultLine;
        case{'computewaterlevel'}
            computeWaterLevel(varargin{2});
        case{'loaddata'}
            loadTableData;
        case{'savedata'}
            saveTableData;
    end
end

%%
function editMw

handles=getHandles;

handles=updateTsunamiValues(handles,'mw');

if handles.Toolbox(tb).Input.updateTable
    handles=updateTableValues(handles);
end

setHandles(handles);

%%
function loadTableData

handles=getHandles;

[filename, pathname, filterindex] = uigetfile('*.xml', 'Select Tsunami File','');

if filename==0
    return
end

filename=[pathname filename];
handles.Toolbox(tb).Input.tsunameTableFile=[pathname filename];
handles=ddb_loadTsunamiTableFile(handles,filename);
handles=convertFaultCoordinates(handles,'latlon2xy');
handles=computeLengthAndStrike(handles);

% Update 'bulk' parameters
handles=updateTsunamiValues(handles,'length');

setHandles(handles);

plotFaultLine;

%%
function plotFaultLine

handles=getHandles;

ddb_zoomOff;

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    x=handles.Toolbox(tb).Input.segmentLon;
    y=handles.Toolbox(tb).Input.segmentLat;
else
    x=handles.Toolbox(tb).Input.segmentX;
    y=handles.Toolbox(tb).Input.segmentY;
end

handles=deleteFaultLine(handles);
h=gui_polyline('plot','x',x,'y',y,'tag','tsunamifault','marker','o','changecallback',@changeFaultLine);
handles.Toolbox(tb).Input.faulthandle=h;

setHandles(handles);

%%
function saveTableData

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.xml', 'Select Tsunami XML File','');
if filename==0
    return
end
filename=[pathname filename];
handles.Toolbox(tb).Input.tsunameTableFile=filename;
setHandles(handles);
ddb_saveTsunamiTableFile(handles,filename);


%%
function drawFaultLine

handles=getHandles;

xmldir=handles.Toolbox(tb).xmlDir;
xmlfile='Tsunami.initialparameters.xml';

h=handles.Toolbox(tb).Input;

[h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);

if ok
    
    handles.Toolbox(tb).Input=h;
    
    ddb_zoomOff;

    handles=deleteFaultLine(handles);

    gui_polyline('draw','Tag','tsunamifault','Marker','o','createcallback',@createFaultLine,'changecallback',@changeFaultLine,'closed',0);

    handles.Toolbox(tb).Input.newFaultLine=1;

    setHandles(handles);

end

%%
function handles=computeLengthAndStrike(handles)
% Compute new length
x = handles.Toolbox(tb).Input.segmentX;
y = handles.Toolbox(tb).Input.segmentY;
pd=pathdistance(x,y);
handles.Toolbox(tb).Input.length=pd(end)/1000;

% Compute new strike
handles.Toolbox(tb).Input.segmentStrike=[];
handles.Toolbox(tb).Input.segmentStrike(1)=90-180*atan2(y(2)-y(1),x(2)-x(1))/pi;
for i=2:length(x)
    handles.Toolbox(tb).Input.segmentStrike(i)=90-180*atan2(y(i)-y(i-1),x(i)-x(i-1))/pi;
end

%%
function createFaultLine(h,x,y,nr)

handles=getHandles;

handles.Toolbox(tb).Input.faulthandle=h;

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    handles.Toolbox(tb).Input.segmentLon=x;
    handles.Toolbox(tb).Input.segmentLat=y;
    handles=convertFaultCoordinates(handles,'latlon2xy');
else
    handles.Toolbox(tb).Input.segmentX=x;
    handles.Toolbox(tb).Input.segmentY=y;
    handles=convertFaultCoordinates(handles,'xy2latlon');
end

handles=computeLengthAndStrike(handles);

% Update theoretical parameters
if handles.Toolbox(tb).Input.updateParameters
    handles=updateTsunamiValues(handles,'length');
end

% Update segment values
handles.Toolbox(tb).Input.segmentDepth=[];
handles.Toolbox(tb).Input.segmentDip=[];
handles.Toolbox(tb).Input.segmentSlipRake=[];
for i=1:length(x)
    handles.Toolbox(tb).Input.segmentDepth(i)=handles.Toolbox(tb).Input.depth;
    handles.Toolbox(tb).Input.segmentDip(i)=handles.Toolbox(tb).Input.dip;
    handles.Toolbox(tb).Input.segmentSlipRake(i)=handles.Toolbox(tb).Input.slipRake;
end
handles=updateTableValues(handles);

setHandles(handles);

gui_updateActiveTab;

%%
function changeFaultLine(h,x,y,nr)

handles=getHandles;

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    handles.Toolbox(tb).Input.segmentLon=x;
    handles.Toolbox(tb).Input.segmentLat=y;
    handles=convertFaultCoordinates(handles,'latlon2xy');
else
    handles.Toolbox(tb).Input.segmentX=x;
    handles.Toolbox(tb).Input.segmentY=y;
    handles=convertFaultCoordinates(handles,'xy2latlon');
end

handles=computeLengthAndStrike(handles);

% Update theoretical parameters
if handles.Toolbox(tb).Input.updateParameters
    handles=updateTsunamiValues(handles,'length');
end

% Update segment values
if handles.Toolbox(tb).Input.updateTable
    handles.Toolbox(tb).Input.segmentDepth=[];
    handles.Toolbox(tb).Input.segmentDip=[];
    handles.Toolbox(tb).Input.segmentSlipRake=[];
    for i=1:length(x)
        handles.Toolbox(tb).Input.segmentDepth(i)=handles.Toolbox(tb).Input.depth;
        handles.Toolbox(tb).Input.segmentDip(i)=handles.Toolbox(tb).Input.dip;
        handles.Toolbox(tb).Input.segmentSlipRake(i)=handles.Toolbox(tb).Input.slipRake;
    end
    handles=updateTableValues(handles);
end

setHandles(handles);

gui_updateActiveTab;

%%
function handles=convertFaultCoordinates(handles,opt)

% Computes x and y or lat and lon values of fault line

switch lower(opt)
    case{'latlon2xy'}
    % Convert x and y to lat-lon
    x=handles.Toolbox(tb).Input.segmentLon;
    y=handles.Toolbox(tb).Input.segmentLat;
    switch lower(handles.screenParameters.coordinateSystem.type)
        case{'projected','cartesian'}
            % Horizontal coordinate system already projected
            cs0.name='WGS 84';
            cs0.type='geographic';
            cs1=handles.screenParameters.coordinateSystem;
        otherwise
            % Horizontal coordinate system is geographic, so find matching
            % UTM system
            cs0=handles.screenParameters.coordinateSystem;
            utmz = fix( ( x(1) / 6 ) + 31);
            if y(1)>0
                utmZone=['WGS 84 / UTM zone ' num2str(utmz) 'N'];
                utmZoneShort=[num2str(utmz) 'N'];
            else
                utmZone=['WGS 84 / UTM zone ' num2str(utmz) 'S'];
                utmZoneShort=[num2str(utmz) 'S'];
            end
            handles.Toolbox(tb).Input.utmZone=utmZone;
            handles.Toolbox(tb).Input.utmZoneShort=utmZoneShort;
            cs1.name=utmZone;
            cs1.type='projected';
    end
    [x,y]=ddb_coordConvert(x,y,cs0,cs1);
    handles.Toolbox(tb).Input.segmentX=x;
    handles.Toolbox(tb).Input.segmentY=y;
case{'xy2latlon'}
    % Only used if screen coordinate system is projected
    x=handles.Toolbox(tb).Input.segmentX;
    y=handles.Toolbox(tb).Input.segmentY;
    cs0=handles.screenParameters.coordinateSystem;
    cs1.name='WGS 84';
    cs1.type='geographic';
    [lon,lat]=ddb_coordConvert(x,y,cs0,cs1);
    handles.Toolbox(tb).Input.segmentLon=lon;
    handles.Toolbox(tb).Input.segmentLat=lat;
end

%%
function handles=updateTsunamiValues(handles,opt)

switch opt
    case{'mw'}
        Mw=handles.Toolbox(tb).Input.Mw;
    case{'length'}
        % Compute magnitude based on length
        if (handles.Toolbox(tb).Input.length > 0)
            Mw = (log10(handles.Toolbox(tb).Input.length) + 2.44) / 0.59;
            handles.Toolbox(tb).Input.Mw = Mw ;
        end
end

mu=30.0e9;
Areaeq=4;

%
%       Options to detrmine the fault area, names below refers to the authors
%         1 = Ward 2004;
%         2 = Coopersmith / Wells 1994 [Dreger 1999];
%         3 = average (Jef);
%         4 = Max. Length and Max width from options 1 & 2
%

fwidth=0;
totflength=0;
disloc=0;

if (Mw > 5)
    Mo = 10.0^(1.5*Mw+9.05);
    disloc = 0.02*10.0^(0.5*Mw-1.8); % dslip in meters
    if (Areaeq == 1)
        totflength  = 10.0^(0.5*Mw-1.8);
        mu1         = mu * 1.66666;
        area        = Mo/(mu1*disloc)/1000000.;
        fwidth      = area/totflength;
    elseif (Areaeq == 2 )
        totflength = 10^(-2.44+0.59*Mw);
        area       = 10^(-3.49+0.91*Mw);
        fwidth     = area/totflength;
    elseif (Areaeq == 3)
        L1  = 10.0^(0.5*Mw-1.8);
        mu1 = mu * 1.66666;
        area= Mo/(mu1*disloc)/1000000.0;
        fw1 = area/L1;
        L2    = 10^(-2.44+0.59*Mw);
        area2 = 10^(-3.49+0.91*Mw);
        fw2   = area2/L2;
        totflength = 0.5*(L1+L2);
        fwidth = 0.5*(fw1 + fw2);
    elseif (Areaeq == 4)
        totflength = 10^(-2.44+0.59*Mw);
        area       = Mo/(mu*disloc)/1000000.0;
        fwidth     = area/totflength;
    end
    
    %     handles.Toolbox(tb).Input.TotalFaultLength=totflength;
    %     handles.Toolbox(tb).Input.FaultWidth=fwidth;
    %     handles.Toolbox(tb).Input.Dislocation=disloc;
else
    %     handles.Toolbox(tb).Input.Mw=0.0;
    %     handles.Toolbox(tb).Input.TotalFaultLength=0;
    %     handles.Toolbox(tb).Input.FaultWidth=0;
    %     handles.Toolbox(tb).Input.Dislocation=0;
end

handles.Toolbox(tb).Input.width=fwidth;
handles.Toolbox(tb).Input.slip=disloc;
handles.Toolbox(tb).Input.theoreticalFaultLength=totflength;



%%
function handles=updateTableValues(handles)

handles.Toolbox(tb).Input.segmentWidth=[];
handles.Toolbox(tb).Input.segmentSlip=[];

for i=1:length(handles.Toolbox(tb).Input.segmentLon)
    handles.Toolbox(tb).Input.segmentWidth(i)=handles.Toolbox(tb).Input.width;
    handles.Toolbox(tb).Input.segmentSlip(i)=handles.Toolbox(tb).Input.slip;
end

%%
function computeWaterLevel(opt)

handles=getHandles;

switch lower(handles.Model(md).name)
    case{'delft3dflow'}
    otherwise
        ddb_giveWarning('text',['Sorry, the tsunami toolbox does not support ' handles.Model(md).longName ' ...']);
        return
end

% First check to see if a grid was loaded
if isempty(handles.Model(md).Input(ad).gridX)
    ddb_giveWarning('text','Please first create or load model grid!');
    return
end

depfiles=[];

for id=1:handles.Model(md).nrDomains
    [filename, pathname, filterindex] = uiputfile('*.ini', ['Select initial conditions file for domain ' upper(handles.Model(md).Input(id).runid)],'');
    filenames{id}=filename;
    if handles.Toolbox(tb).Input.adjustBathymetry
        [filename, pathname, filterindex] = uiputfile('*.dep', ['Select new depth file for domain ' upper(handles.Model(md).Input(id).runid)],'');
        depfiles{id}=filename;
    end
end
        
if ~isempty(pathname)
    
    wb = waitbox('Generating initial tsunami wave ...');
    
    try
                
        switch opt
            case{'fromparameters'}
                xs=handles.Toolbox(tb).Input.segmentX;
                ys=handles.Toolbox(tb).Input.segmentY;
                wdts=handles.Toolbox(tb).Input.segmentWidth;
                depths=handles.Toolbox(tb).Input.segmentDepth;
                dips=handles.Toolbox(tb).Input.segmentDip;
                sliprakes=handles.Toolbox(tb).Input.segmentSlipRake;
                slips=handles.Toolbox(tb).Input.segmentSlip;
                
                % Compute tsunami wave (in projected coordinate system!)
                [xx,yy,zz]=ddb_computeTsunamiWave2(xs,ys,depths,dips,wdts,sliprakes,slips);
                
                if handles.Toolbox(tb).Input.saveESRIGridFile
                    % Write tsunami asc file (in geographic coordinates)
                    xmn=min(min(xx));
                    xmx=max(max(xx));
                    ymn=min(min(yy));
                    ymx=max(max(yy));
                    oldSys.name=handles.Toolbox(tb).Input.utmZone;
                    oldSys.type='projected';
                    newSys.name='WGS 84';
                    newSys.type='geographic';
                    [xmn,ymn]=ddb_coordConvert(xmn,ymn,oldSys,newSys);
                    [xmx,ymx]=ddb_coordConvert(xmx,ymx,oldSys,newSys);
                    [xgeo,ygeo]=meshgrid(xmn:0.02:xmx,ymn:0.02:ymx);
                    [xutm,yutm]=ddb_coordConvert(xgeo,ygeo,newSys,oldSys);
                    zgeo=interp2(xx,yy,zz,xutm,yutm);
                    ascfile=[filenames{1}(1:end-4) '.asc'];
                    arcgridwrite(ascfile,xgeo,ygeo,zgeo);
                end

                % Plot figure (first convert to geographic coordinate system)
                if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
                    oldSys.name=handles.Toolbox(tb).Input.utmZone;
                    oldSys.type='projected';
                    newSys.name='WGS 84';
                    newSys.type='geographic';
                    [xx1,yy1]=ddb_coordConvert(xx,yy,oldSys,newSys);
                else
                    oldSys=handles.screenParameters.coordinateSystem;
                    newSys.name='WGS 84';
                    newSys.type='geographic';
                    [xx1,yy1]=ddb_coordConvert(xx,yy,oldSys,newSys);
                end
                
            otherwise
                % Load tsunami wave (in geographic coordinate system!)
                [xx yy zz info] = arc_asc_read(handles.Toolbox(tb).Input.gridFile);
                xx1=xx;
                yy1=yy;

        end
        
        ddb_plotInitialTsunami(handles,xx1,yy1,zz);
        
        % Interpolate initial tsunami wave onto model grid(s)
        for id=1:handles.Model(md).nrDomains
                        
            xz=handles.Model(md).Input(id).gridXZ;
            yz=handles.Model(md).Input(id).gridYZ;
            dp=handles.Model(md).Input(id).depth;

            oldSys=handles.screenParameters.coordinateSystem;
            newSys.name='WGS 84';
            newSys.type='geographic';

            switch opt
                case{'fromparameters'}                    
                    % If in geographic coordinate system, convert grids first to
                    % projected coordinate system
                    if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
                        newSys.name=handles.Toolbox(tb).Input.utmZone;
                        newSys.type='projected';
                    end
            end

            adjustBathymetry=handles.Toolbox(tb).Input.adjustBathymetry;
            
            interpolateTsunamiToGrid('xgrid',xz,'ygrid',yz,'gridcs',oldSys,'tsunamics',newSys, ...
                'xtsunami',xx,'ytsunami',yy,'ztsunami',zz,'inifile',filenames{id}, ...
                'adjustbathymetry',adjustBathymetry,'depth',dp,'newdepfile',depfiles{id});
            
            handles.Model(md).Input(id).iniFile=filenames{id};
            handles.Model(md).Input(id).initialConditions='ini';
            
            if handles.Toolbox(tb).Input.adjustBathymetry
                handles.Model(md).Input(id).depFile=depfiles{id};
                mmax=handles.Model(md).Input(id).MMax;
                nmax=handles.Model(md).Input(id).NMax;
                dp=ddb_wldep('read',handles.Model(md).Input(id).depFile,[mmax nmax]);
                dp(dp==-999)=NaN;
                handles.Model(md).Input(id).depth=-dp(1:end-1,1:end-1);
                handles.Model(md).Input(id).depthZ=getDepthZ(handles.Model(md).Input(id).depth,handles.Model(md).Input(id).dpsOpt);
                handles=ddb_Delft3DFLOW_plotBathy(handles,'plot','domain',id);                
            end
                        
        end
        
        close(wb);
        
        % Reset all boundary conditions to Riemann in order to avoid
        % reflections at the boundaries.
        
        % First check whether other boundary types are there
        bndr=1;
        for id=1:handles.Model(md).nrDomains
            for nb=1:handles.Model(md).Input(id).nrOpenBoundaries
                switch lower(handles.Model(md).Input(id).openBoundaries(nb).type)
                    case{'r'}
                    otherwise
                        bndr=0;
                end
            end
        end
        if ~bndr
            ButtonName = questdlg('Reset all boundaries to Riemann in order to avoid boundary reflections?','','No', 'Yes', 'Yes');
            switch ButtonName,
                case 'Yes'
                    for id=1:handles.Model(md).nrDomains
                        for nb=1:handles.Model(md).Input(id).nrOpenBoundaries
                            switch lower(handles.Model(md).Input(id).openBoundaries(nb).type)
                                case{'r'}
                                otherwise                                    
                                    handles.Model(md).Input(id).openBoundaries(nb).type='R';
                                    handles.Model(md).Input(id).openBoundaries(nb).forcing='T';
                                    t0=handles.Model(md).Input(id).startTime;
                                    t1=handles.Model(md).Input(id).stopTime;
                                    handles.Model(md).Input(id).openBoundaries(nb).timeSeriesT=[t0 t1];
                                    handles.Model(md).Input(id).openBoundaries(nb).timeSeriesA=[0.0 0.0];
                                    handles.Model(md).Input(id).openBoundaries(nb).timeSeriesB=[0.0 0.0];
                            end
                        end
                    end
            end
        end
        
        setHandles(handles);
        
    catch
        close(wb);
        ddb_giveWarning('txt','Some went wrong while generating tsunami wave.');
    end
end

%%
function handles=deleteFaultLine(handles)
try
    delete(handles.Toolbox(tb).Input.faulthandle);
end
handles.Toolbox(tb).Input.faulthandle=[];
