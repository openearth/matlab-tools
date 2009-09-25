function UCIT_plotLandboundary(datatypeinfo,landcolor,seacolor)
%PLOTLANDBOUNDARY   plots a landboundary for a given <datatypeinfo>
%
%   This routine finds a landboundary given <datatypeinfo>
%
%   syntax:
%   plotLandboundary(datatypeinfo,landcolor)
%
%   input:
%       datatypeinfo = datatype info from McDatabase
%       landcolor    = 0: none 1: yellow
%

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld       
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
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

tryldb=1;

if nargin == 1
    landcolor=1;
end

if nargin==2
    if ~strcmp(datatypeinfo(1:3),'NCP')
        landcolor=1;
    else
        landcolor=0;
    end
end


try
    FI=shape('open',which([datatypeinfo '.shp']));
    data=shape('read',FI,0,'lines');
    shph=plot(data(:,1),data(:,2),'k','linewidth',1);
    tryldb=0;
end

if tryldb
    try
        if strcmp(datatypeinfo(1:3),'NCP')
            [X,Y]=landboundary('read',which(['NCP.ldb']));
            shph=plot(X,Y,'k','linewidth',1);

        elseif strcmp(datatypeinfo,'Lidar Data US');
            ldb=landboundary('read',which(['OR_coast_UTM5.ldb']));
            fillpolygon(ldb,'k',[1 1 0.6],100,-100); hold on;
            ldb2=landboundary('read',which(['ref20OR.ldb'])); % this is their reference line
            plot(ldb2(:,1),ldb2(:,2),'color','r','linewidth',2);
            axis equal;axis(1E6*[0.3382    0.4796    4.6537    5.1275])

        elseif ismember(datatypeinfo,{...
                'AHN Hollandse kust', ...
                'Beach Wizard data', ...
                'Delray Beach data', ...
                'DGPS data 10x10', ...
                'Discharge', ...
                'Dutch beach lines', ...
                'Dutch offshore data', ...
                'Jarkus Data', ...
                'Kaartblad Bagger Egmond', ...
                'Kaartblad Jarkus', ...
                'Kaartblad Monitoring', ...
                'Kaartblad Vaklodingen', ...
                'Kaartblad WESP', ...
                'KNMI', ...
                'Netherlands', ...
                'Schematische profielen', ...
                'HelderseZeewering', ...
                'Suppletie lodingen', ...
                'Waterbase', ...
                'Zuno'})
            ldb=landboundary('read',which(['Netherlands.ldb']));
            if landcolor == 1
                fillpolygon(ldb,'k',[1 1 0.6],100,-100);
            else
                [X,Y]=landboundary('read',which(['Netherlands.ldb']));
                shph=plot(X,Y,'k','linewidth',1);
            end
            view(2);
%             xlabel('Easting (m, RD)','fontsize',9);
%             ylabel('Northing (m, RD)','fontsize',9);
%             kmAxis(gca,[50 50]);
        else
            [X,Y]=landboundary('read',which([datatypeinfo '.ldb']));
            shph=plot(X,Y,'k','linewidth',1);
        end
        tryldb=0;
    end
end

if tryldb
    try
        load([datatypeinfo '.mat']);
        plot3(data(:,1),data(:,2),data(:,3),'ko','markersize',1,'markerfacecolor','k');view(2);axis equal
    end
    tryldb=0;
end