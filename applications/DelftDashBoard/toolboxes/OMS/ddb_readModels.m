function hm = ddb_readModels(hm)
%DDB_READMODELS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   hm = ddb_readModels(hm)
%
%   Input:
%   hm =
%
%   Output:
%   hm =
%
%   Example
%   ddb_readModels
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
dirname=[hm.ScenarioDir 'models\'];

continent=hm.Continents;

noset=0;

for jj=1:8
    
    cntdir=[dirname continent{jj}];
    dr=dir(cntdir);
    for kk=1:length(dr)
        if dr(kk).isdir && ~strcmpi(dr(kk).name(1),'.')
            
            fname=[dirname continent{jj} '\' dr(kk).name '\' dr(kk).name '.dat'];
            txt=ReadTextFile(fname);
            
            % Read Models
            
            
            for i=1:length(txt)
                
                switch lower(txt{i}),
                    case {'model'},
                        noset=noset+1;
                        nostat=0;
                        nrprofiles=0;
                        hm.Models(noset).LongName=txt{i+1};
                        hm.Models(noset).NrStations=0;
                        hm.Models(noset).NrAreas=0;
                        hm.Models(noset).RunTime=0;
                        hm.Models(noset).FlowSpinUp=0;
                        hm.Models(noset).WaveSpinUp=0;
                        hm.Models(noset).HisTimeStep=0;
                        hm.Models(noset).MapTimeStep=0;
                        hm.Models(noset).ComTimeStep=0;
                        hm.Models(noset).FlowNested=0;
                        hm.Models(noset).FlowNestModel=[];
                        hm.Models(noset).WaveNested=0;
                        hm.Models(noset).WaveNestModel=[];
                        hm.Models(noset).UseMeteo='none';
                        hm.Models(noset).MorFac=0;
                        hm.Models(noset).NestedFlowModels=[];
                        hm.Models(noset).NestedWaveModels=[];
                        hm.Models(noset).Continent=continent{jj};
                        hm.Models(noset).Dir=[hm.ScenarioDir 'models\' continent{jj} '\' dr(kk).name '\'];
                        hm.Models(noset).WebSite='none';
                        hm.Models(noset).ArchiveDir=[hm.ArchiveDir continent{jj} '\' dr(kk).name '\archive\'];
                        hm.Models(noset).XTick=0.5;
                        hm.Models(noset).YTick=0.5;
                        hm.Models(noset).PrCorr=101200.0;
                    case {'type'},
                        hm.Models(noset).Type=txt{i+1};
                    case {'abbr','name'},
                        hm.Models(noset).Name=txt{i+1};
                    case {'coordsys'},
                        hm.Models(noset).CoordinateSystem=txt{i+1};
                    case {'coordsystype'},
                        hm.Models(noset).CoordinateSystemType=txt{i+1};
                    case {'runid'},
                        hm.Models(noset).Runid=txt{i+1};
                    case {'website'},
                        hm.Models(noset).WebSite=txt{i+1};
                    case {'position','location'},
                        hm.Models(noset).Location(1)=str2double(txt{i+1});
                        hm.Models(noset).Location(2)=str2double(txt{i+2});
                    case {'size'},
                        hm.Models(noset).Size=str2double(txt{i+1});
                    case {'mapsize'},
                        hm.Models(noset).MapSize(1)=str2double(txt{i+1});
                        hm.Models(noset).MapSize(2)=str2double(txt{i+2});
                    case {'xlim'},
                        hm.Models(noset).XLim(1)=str2double(txt{i+1});
                        hm.Models(noset).XLim(2)=str2double(txt{i+2});
                        hm.Models(noset).XLimPlot=hm.Models(noset).XLim;
                    case {'ylim'},
                        hm.Models(noset).YLim(1)=str2double(txt{i+1});
                        hm.Models(noset).YLim(2)=str2double(txt{i+2});
                        hm.Models(noset).YLimPlot=hm.Models(noset).YLim;
                    case {'xlimplot'},
                        hm.Models(noset).XLimPlot(1)=str2double(txt{i+1});
                        hm.Models(noset).XLimPlot(2)=str2double(txt{i+2});
                    case {'ylimplot'},
                        hm.Models(noset).YLimPlot(1)=str2double(txt{i+1});
                        hm.Models(noset).YLimPlot(2)=str2double(txt{i+2});
                    case {'xtick'},
                        hm.Models(noset).XTick=str2double(txt{i+1});
                    case {'ytick'},
                        hm.Models(noset).YTick=str2double(txt{i+1});
                    case {'priority'},
                        hm.Models(noset).Priority=str2double(txt{i+1});
                    case {'flownested','nested'},
                        hm.Models(noset).FlowNestModel=txt{i+1};
                        hm.Models(noset).FlowNested=1;
                    case {'wavenested'},
                        hm.Models(noset).WaveNestModel=txt{i+1};
                        hm.Models(noset).WaveNested=1;
                    case {'flowspinup'},
                        hm.Models(noset).FlowSpinUp=str2double(txt{i+1});
                    case {'wavespinup'},
                        hm.Models(noset).WaveSpinUp=str2double(txt{i+1});
                    case {'runtime'},
                        hm.Models(noset).RunTime=str2double(txt{i+1});
                    case {'timestep'},
                        hm.Models(noset).TimeStep=str2double(txt{i+1});
                    case {'maptimestep'},
                        hm.Models(noset).MapTimeStep=str2double(txt{i+1});
                    case {'histimestep'},
                        hm.Models(noset).HisTimeStep=str2double(txt{i+1});
                    case {'comtimestep'},
                        hm.Models(noset).ComTimeStep=str2double(txt{i+1});
                    case {'usemeteo','meteo'}
                        hm.Models(noset).UseMeteo=txt{i+1};
                    case {'morfac'},
                        hm.Models(noset).MorFac=str2double(txt{i+1});
                    case {'prcorr'},
                        hm.Models(noset).PrCorr=str2double(txt{i+1});
                    case {'station'}
                        nostat=nostat+1;
                        hm.Models(noset).NrStations=nostat;
                        hm.Models(noset).Stations(nostat).Name2=txt{i+1};
                        hm.Models(noset).Stations(nostat).Location=[];
                        hm.Models(noset).Stations(nostat).M=[];
                        hm.Models(noset).Stations(nostat).N=[];
                        hm.Models(noset).Stations(nostat).WaveM=[];
                        hm.Models(noset).Stations(nostat).WaveN=[];
                        hm.Models(noset).Stations(nostat).Type='undefined';
                        nopar=0;
                        for nn=1:hm.NrParameters
                            hm.Models(noset).Stations(nostat).Parameters(nn).PlotCmp=0;
                            hm.Models(noset).Stations(nostat).Parameters(nn).PlotObs=0;
                            hm.Models(noset).Stations(nostat).Parameters(nn).PlotPrd=0;
                            hm.Models(noset).Stations(nostat).Parameters(nn).ObsCode='none';
                            hm.Models(noset).Stations(nostat).Parameters(nn).PrdCode='none';
                        end
                    case {'stabbr'},
                        hm.Models(noset).Stations(nostat).Name1=txt{i+1};
                    case {'sttype'},
                        hm.Models(noset).Stations(nostat).Type=txt{i+1};
                    case {'stlocation'},
                        hm.Models(noset).Stations(nostat).Location(1)=str2double(txt{i+1});
                        hm.Models(noset).Stations(nostat).Location(2)=str2double(txt{i+2});
                    case {'stmn'},
                        hm.Models(noset).Stations(nostat).M=str2double(txt{i+1});
                        hm.Models(noset).Stations(nostat).N=str2double(txt{i+2});
                    case {'stwavemn'},
                        hm.Models(noset).Stations(nostat).WaveM=str2double(txt{i+1});
                        hm.Models(noset).Stations(nostat).WaveN=str2double(txt{i+2});
                    case {'parameter'}
                        nopar=findstrinstruct(hm.Parameters,'Name',txt{i+1});
                        if isempty(nopar)
                            nopar=hm.NrParameters+1;
                        end
                        hm.Models(noset).Stations(nostat).Parameters(nopar).PlotCmp=0;
                        hm.Models(noset).Stations(nostat).Parameters(nopar).PlotObs=0;
                        hm.Models(noset).Stations(nostat).Parameters(nopar).PlotPrd=0;
                        hm.Models(noset).Stations(nostat).Parameters(nopar).ObsCode='none';
                        hm.Models(noset).Stations(nostat).Parameters(nopar).PrdCode='none';
                    case {'plotcmp'}
                        if strcmpi(txt{i+1},'yes')
                            hm.Models(noset).Stations(nostat).Parameters(nopar).PlotCmp=1;
                        else
                            hm.Models(noset).Stations(nostat).Parameters(nopar).PlotCmp=0;
                        end
                    case {'plotobs'}
                        if strcmpi(txt{i+1},'yes')
                            hm.Models(noset).Stations(nostat).Parameters(nopar).PlotObs=1;
                        else
                            hm.Models(noset).Stations(nostat).Parameters(nopar).PlotObs=0;
                        end
                    case {'obscode'}
                        hm.Models(noset).Stations(nostat).Parameters(nopar).ObsCode=txt{i+1};
                    case {'plotprd'}
                        if strcmpi(txt{i+1},'yes')
                            hm.Models(noset).Stations(nostat).Parameters(nopar).PlotPrd=1;
                        else
                            hm.Models(noset).Stations(nostat).Parameters(nopar).PlotPrd=0;
                        end
                    case {'prdcode'}
                        hm.Models(noset).Stations(nostat).Parameters(nopar).PrdCode=txt{i+1};
                    case {'area'}
                        hm.Models(noset).NrAreas=hm.Models(noset).NrAreas+1;
                        ii=hm.Models(noset).NrAreas;
                        hm.Models(noset).Area(ii).Name=txt{i+1};
                    case {'areaabbr'},
                        ii=hm.Models(noset).NrAreas;
                        hm.Models(noset).Area(ii).Abbr=txt{i+1};
                    case {'areaxlim'},
                        ii=hm.Models(noset).NrAreas;
                        hm.Models(noset).Area(ii).XLim(1)=str2double(txt{i+1});
                        hm.Models(noset).Area(ii).XLim(2)=str2double(txt{i+2});
                    case {'areaylim'},
                        ii=hm.Models(noset).NrAreas;
                        hm.Models(noset).Area(ii).YLim(1)=str2double(txt{i+1});
                        hm.Models(noset).Area(ii).YLim(2)=str2double(txt{i+2});
                    case {'areaplotwl'},
                        ii=hm.Models(noset).NrAreas;
                        if strcmpi(txt{i+1},'yes')
                            hm.Models(noset).Area(ii).PlotWL=1;
                        else
                            hm.Models(noset).Area(ii).PlotWL=1;
                        end
                    case {'areaplotvel'},
                        ii=hm.Models(noset).NrAreas;
                        if strcmpi(txt{i+1},'yes')
                            hm.Models(noset).Area(ii).PlotVel=1;
                        else
                            hm.Models(noset).Area(ii).PlotVel=1;
                        end
                    case {'areaplotvelmag'},
                        ii=hm.Models(noset).NrAreas;
                        if strcmpi(txt{i+1},'yes')
                            hm.Models(noset).Area(ii).PlotVelMag=1;
                        else
                            hm.Models(noset).Area(ii).PlotVelMag=1;
                        end
                    case {'areaploths'},
                        ii=hm.Models(noset).NrAreas;
                        if strcmpi(txt{i+1},'yes')
                            hm.Models(noset).Area(ii).PlotHs=1;
                        else
                            hm.Models(noset).Area(ii).PlotHs=1;
                        end
                    case {'areaplottp'},
                        ii=hm.Models(noset).NrAreas;
                        if strcmpi(txt{i+1},'yes')
                            hm.Models(noset).Area(ii).PlotTp=1;
                        else
                            hm.Models(noset).Area(ii).PlotTp=1;
                        end
                    case {'xbprofile'}
                        nrprofiles=nrprofiles+1;
                        hm.Models(noset).NrProfiles=nrprofiles;
                        hm.Models(noset).Profile(nrprofiles).Name=txt{i+1};
                    case {'location'},
                        hm.Models(noset).Profile(nrprofiles).Location(1)=str2double(txt{i+1});
                        hm.Models(noset).Profile(nrprofiles).Location(2)=str2double(txt{i+2});
                    case {'origin'},
                        hm.Models(noset).Profile(nrprofiles).Origin(1)=str2double(txt{i+1});
                        hm.Models(noset).Profile(nrprofiles).Origin(2)=str2double(txt{i+2});
                    case {'alpha'},
                        hm.Models(noset).Profile(nrprofiles).Alpha=str2double(txt{i+1});
                end
            end
        end
    end
end

hm.NrModels=noset;

for i=1:hm.NrModels
    hm.ModelNames{i}=hm.Models(i).LongName;
    hm.ModelAbbrs{i}=hm.Models(i).Name;
end

for i=1:hm.NrModels
    if hm.Models(i).FlowNested
        fnest=hm.Models(i).FlowNestModel;
        mm=findstrinstruct(hm.Models,'Name',fnest);
        hm.Models(i).FlowNestModelNr=mm;
        n=length(hm.Models(mm).NestedFlowModels);
        hm.Models(mm).NestedFlowModels(n+1)=i;
    end
    if hm.Models(i).WaveNested
        fnest=hm.Models(i).WaveNestModel;
        mm=findstrinstruct(hm.Models,'Name',fnest);
        hm.Models(i).WaveNestModelNr=mm;
        n=length(hm.Models(mm).NestedWaveModels);
        hm.Models(mm).NestedWaveModels(n+1)=i;
    end
end


