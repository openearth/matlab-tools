function ddb_plotOMSStations(handles)
%DDB_PLOTOMSSTATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_plotOMSStations(handles)
%
%   Input:
%   handles =
%
%
%
%
%   Example
%   ddb_plotOMSStations
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
h=findall(gca,'Tag','OMSStations');
delete(h);
h=findall(gca,'Tag','ActiveOMSStation');
delete(h);

if handles.Toolbox(tb).NrStations>0
    
    for i=1:handles.Toolbox(tb).NrStations
        x(i)=handles.Toolbox(tb).Stations(i).x;
        y(i)=handles.Toolbox(tb).Stations(i).y;
    end
    
    z=zeros(size(x))+500;
    plt=plot3(x,y,z,'o');hold on;
    set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','y');
    set(plt,'Tag','OMSStations');
    set(plt,'ButtonDownFcn',{@SelectOMSStation});
    
    n=handles.Toolbox(tb).ActiveStation;
    plt=plot3(x(n),y(n),1000,'o');
    set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveOMSStation');
    %     set(handles.GUIHandles.ListOMSStations,'Value',n);
    
end

%%
function SelectOMSStation(imagefig, varargins)

h=gco;
if strcmp(get(h,'Tag'),'OMSStations')
    handles=getHandles;
    pos = get(gca, 'CurrentPoint');
    posx=pos(1,1);
    posy=pos(1,2);
    
    for i=1:handles.Toolbox(tb).NrStations
        x(i)=handles.Toolbox(tb).Stations(i).x;
        y(i)=handles.Toolbox(tb).Stations(i).y;
    end
    
    dxsq=(x-posx).^2;
    dysq=(y-posy).^2;
    dist=(dxsq+dysq).^0.5;
    [dummy,n]=min(dist);
    h0=findobj(gca,'Tag','ActiveOMSStation');
    delete(h0);
    
    plt=plot3(x(n),y(n),1000,'o');
    set(plt,'MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor','r','Tag','ActiveOMSStation');
    %     set(handles.GUIHandles.ListOMSStations,'Value',n);
    handles.Toolbox(tb).ActiveStation=n;
    
    if strcmpi(handles.ScreenParameters.ActiveSecondTab,'stations')
        ddb_refreshOMSStations(handles);
    end
    
    setHandles(handles);
end


