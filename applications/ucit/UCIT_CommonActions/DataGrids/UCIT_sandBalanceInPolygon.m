function UCIT_sandBalanceInPolygon
%UCIT_SANDBALANCEINPOLYGON   computes sediment volume change for a given polygon and settings
%
%   syntax:
%       UCIT_sandBalanceInPolygon
%
%   input:
%       function has no input
%
%   output:
%       function has no output
%
%   See also UCIT_findCoverage, UCIT_plotDataInPolygon, grid_orth_getDataInPolygon

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%
%       Ben de Sonneville
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

warningstate = warning;
warning off

datatype = UCIT_getInfoFromPopup('GridsDatatype');

%% Select in either grid plot or grid overview plot

   mapW = findobj('tag','gridPlot');
   
   if isempty(mapW)
       if isempty(findobj('tag','gridOverview')) || ~any(ismember(get(axes, 'tag'), {datatype}))
           fh = UCIT_plotGridOverview(datatype,'refreshonly',1);
       else
           fh = figure(findobj('tag','gridOverview'));figure(fh);
       end
   else
       fh = figure(findobj('tag','gridPlot')); figure(fh);
   end

   curdir=pwd;

%% make folder for results

   dname = uigetdir(curdir,'Select folder to store data');cd(dname);
   mkdir(['polygons']);

%% Specify polygon

   figure(fh);
   
   if nargin == 0
       figure(fh);
       [xv,yv] = polydraw;
       polygon=[xv' yv'];
   else
       load(polygonname)
   end

%% get other input

   prompt    = {'Polygon name','Minimal coverage [%]','First year','Last year','Search window [months]'};
   dlg_title = 'Input for sand balance';
   num_lines = 1;
   def       = {'Polygon','10','2000','2004',UCIT_getInfoFromPopup('GridsInterval')};
   answer    = inputdlg(prompt,dlg_title,num_lines,def);
   
   save(['polygons\' answer{1},'.mat'],'polygon')

%% arrange input in OPT structure

   OPT.datatype        = datatype;
   OPT.thinning        =  str2double(UCIT_getInfoFromPopup('GridsSoundingID'));
   OPT.timewindow      =  str2double(answer{5});
   OPT.inputyears      = [str2double(answer{3}) : str2double(answer{4})];
   OPT.min_coverage    =  str2double(answer{2});

%% delete previous data

   delete(['results\timewindow = '   answer{5} '\ref='  answer{2} '\*.*'])
   delete(['coverage\timewindow = '  answer{5} '\*.*'])
   delete(['datafiles\timewindow = ' answer{5} '\*.*'])

%% get sandbalance

   UCIT_getSandBalance(OPT)
   
warning(warningstate)

%% EOF   