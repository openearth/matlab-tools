function varargout = gui_polyline(varargin)
%UIPOLYLINE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = UIPolyline(h, opt, varargin)
%
%   Input:
%   h         =
%   opt       =
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   UIPolyline
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

%

if ischar(varargin{1})
    opt=varargin{1};
else
    hg=varargin{1};
    opt=varargin{2};
end

% Default values
options.linecolor='g';
options.linewidth=1.5;
options.linestyle='-';
options.marker='';
options.markeredgecolor='r';
options.markerfacecolor='r';
options.markersize=4;
options.facecolor='r';
options.maxpoints=10000;
options.text=[];
options.createcallback=[];
options.createinput=[];
options.changecallback=[];
options.changeinput=[];
options.doubleclickcallback=[];
options.doubleclickinput=[];
options.rightclickcallback=[];
options.rightclickinput=[];
options.closed=0;
options.axis=gca;
options.tag='';
options.type='polyline';
options.arrowwidth=2;
options.headwidth=4;
options.headlength=8;
options.nrheads=1;
options.userdata=[];

% Not generic yet! DDB specific.
options.windowbuttonupdownfcn=@ddb_setWindowButtonUpDownFcn;
options.windowbuttonmotionfcn=@ddb_setWindowButtonMotionFcn;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'x'}
                x=varargin{i+1};
            case{'y'}
                y=varargin{i+1};
            case{'tag'}
                options.tag=varargin{i+1};
            case{'linecolor','color'}
                options.linecolor=varargin{i+1};
            case{'linewidth','width'}
                options.linewidth=varargin{i+1};
            case{'linestyle'}
                options.linestyle=varargin{i+1};
            case{'facecolor'}
                options.facecolor=varargin{i+1};
            case{'marker'}
                options.marker=varargin{i+1};
            case{'markeredgecolor'}
                options.markeredgecolor=varargin{i+1};
            case{'markerfacecolor'}
                options.markerfacecolor=varargin{i+1};
            case{'markersize'}
                options.markersize=varargin{i+1};
            case{'max'}
                options.maxpoints=varargin{i+1};
            case{'text'}
                options.text=varargin{i+1};
            case{'createcallback'}
                options.createcallback=varargin{i+1};
            case{'createinput'}
                options.createinput=varargin{i+1};
            case{'changecallback'}
                options.changecallback=varargin{i+1};
            case{'changeinput'}
                options.changeinput=varargin{i+1};
            case{'doubleclickcallback'}
                options.doubleclickcallback=varargin{i+1};
            case{'doubleclickinput'}
                options.doubleclickinput=varargin{i+1};
            case{'rightclickcallback'}
                options.rightclickcallback=varargin{i+1};
            case{'rightclickinput'}
                options.rightclickinput=varargin{i+1};
            case{'closed'}
                options.closed=varargin{i+1};
            case{'windowbuttonupdownfcn'}
                options.windowbuttonupdownfcn=varargin{i+1};
            case{'windowbuttonmotionfcn'}
                options.windowbuttonmotionfcn=varargin{i+1};
            case{'axis'}
                options.axis=varargin{i+1};
            case{'type'}
                options.type=varargin{i+1};
            case{'arrowwidth'}
                options.arrowwidth=varargin{i+1};
            case{'headwidth'}
                options.headwidth=varargin{i+1};
            case{'headlength'}
                options.headlength=varargin{i+1};
            case{'nrheads'}
                options.nrheads=varargin{i+1};
            case{'userdata'}
                options.userdata=varargin{i+1};
        end
    end
end

switch lower(opt)
    case{'draw'}
        
        % Plot first (invisible) point
        
        x=0;
        y=0;
        
        hg=hggroup;

        switch options.type
            case{'polyline','spline'}
                h=plot(x,y);
                set(h,'Color',options.linecolor);
                if ~isempty(options.marker)
                    set(h,'Marker',options.marker);
                    set(h,'MarkerEdgeColor',options.markeredgecolor);
                    set(h,'MarkerFaceColor',options.markerfacecolor);
                    set(h,'MarkerSize',options.markersize);
                end
            case{'curvedarrow'}
                h=patch(x,y,'r');
                set(h,'EdgeColor',options.linecolor);
        end

        set(hg,'Visible','off');
        
        set(hg,'Tag',options.tag);
        set(h,'Parent',hg);
        set(h,'LineWidth',options.linewidth);
        setappdata(hg,'linehandle',h);
        
        setappdata(hg,'x',[]);
        setappdata(hg,'y',[]);
        setappdata(hg,'options',options);
        
        set(gcf, 'windowbuttondownfcn',   {@clickNextPoint,hg});
        set(gcf, 'windowbuttonmotionfcn', {@moveMouse,hg});
        
    case{'plot'}

        hg=hggroup;
        h=plot(0,0);
        set(h,'Parent',hg);
        setappdata(hg,'options',options);
        set(hg,'tag',options.tag);
        setappdata(hg,'x',x);
        setappdata(hg,'y',y);

        h=drawPolyline(hg,'nocallback');
        
    case{'delete'}

        try
            delete(hg);
        end

    case{'change'}
        
        if ~isempty(hg)
            
            for i=1:length(varargin)
                if ischar(varargin{i})
                    switch lower(varargin{i})
                        case{'color'}
                            h=getappdata(hg,'linehandle');
                            set(h,'Color',varargin{i+1});
                        case{'markeredgecolor'}
                            ch=getappdata(hg,'markerhandles');
                            set(ch,'markeredgecolor',varargin{i+1});
                        case{'markerfacecolor'}
                            ch=getappdata(hg,'markerhandles');
                            set(ch,'markerfacecolor',varargin{i+1});
                        case{'markersize'}
                            ch=getappdata(hg,'markerhandles');
                            set(ch,'markersize',varargin{i+1});
                        case{'x'}
                            x=varargin{i+1};
                            h=getappdata(hg,'linehandle');
                            mh=getappdata(hg,'markerhandles');
                            for ii=1:length(mh)
                                set(mh(ii),'XData',x(ii));
                            end
                            tx=getappdata(hg,'texthandles');
                            for ii=1:length(tx)
                                set(tx(ii),'XData',x(ii));
                            end
                            set(h,'XData',x);
                            setappdata(hg,'x',x);
                        case{'y'}
                            y=varargin{i+1};
                            h=getappdata(hg,'linehandle');
                            mh=getappdata(hg,'markerhandles');
                            for ii=1:length(mh)
                                set(mh(ii),'YData',y(ii));
                            end
                            tx=getappdata(hg,'texthandles');
                            for ii=1:length(tx)
                                set(tx(ii),'YData',y(ii));
                            end
                            set(h,'YData',y);
                            setappdata(hg,'y',y);
                    end
                end
            end

        end
end

if nargout==1
    varargout{1}=h;
elseif nargout==2
    varargout{1}=x;
    varargout{2}=y;
else
    varargout{1}=h;
end

%%
function hg=drawPolyline(hg,varargin)
% called to plot the polyline

opt='withcallback';
if ~isempty(varargin)
    opt=varargin{1};
end

x=getappdata(hg,'x');
y=getappdata(hg,'y');
ax=getappdata(hg,'axis');

options=getappdata(hg,'options');
% userdata=get(hg,'UserData');

% Delete temporary polyline
delete(hg);

if ~isempty(x)

    hg=hggroup;
    set(hg,'Tag',options.tag);
    setappdata(hg,'options',options);

    switch options.type
        case{'polyline'}
            h=plot(x,y,'g');
            set(h,'Color',options.linecolor);
        case{'spline'}
            [xs,ys]=spline2d(x',y');
            h=plot(xs,ys,'g');
            set(h,'Color',options.linecolor);
        case{'curvedarrow'}
            [xp,yp]=muppet_makeCurvedArrow(x,y,'arrowwidth',options.arrowwidth, ...
               'headwidth',options.headwidth,'headlength',options.headlength);            
            h=patch(xp,yp,'r');
            set(h,'EdgeColor',options.linecolor);
            set(h,'FaceColor',options.facecolor);
    end
    
    set(h,'Parent',hg);
    set(h,'LineWidth',options.linewidth);
    set(h,'LineStyle',options.linestyle);
    set(h,'HitTest','off');
    setappdata(hg,'linehandle',h);
    setappdata(hg,'x',x);
    setappdata(hg,'y',y);

    setappdata(hg,'axis',ax);
    
    % Markers
    for i=1:length(x)
        mh(i)=plot(x(i),y(i),['r' options.marker]);
        set(mh(i),'MarkerEdgeColor',options.markeredgecolor,'MarkerFaceColor',options.markerfacecolor,'MarkerSize',options.markersize,'LineStyle','none');
        set(mh(i),'ButtonDownFcn',{@moveVertex});
        setappdata(mh(i),'parent',h);
        setappdata(mh(i),'number',i);
        set(mh(i),'Parent',hg);
    end
    setappdata(hg,'markerhandles',mh);

    tx=[];
    if ~isempty(options.text)
        for i=1:length(x)
            tx(i)=text(x(i),y(i),options.text{i});
            set(tx(i),'Tag',options.tag,'HitTest','off','Clipping','on');
            setappdata(tx(i),'number',i);
            set(tx(i),'Parent',hg);
        end
    end   
    setappdata(hg,'texthandles',tx);
    setappdata(hg,'axis',ax);
    
    if ~isempty(options.createcallback) && strcmpi(opt,'withcallback')
        if isempty(options.createinput)
            feval(options.createcallback,hg,x,y);
        else
            feval(options.createcallback,options.createinput,hg,x,y);
        end
    end
    
end

%%
function clickNextPoint(imagefig, varargins,hg)

mouseclick=get(gcf,'SelectionType');

options=getappdata(hg,'options');

if strcmp(mouseclick,'normal')

    % Left click

    for iax=1:length(options.axis)
        
        pos=get(options.axis(iax), 'CurrentPoint');
        posx=pos(1,1);
        posy=pos(1,2);
        
        xl=get(options.axis(iax),'XLim');
        yl=get(options.axis(iax),'YLim');
        
        if posx>=xl(1) && posx<=xl(2) && posy>=yl(1) && posy<=yl(2)
            
            x=getappdata(hg,'x');
            y=getappdata(hg,'y');
            
            x=[x posx];
            y=[y posy];
            
            setappdata(hg,'x',x);
            setappdata(hg,'y',y);
            
            setappdata(hg,'axis',options.axis(iax));
            setappdata(hg,'subplot',iax);
            
            h=getappdata(hg,'linehandle');

            xp=x;
            yp=y;
            
            switch options.type
                case{'spline'}
                    [xp,yp]=spline2d(x',y');
                    set(h,'Marker','none');
                case{'curvedarrow'}
                    [xp,yp]=muppet_makeCurvedArrow(x,y,'arrowwidth',options.arrowwidth, ...
                        'headwidth',options.headwidth,'headlength',options.headlength);
            end

            set(h,'XData',xp,'YData',yp);
            set(hg,'Visible','on');
            
            if length(x)==options.maxpoints
                feval(options.windowbuttonupdownfcn);
                feval(options.windowbuttonmotionfcn);
                drawPolyline(hg);
            end
            
            break
            
        end
    end
    
else
    
    % Right click
    if options.closed
        % Add last point
        x=getappdata(hg,'x');
        y=getappdata(hg,'y');
        if ~isempty(x)
            x(end+1)=x(1);
            y(end+1)=y(1);
            setappdata(hg,'x',x);
            setappdata(hg,'y',y);
        end
    end
    set(gcf,'Pointer','arrow');
    feval(options.windowbuttonupdownfcn);
    feval(options.windowbuttonmotionfcn);
    drawPolyline(hg);
end

%%
function moveMouse(imagefig, varargins, hg)

options=getappdata(hg,'options');

pos=get(options.axis, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

inaxis=0;
for iax=1:length(options.axis)
    xl=get(options.axis(iax),'XLim');
    yl=get(options.axis(iax),'YLim');
    if posx>=xl(1) && posx<=xl(2) && posy>=yl(1) && posy<=yl(2)
        inaxis=1;
    end
end

% If mouse cursor is within one of the axes, set mouse to cross hair
if inaxis
    set(gcf, 'Pointer', 'crosshair');
else
    set(gcf,'Pointer','arrow');
end

try
    ddb_updateCoordinateText('crosshair');
end

%%
function moveVertex(imagefig, varargins)

mouseclick=get(gcf,'SelectionType');

switch mouseclick
    case{'normal'}
        set(gcf, 'windowbuttonmotionfcn', {@followTrack});
        set(gcf, 'windowbuttonupfcn',     {@stopTrack});
    case{'alt'}
        % right click
        mh=get(gcf,'CurrentObject');
        hg=get(mh,'parent');
        options=getappdata(hg,'options');
        x=getappdata(hg,'x');
        y=getappdata(hg,'y');
        nr=getappdata(mh,'number');
        if ~isempty(options.rightclickcallback)
            if ~isempty(options.rightclickinput)
                feval(options.rightclickcallback,options.rightclickinput,hg,x,y,nr);
            else
                feval(options.rightclickcallback,hg,x,y,nr);
            end
        end        
    case{'open'}
        % right click
        mh=get(gcf,'CurrentObject');
        hg=get(mh,'parent');
        options=getappdata(hg,'options');
        x=getappdata(hg,'x');
        y=getappdata(hg,'y');
        nr=getappdata(mh,'number');
        if ~isempty(options.doubleclickcallback)
            if ~isempty(options.doubleclickinput)
                feval(options.doubleclickcallback,options.doubleclickinput,hg,x,y,nr);
            else
                feval(options.doubleclickcallback,hg,x,y,nr);
            end
        end        
end

%%
function followTrack(imagefig, varargins)
p=get(gcf,'CurrentObject');
hg=get(p,'parent');
options=getappdata(hg,'options');
h=getappdata(hg,'linehandle');
mh=getappdata(hg,'markerhandles');
tx=getappdata(hg,'texthandles');
x=getappdata(hg,'x');
y=getappdata(hg,'y');
nr=getappdata(p,'number');
pos = get(gca, 'CurrentPoint');
xi=pos(1,1);
yi=pos(1,2);
x(nr)=xi;
y(nr)=yi;
if options.closed
    if nr==1
        x(end)=x(1);
        y(end)=y(1);
    elseif nr==length(x)
        x(1)=x(end);
        y(1)=y(end);
    end
end
setappdata(hg,'x',x);
setappdata(hg,'y',y);

xp=x;
yp=y;
switch options.type
    case{'spline'}
        [xp,yp]=spline2d(x',y');
    case{'curvedarrow'}
        [xp,yp]=muppet_makeCurvedArrow(x,y,'arrowwidth',options.arrowwidth, ...
            'headwidth',options.headwidth,'headlength',options.headlength);
        set(h,'FaceColor','none');
end

set(h,'XData',xp,'YData',yp);

if options.closed
    if nr==1
        set(mh(1),'XData',x(nr),'YData',y(nr));
        set(mh(end),'XData',x(nr),'YData',y(nr));
    elseif nr==length(x)
        set(mh(1),'XData',x(nr),'YData',y(nr));
        set(mh(end),'XData',x(nr),'YData',y(nr));
    else
        set(mh(nr),'XData',x(nr),'YData',y(nr));
    end
else
    set(mh(nr),'XData',x(nr),'YData',y(nr));
    if ~isempty(tx)
        set(tx(nr),'Position',[x(nr) y(nr)]);
    end
end
try
    ddb_updateCoordinateText('arrow');
end

%%
function stopTrack(imagefig, varargins)
% Function is called after polyline has been changed

p=get(gcf,'CurrentObject');
hg=get(p,'Parent');
nr=getappdata(p,'number');

options=getappdata(hg,'options');
x=getappdata(hg,'x');
y=getappdata(hg,'y');

feval(options.windowbuttonupdownfcn);
feval(options.windowbuttonmotionfcn);

pos = get(gca, 'CurrentPoint');
xi=pos(1,1);
yi=pos(1,2);

x(nr)=xi;
y(nr)=yi;

setappdata(hg,'x',x);
setappdata(hg,'y',y);

hg=drawPolyline(hg,'withoucallback');

if ~isempty(options.changecallback)
    if isempty(options.changeinput)
        feval(options.changecallback,hg,x,y,nr);
    else
        feval(options.changecallback,options.changeinput,hg,x,y,nr);
    end
end
