function d = UCIT_SelectTransectsUS(datatype,transectsSoundingID,begintransect,endtransect)
%UCIT_SELECTTRANSECTSUS select a number of alongshore transects to plot
%certain parameters of
% Syntax: SelectTransectsUS('Lidar Data US','2002',9,1200)
%
%   See also plotAlongshore

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Ben de Sonneville
%
%       Ben.deSonneville@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

[check]=UCIT_checkPopups(1, 1);
if check == 0
    return
end

mapWhandle = findobj('tag','mapWindow');

if ~isempty(mapWhandle) & strcmp(UCIT_DC_getInfoFromPopup('TransectsDatatype'),'Lidar Data US')
    [d] = UCIT_getMetaData;
elseif isempty(mapWhandle)
    disp('Make overview figure first')
    return
end

if nargin==0
    figure(mapWhandle)
    [xv,yv] = UCIT_WS_drawPolygon;
    polygon=[xv yv];
    test = d.contour;
    id1 = inpolygon(test(:,1),test(:,3),polygon(:,1),polygon(:,2));
    id2 = inpolygon(test(:,2),test(:,4),polygon(:,1),polygon(:,2));
    id = (id1|id2);
    
    e=find(id>0);NHandle.beginTransect=findobj('tag','beginTransect');NHandle.endTransect=findobj('tag','endTransect');
    
    set(NHandle.beginTransect,'value',e(1));set(NHandle.endTransect,'value',e(end));
else
    a=find(str2double(vertcat(d.transectID))==str2double(begintransect));
    b=find(str2double(vertcat(d.transectID))==str2double(endtransect));
    id=[a:b];
end

fh=findobj('tag','mapWindow');
figure(fh);
% if length(d)>5000
%     dx=50000;
% elseif length(d)>2500&length(d)<5000
%     dx=25000;
% elseif length(d)>1000&length(d)<2500
%     dx=10000;
% elseif length(d)>250&length(d)<1000
%     dx=3000;
% elseif length(d)>50&length(d)<250
%     dx=1500;
% else
%     dx=500;
% end
% 
% coord=d.contour(id,:);
% maxx=max(coord(:,1));
% minx=min(coord(:,1));
% maxy=max(coord(:,2));
% miny=min(coord(:,2));

% axis([(minx-dx) (maxx+dx) (miny-1000) (maxy+1000)] );
% ah = gca;

% getUSGSMetadata

% for i=1:length(d);
%     d(i).shorePos(find(d(i).shorePos ==-999.99))=nan;
%     d(i).shoreLat(find(d(i).shoreLat ==-999.99))=nan;
%     d(i).shoreLon(find(d(i).shoreLon ==-999.99))=nan;
%     d(i).shoreNorth(find(d(i).shoreNorth ==-999.99))=nan;
%     d(i).shoreEast(find(d(i).shoreEast ==-999.99))=nan;
%     d(i).tanb(find(d(i).tanb ==-999.99))=nan;
%     d(i).Tp(find(d(i).Tp ==-999.99))=nan;
%     d(i).L0(find(d(i).L0 ==-999.99))=nan;
%     d(i).Hs(find(d(i).Hs ==-999.99))=nan;
%     d(i).bias(find(d(i).bias ==-999.99))=nan;
%     d(i).Z_mhw(find(d(i).Z_mhw ==-999.99))=nan;
% 
% end


% Find all transects and colour them blue
figure(fh);
rayH=findobj(gca,'type','line','LineStyle','-');
dpTs=get(rayH,'tag');

for i = 1:length(dpTs)-1
    tagtext = dpTs{i};
    underscores = strfind(tagtext,'_');
    id_text(i) = str2double(tagtext([underscores(2)+1:underscores(3)-1]));
end

[C,IA,IB] = intersect(str2double(d.transectID(id)),id_text');

selection=get(rayH(IB),'tag');

for jj=1:length(selection)
    tt=findobj('tag',selection{jj});
    set(tt,'color','b');
end

