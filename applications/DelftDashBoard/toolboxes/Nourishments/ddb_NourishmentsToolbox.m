function ddb_NourishmentsToolbox(varargin)
%DDB_GEOIMAGETOOLBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_GeoImageToolbox(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_GeoImageToolbox
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
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotNourishments('activate');
    handles=getHandles;
    clearInstructions;
    setUIElements(handles.Model(md).GUI.elements.tabs(1).elements);
else
    %Options selected
    handles=getHandles;
    opt=lower(varargin{1});
    switch opt
        case{'drawrectangle'}
            setInstructions({'','','Use mouse to draw model outline on map'});
            UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','ModelOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeModelOnMap,'onstart',@deleteModel);
        case{'drawpolygon'}
            drawPolygon;
        case{'computenourishment'}
            computeNourishment;
        case{'editoutline'}
            editOutline;
        case{'loadcurrents'}
            loadCurrents;
    end
end

%%
function changeModelOnMap(x0,y0,dx,dy,rotation,h)

setInstructions({'','Left-click and drag markers to change corner points','Right-click and drag yellow marker to move entire box'});

handles=getHandles;
handles.Toolbox(tb).Input.modelOutlineHandle=h;
handles.Toolbox(tb).Input.xLim(1)=x0;
handles.Toolbox(tb).Input.yLim(1)=y0;
handles.Toolbox(tb).Input.xLim(2)=x0+dx;
handles.Toolbox(tb).Input.yLim(2)=y0+dy;

% cs=handles.screenParameters.coordinateSystem;
% dataCoord.name='WGS 84';
% dataCoord.type='geographic';
% 
% % Find bounding box for data
% if ~strcmpi(cs.name,'wgs 84') || ~strcmpi(cs.type,'geographic')
%     ddx=dx/10;
%     ddy=dy/10;
%     [xtmp,ytmp]=meshgrid(x0-ddx:ddx:x0+dx+ddx,y0-ddy:ddy:y0+dy+ddy);
%     [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,cs,dataCoord);
%     dx=max(max(xtmp2))-min(min(xtmp2));
% end
% 
% npix=handles.Toolbox(tb).Input.nPix;
% zmlev=round(log2(npix*3/(dx)));
% zmlev=max(zmlev,4);
% zmlev=min(zmlev,23);
% 
% handles.Toolbox(tb).Input.zoomLevelStrings{1}=['auto (' num2str(zmlev) ')'];
% 
setHandles(handles);
setUIElement('editxmin');
setUIElement('editxmax');
setUIElement('editymin');
setUIElement('editymax');

%%
function editOutline
handles=getHandles;
if ~isempty(handles.Toolbox(tb).Input.imageOutlineHandle)
    try
        delete(handles.Toolbox(tb).Input.imageOutlineHandle);
    end
end
x0=handles.Toolbox(tb).Input.xLim(1);
y0=handles.Toolbox(tb).Input.yLim(1);
dx=handles.Toolbox(tb).Input.xLim(2)-x0;
dy=handles.Toolbox(tb).Input.yLim(2)-y0;

h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','ImageOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeGeoImageOnMap, ...
    'onstart',@deleteImageOutline,'x0',x0,'y0',y0,'dx',dx,'dy',dy);
handles.Toolbox(tb).Input.imageOutlineHandle=h;
setHandles(handles);

%%
function deleteModel
handles=getHandles;
if ~isempty(handles.Toolbox(tb).Input.modelOutlineHandle)
    try
        delete(handles.Toolbox(tb).Input.modelOutlineHandle);
    end
end

%%
function drawPolygon
handles=getHandles;
ddb_zoomOff;
h=findobj(gcf,'Tag','NourishmentOutline');
if ~isempty(h)
    delete(h);
end
UIPolyline(gca,'draw','Tag','NourishmentOutline','Marker','o','Callback',@changePolygon,'closed',1);
setHandles(handles);
%setUIElement('bathymetrypanel.export.savepolygon');

%%
function changePolygon(x,y,varargin)
handles=getHandles;
handles.Toolbox(tb).Input.polygonX=x;
handles.Toolbox(tb).Input.polygonY=y;
handles.Toolbox(tb).Input.polyLength=length(x);
setHandles(handles);
% setUIElement('bathymetrypanel.export.exportbathy');
% setUIElement('bathymetrypanel.export.savepolygon');

%%
function loadCurrents
handles=getHandles;
s=load(handles.Toolbox(tb).Input.currentsFile);
h=findobj(gcf,'Tag','ResidualCurrents');
if ~isempty(h)
    delete(h);
end
q=quiver(s.x,s.y,s.u,s.v,'k');
set(q,'Tag','ResidualCurrents');

%%
function computeNourishment

handles=getHandles;

%% Parameters

% Numerical and physical parameters
par.cE=0.02;
par.nfac=2;
par.d=handles.Toolbox(tb).Input.diffusionCoefficient; % Diffusion
par.ws=handles.Toolbox(tb).Input.settlingVelocity; % Diffusion
par.morfac=1000;
par.cdryb=1600;

% Time parameters
nyear=handles.Toolbox(tb).Input.nrYears;
toutp=handles.Toolbox(tb).Input.outputInterval; % years
t0=0;
t1=nyear*365*86400/par.morfac;

tmorph=0;
dt=60; % seconds
t=t0:dt:t1;
nt=length(t);
par.dt=dt;

ntout=round(toutp*365*86400/dt/par.morfac);

%% Grid and bathymetry

xlim=handles.Toolbox(tb).Input.xLim;
ylim=handles.Toolbox(tb).Input.yLim;
dx=handles.Toolbox(tb).Input.dX;
dy=handles.Toolbox(tb).Input.dX;
xx=xlim(1):dx:xlim(2);
yy=ylim(1):dy:ylim(2);
[xg,yg]=meshgrid(xx,yy);

[xb,yb,zb,ok]=ddb_getBathy(handles,xlim,ylim,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',dx);

zz=interp2(xb,yb,zb,xg,yg);

[grd,dps]=getgridinfo('gridx',xg,'gridy',yg,'depth',zz);

%% Nourishment
nourdep=zeros(size(dps));
xpol=handles.Toolbox(tb).Input.polygonX;
ypol=handles.Toolbox(tb).Input.polygonY;
inpol=inpolygon(grd.xg,grd.yg,xpol,ypol);
polarea=polyarea(xpol,ypol);

switch handles.Toolbox(tb).Input.nourishmentType
    case{'volume'}
        nourhgt=handles.Toolbox(tb).Input.nourishmentVolume/polarea;
        nourdep(inpol)=nourhgt;
    case{'height'}
        nourdep(inpol)=handles.Toolbox(tb).Input.nourishmentHeight-dps(inpol);
    case{'thickness'}
        nourdep(inpol)=handles.Toolbox(tb).Input.nourishmentThickness;
end

sedthick=nourdep;

%% Residual currents

switch lower(handles.Toolbox(tb).Input.currentSource)
    case{'file'}
        % Load mat file with currents
        s=load(handles.Toolbox(tb).Input.currentsFile);        
        xx=s.x(~isnan(s.x));
        yy=s.y(~isnan(s.y));
        uu=s.u(~isnan(s.u));
        vv=s.v(~isnan(s.v));
        % Interpolate onto grid
        u=griddata(xx,yy,uu,grd.xg,grd.yg);
        v=griddata(xx,yy,vv,grd.xg,grd.yg);
        u(isnan(u))=0;
        v(isnan(v))=0;        
    otherwise
        u=zeros(size(grd.xg))+handles.Toolbox(tb).Input.currentU;
        v=zeros(size(grd.xg))+handles.Toolbox(tb).Input.currentV;        
end

ug=u;
vg=v;

%% Initial conditions
c=zeros(size(grd.xg))+par.cE;

%% Put everything in 1D vectors
np=grd.nx*grd.ny;
u=reshape(u,[1 np]);
v=reshape(v,[1 np]);
c=reshape(c,[1 np]);
dps=reshape(dps,[1 np]);
sedthick=reshape(sedthick,[1 np]);
grd.dx=reshape(grd.dx,[1 np]);
grd.dy=reshape(grd.dy,[1 np]);
grd.a=reshape(grd.a,[1 np]);
nourdep=reshape(nourdep,[1 np]);
wl=zeros(size(c))+0;
ce=zeros(size(c))+par.cE;

%% Initial equilibrium water depth

dps=dps-2;

he=wl-dps;
he=max(he,0.01);

dps=dps+nourdep;


sedthick0=sedthick;

xl=[min(min(grd.xg))+handles.Toolbox(tb).Input.dX max(max(grd.xg))];
yl=[min(min(grd.yg))+handles.Toolbox(tb).Input.dX max(max(grd.yg))];


figure(999)
clf;

mxthick=ceil(max(max(nourdep)));
mndep=floor(min(min(dps)));
mxdep=ceil(max(max(dps)));

%% Start of computational code
for it=1:nt
%    disp([num2str(it) ' of ' num2str(nt)])
    t(it)=(it-1)*dt;
    updbed=0;
    if t(it)>=tmorph
        updbed=1;
    end
    if t(it)==tmorph
        cmorphstart=c;
        sedvol0=10000*nansum(sedthick)+par.morfac*nansum(c.*-dps)*10000/par.cdryb;
        thckvol0=10000*nansum(sedthick);
    end
    
    [c,dps,sedthick,srcsnk]=difu4(c,wl,dps,sedthick,he,u,v,grd,par,updbed);

    polz=zeros(size(handles.Toolbox(tb).Input.polygonX))+1000;

    if it==1 || round(it/ntout)==it/ntout || it==nt
    
        figure(999)
        
        c1=reshape(c,[grd.ny grd.nx]);
        dps1=reshape(dps,[grd.ny grd.nx])+2;
        dps2=dps-par.morfac*c.*-dps/par.cdryb;
        
        if it==1
            dps0=dps2;
            dps0=reshape(dps0,[grd.ny grd.nx])+2;
        end
        
        dps2=reshape(dps2,[grd.ny grd.nx])+2;
        
        sedthick1=reshape(sedthick,[grd.ny grd.nx]);
        
        sedthick2=sedthick+par.morfac*(c-par.cE).*-dps/par.cdryb;
        sedthick2=reshape(sedthick2,[grd.ny grd.nx]);
        srcsnk1=reshape(srcsnk,[grd.ny grd.nx]);
        
        tyear=round(t(it)*par.morfac/86400/365);
        
        
        subplot(2,2,1)        
        pcolor(grd.xg,grd.yg,dps2-dps0);shading flat;axis equal;clim([-mxthick mxthick]);colorbar;
        hold on;
        quiver(grd.xg(1:2:end,1:2:end),grd.yg(1:2:end,1:2:end),ug(1:2:end,1:2:end),vg(1:2:end,1:2:end),'k');
        pol=plot(handles.Toolbox(tb).Input.polygonX,handles.Toolbox(tb).Input.polygonY,'r');
        set(pol,'LineWidth',2);
        axis equal;
        set(gca,'xlim',xl,'ylim',yl);
        title(['sedero - ' num2str(tyear,'%i') ' years']);
%        drawnow;
        
%         subplot(2,2,2)        
%         pcolor(grd.xg,grd.yg,c1);shading flat;axis equal;clim([0 1]);colorbar;
%         hold on;
%         quiver(grd.xg(1:2:end,1:2:end),grd.yg(1:2:end,1:2:end),ug(1:2:end,1:2:end),vg(1:2:end,1:2:end),'k');
%         pol=plot(handles.Toolbox(tb).Input.polygonX,handles.Toolbox(tb).Input.polygonY,'r');
%         set(pol,'LineWidth',2);
%         axis equal;
%         set(gca,'xlim',xl,'ylim',yl);
%         title(['concentration - ' num2str(tyear,'%i') ' years']);
        
        subplot(2,2,3)        
        pcolor(grd.xg,grd.yg,sedthick2);shading flat;axis equal;clim([0 mxthick]);colorbar;
        hold on;
        quiver(grd.xg(1:2:end,1:2:end),grd.yg(1:2:end,1:2:end),ug(1:2:end,1:2:end),vg(1:2:end,1:2:end),'k');
        pol=plot(handles.Toolbox(tb).Input.polygonX,handles.Toolbox(tb).Input.polygonY,'r');
        set(pol,'LineWidth',2);
        axis equal;
        set(gca,'xlim',xl,'ylim',yl);
        title(['sediment thickness - ' num2str(tyear,'%i') ' years']);

        subplot(2,2,4)
        pcolor(grd.xg,grd.yg,dps2);shading flat;axis equal;clim([-5 mxdep]);colorbar;
        hold on;
        quiver(grd.xg(1:2:end,1:2:end),grd.yg(1:2:end,1:2:end),ug(1:2:end,1:2:end),vg(1:2:end,1:2:end),'k');
        pol=plot(handles.Toolbox(tb).Input.polygonX,handles.Toolbox(tb).Input.polygonY,'r');
        set(pol,'LineWidth',2);
        axis equal;
        set(gca,'xlim',xl,'ylim',yl);
        title(['bed level - ' num2str(tyear,'%i') ' years']);
        drawnow;
    end
end
sedvol1=10000*nansum(sedthick)+par.morfac*nansum(c.*-dps)*10000/par.cdryb
thckvol1=10000*nansum(sedthick)
dvol=10000*nansum(sedthick-sedthick0)+nansum((c-cmorphstart).*-dps)*par.morfac*10000/par.cdryb
