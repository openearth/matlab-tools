function varargout = gui_multipolygon(varargin)
%gui_multipolygon  One line description goes here.
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

% $Id: gui_polyline.m 16688 2020-10-27 06:08:38Z ormondt $
% $Date: 2020-10-27 02:08:38 -0400 (Tue, 27 Oct 2020) $
% $Author: ormondt $
% $Revision: 16688 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/gui/experimental/gui_polyline.m $
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
options.fillpolygon=0;
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
options.dxspline=0;
options.cstype='projected';
options.xmin=[];
options.xmax=[];
options.ymin=[];
options.ymax=[];

% Not generic yet! DDB specific.
options.windowbuttonupdownfcn=@ddb_setWindowButtonUpDownFcn;
options.windowbuttonmotionfcn=@ddb_setWindowButtonMotionFcn;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'polygon'}
                options.polygon=varargin{i+1};                
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
            case{'fillpolygon'}
                options.fillpolygon=varargin{i+1};
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
            case{'dxspline'}
                options.dxspline=varargin{i+1};
            case{'cstype'}
                options.cstype=varargin{i+1};
        end
    end
end

switch lower(opt)
        
    case{'plot'}

        hg=hggroup;
        npol=length(options.polygon);

        options.xmin=zeros(1,npol);
        options.xmax=options.xmin;
        options.ymin=options.xmin;
        options.ymax=options.xmin;

        for ip=1:npol
            h(ip)=patch(options.polygon(ip).x,options.polygon(ip).y,'r');
            if options.polygon(ip).active
                set(h(ip),'FaceColor','r');
            else
                set(h(ip),'FaceColor','none');
            end
            set(h(ip),'HitTest','off');
            options.xmin(ip)=min(options.polygon(ip).x);
            options.xmax(ip)=max(options.polygon(ip).x);
            options.ymin(ip)=min(options.polygon(ip).y);
            options.ymax(ip)=max(options.polygon(ip).y);
            options.handles(ip)=h(ip);
        end
        
        options.last_active=[];
        
        set(h,'Parent',hg);
        setappdata(hg,'options',options);
        set(hg,'tag',options.tag);

    case{'activate'}
        
        set(gcf, 'windowbuttondownfcn',   {@clickPoint,hg});
        set(gcf, 'windowbuttonmotionfcn', {@moveMouse,hg});

    case{'deactivate'}
        
        set(gcf, 'windowbuttondownfcn',   []);
        set(gcf, 'windowbuttonmotionfcn', []);
        
    case{'delete'}
        
        try
            delete(hg);
        end

end

% if nargout==1
%     varargout{1}=h;
% elseif nargout==2
%     varargout{1}=x;
%     varargout{2}=y;
% else
%     varargout{1}=h;
% end

if nargout==1
    varargout{1}=hg;
elseif nargout==2
    varargout{1}=x;
    varargout{2}=y;
else
    varargout{1}=hg;
end


%%
function clickPoint(imagefig, varargins,hg)

mouseclick=get(gcf,'SelectionType');
% if ~strcmp(mouseclick,'normal')
%     merge(hg);
%     return
% end

% ERROR KEES
options=getappdata(hg,'options'); 

iin=[];
    
inaxis=0;
for iax=1:length(options.axis)
    pos=get(options.axis(iax), 'CurrentPoint');
    posx=pos(1,1);
    posy=pos(1,2);
    xl=get(options.axis(iax),'XLim');
    yl=get(options.axis(iax),'YLim');
    if posx>=xl(1) && posx<=xl(2) && posy>=yl(1) && posy<=yl(2)
        inaxis=1;
    end
end

h=options.handles;

% If mouse cursor is within one of the axes, set mouse to cross hair
if inaxis
    
    inbox=find(posx>options.xmin & posx<options.xmax & posy>options.ymin & posy<options.ymax);
    
    for j=1:length(inbox)
        ip=inbox(j);
        if inpolygon(posx,posy,options.polygon(ip).x,options.polygon(ip).y)
            iin=ip;
            break
        end
    end
        
    if ~isempty(iin)
        if options.polygon(iin).active
            options.polygon(iin).active=0;
            set(h(iin),'FaceColor','none');
        else
            options.polygon(iin).active=1;
            set(h(iin),'FaceColor','r');
        end
        setappdata(hg,'options',options); 
    end
    
end

%%
function moveMouse(imagefig, varargins, hg)

% ERROR KEES
options=getappdata(hg,'options'); 

iin=[];

inaxis=0;
for iax=1:length(options.axis)
    pos=get(options.axis(iax), 'CurrentPoint');
    posx=pos(1,1);
    posy=pos(1,2);
    xl=get(options.axis(iax),'XLim');
    yl=get(options.axis(iax),'YLim');
    if posx>=xl(1) && posx<=xl(2) && posy>=yl(1) && posy<=yl(2)
        inaxis=1;
    end
end

h=options.handles;

% If mouse cursor is within one of the axes, set mouse to cross hair
if inaxis

    set(gcf, 'Pointer', 'crosshair');    
    
    inbox=find(posx>options.xmin & posx<options.xmax & posy>options.ymin & posy<options.ymax);
    
    for j=1:length(inbox)
        ip=inbox(j);
        if inpolygon(posx,posy,options.polygon(ip).x,options.polygon(ip).y)
            iin=ip;
            break
        end
    end
    
    %
    if ~isempty(iin)
        set(h(iin),'FaceColor','r');
    end
    
    % de-activate last active polyline
    if ~isempty(options.last_active)
        if isempty(iin) || iin~=options.last_active
            % New active polygon found
            if ~options.polygon(options.last_active).active
                set(h(options.last_active),'FaceColor','none');
            end    
        end
    end
    
    if ~isempty(iin)
        options.last_active=iin;
        setappdata(hg,'options',options); 
    end    
             
else
    
    % de-activate last active polyline
    if ~isempty(options.last_active)
        % New active polygon found
        if ~options.polygon(options.last_active).active
            set(h(options.last_active),'FaceColor','none');
        end
        options.last_active=[];
        setappdata(hg,'options',options);
    end
    
    set(gcf,'Pointer','arrow');
end

% %%
% function merge(hg)
% options=getappdata(hg,'options');
% poly1=[];
% 
% nact=0;
% % count active
% for ip=1:length(options.polygon)
%     if options.polygon(ip).active
%         nact=nact+1;
%     end
% end
%         
% nac=0;
% for ip=1:length(options.polygon)
%     if options.polygon(ip).active
%         disp(['Merging ' num2str(nac+1) ' of ' num2str(nact) ' ...']);
%         if nac==0
%             poly1 = polyshape(options.polygon(ip).x,options.polygon(ip).y);
%         else
%             poly2 = polyshape(options.polygon(ip).x,options.polygon(ip).y);
%             poly1 = union(poly1,poly2);
%         end
%         nac=nac+1;
%     end
% end
% if ~isempty(poly1)
%     figure(555)
%     plot(poly1)
% end
% axis equal;
% 
% x=poly1.Vertices(:,1);
% y=poly1.Vertices(:,2);
% [x,y]=convertCoordinates(x,y,'persistent','CS1.code',4326,'CS2.name','WGS 84 / UTM zone 18N','CS2.type','projected');
% 
% x(end+1)=NaN;
% y(end+1)=NaN;
% 
% inan=find(isnan(x));
% npol=length(inan);
% nrp=zeros(1,npol);
% i1=zeros(1,npol);
% i2=zeros(1,npol);
% for k=1:length(inan)
%     if k==1
%         i1(k)=1;
%     else
%         i1(k)=inan(k-1)+1;
%     end    
%     i2(k)=inan(k)-1;
%     nrp(k)=(i2(k)-i1(k))-1;
% end
% 
% fid=fopen('new_england.pol','wt');
% for ipol=1:npol
%     fprintf(fid,'%s\n',['BL' num2str(ipol,'%0.5i')]);
%     fprintf(fid,'%i %i\n',nrp(ipol)+1,2);
%     for ix=1:nrp(ipol)
%         fprintf(fid,'%10.1f %10.1f\n',x(ix+i1(ipol)-1),y(ix+i1(ipol)-1) );
%     end
%     fprintf(fid,'%10.1f %10.1f\n',x(i1(ipol)),y(i1(ipol)) );
% %     if ix==1 || isnan(x(ix))
% %         npol=npol+1;
% %         n=1;
% %         fprintf(fid,'%s\n',['BL' num2str(npol,'%0.5i')]);
% %     n=n+1;
% end
% % while 1
% % end
% fclose(fid);
