function UCIT_plotLidarTransect(d)
%PLOTLIDARTRANSECT   routine plots transect from structure d
%
% input:
%   d = basic UCIT datastructure for transects
%
% output:
%   function has no output
%
%   See also getPlot

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

if nargin==0

    guiH=findobj('tag','UCIT_mainWin');
    d=get(guiH,'userdata');
    
    datatypes = UCIT_getDatatypes;
    url = datatypes.transect.urls{find(strcmp(UCIT_DC_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names))};

    d = readLidarDataNetcdf(url, UCIT_DC_getInfoFromPopup('TransectsArea'),...
        UCIT_DC_getInfoFromPopup('TransectsTransectID'),datenum(UCIT_DC_getInfoFromPopup('TransectsSoundingID'))-datenum(1970,1,1));

    US_getPlot(d);

end

function US_getPlot(d, axisNew)
%---------------------------------------------------------------------%

%% preprocess input to fit below routines
try %#ok<TRYNC>
    if isnumeric(d.area)
        d.area=num2str(d.area);
    end
end

%% prepare figure window
try
    guiH=findobj('tag','UCIT_mainWin');
end

if get(findobj(guiH,'tag','UCIT_holdFigure'),'value')==0&&~isempty(findobj('tag','plotWindow_US'))
    fh=findobj('tag','plotWindow_US');
    figure(fh)
    ah=gca;
    try
        if nargin == 1
            axisNew = axis(gca);
            set(fh,'UserData',d);

            hold off;

            %plot entire jarkus profiel
            if ~isempty(d.ze)
                try
                    ph1=plot(d.xe(~isnan(d.ze)),d.ze(~isnan(d.ze)),'color','b','linestyle','none','marker','diamond','MarkerFaceColor','b','Markersize',4);
                catch
                    ph1=plot(d(1).xe(~isnan(d(1).ze)),d(1).ze(~isnan(d(1).ze)),'color','b','linestyle','none','marker','diamond','MarkerFaceColor','b','Markersize',4);
                end
                hold on

                xlabel('Distance to profile origin [m]');
                ylabel('Height [m]');
                RaaiInformatie=['UCIT - Transect view -  Area: ' d.area '  Transect: ' num2str(d.transectID) '  Time: ' num2str(d.year)];
                title(RaaiInformatie);
                set(gca, 'xlim',[min(d(1).xi(~isnan(d(1).ze))) max(d(1).xi(~isnan(d(1).ze)))]);
                set(gca, 'ylim',[-1 20]);

                plot(d.xe(find(abs(d.xe-d.shorePos)==min(abs(d.xe-d.shorePos)))),d.ze(find(abs(d.xe-d.shorePos)==min(abs(d.xe-d.shorePos)))),'color','r','linestyle','none','marker','*','MarkerFaceColor','r','Markersize',10)
                try
                    line([d.xe(1) d.xe(end)],[d.ze(find(abs(d.xe-d.shorePos)==min(abs(d.xe-d.shorePos)))) d.ze(find(abs(d.xe-d.shorePos)==min(abs(d.xe-d.shorePos))))],'color','k')
                end
                box on
                axis(axisNew)
                minmax = axis;
                handles.XMaxRange = [minmax(1) minmax(2)];
                handles.YMaxRange = [minmax(3) minmax(4)];
                guidata(fh,handles);
            end
        end
    end
else
    try
        fh=figure('tag','plotWindow_US');
        figure(fh);
        RaaiInformatie=['UCIT - Transect view -  Area: ' d.area '  Transect: ' num2str(d.transectID) '  Time: ' num2str(d.year)];
        set(fh,'Name', RaaiInformatie,'NumberTitle','On','Units','normalized');

        ah=axes;

        set(fh,'UserData',d);

        hold on;

        %plot entire jarkus profiel
        if ~isempty(d.ze)
            try
                ph1=plot(d.xe(~isnan(d.ze)),d.ze(~isnan(d.ze)),'color','b','linestyle','none','marker','diamond','MarkerFaceColor','b','Markersize',4);
            catch
                ph1=plot(d(1).xe(~isnan(d(1).ze)),d(1).ze(~isnan(d(1).ze)),'color','b','linestyle','none','marker','diamond','MarkerFaceColor','b','Markersize',4);
            end
            hold on

            xlabel('Distance to profile origin [m]');
            ylabel('Height [m]');
            RaaiInformatie=['UCIT - Transect view -  Area: ' d.area '  Transect: ' num2str(d.transectID) '  Time: ' num2str(d.year)];
            title(RaaiInformatie);
            set(gca, 'xlim',[min(d(1).xi(~isnan(d(1).ze))) max(d(1).xi(~isnan(d(1).ze)))]);
            set(gca, 'ylim',[-1 20]);

            % plot the shoreline position: for the y position take the y value nearest to the estimated shoreposition
            if ~isnan(d.shorePos)
                plot(d.shorePos,d.ze(find(abs(d.xe-d.shorePos)==min(abs(d.xe-d.shorePos)))),'color','r','linestyle','none','marker','*','MarkerFaceColor','r','Markersize',10);
                hline([d.ze(find(abs(d.xe-d.shorePos)==min(abs(d.xe-d.shorePos)))) d.ze(find(abs(d.xe-d.shorePos)==min(abs(d.xe-d.shorePos))))],'k');
            end
            box on
            minmax = axis;
            handles.XMaxRange = [minmax(1) minmax(2)];
            handles.YMaxRange = [minmax(3) minmax(4)];
            guidata(fh,handles);

        else
            plot3(d.fielddata.rawx,d.fielddata.rawy,d.fielddata.rawz)
            xlabel('Distance to profile origin [m]');
            ylabel('Height [m]');
            RaaiInformatie=['UCIT - Transect view -  Area: ' d.area '  Transect: ' num2str(d.transectID) '  Time: ' num2str(d.year)];
            title(RaaiInformatie);
        end
    end
end
box on
handles = guidata(fh);

fh=findobj('tag','plotWindow_US');
[fh,ah] = UCIT_prepareFigure(2, fh, 'UL', ah);

if ~isempty(findobj('tag','mapWindow'))
    UCIT_showTransectOnOverview
end


