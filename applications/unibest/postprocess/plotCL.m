function plotCL(input)
%plotCL.m : Plots CL-run output
%
%   Syntax:
%     function plotCL(input)
% 
%   Input:
%     input         structure with information on the model results file and plotting formats
%                    .test_id     run name (used for name of plotted graph)
%                    .output_dir  output directory for plots
%                    .dir         directory with files
%                    .file        PRN file
%                    .reffile     reference PRN-file
%                    .time1       moment(s) in time to plot
%                    .type        type of plot ('coastline' or 'transport')
%                    .fignum      figure number
%  
%   Output:
%     graph with coastline positions or transports
%
%   Example:
%     input.test_id='DEF';
%     input.dir=pwd;
%     input.file='file1.PRN';
%     input.reffile='file2.PRN';
%     input.time1=0.5;
%     input.type='transport';
%     input.fignum=1;
%     input.output_dir='';
%     plotCL(input);
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: plotCL.m 3495 2013-02-06 14:14:12Z huism_b $
% $Date: 2013-02-06 15:14:12 +0100 (Wed, 06 Feb 2013) $
% $Author: huism_b $
% $Revision: 3495 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/postprocess/plotCL.m $
% $Keywords: $


color = [{'b'},{'r'}];
markers1 = {'.','none'};
markers2 = {'s','+'};
linewidth = [4,2.5];
fontsize = 12;

addpath(genpath(input.dir));
close all;

f = figure(1);clf;set(gcf,'Position',[60 300 1000 300]);set(gcf,'Color',[1 1 1]);hold off;
set(gcf,'PaperSize',[9.8925    3.4973],'PaperPosition',[0 0 9.8925    3.4973],'PaperUnits','centimeters','PaperType','A4','PaperPositionMode','manual'); % made size three times smaller than 29.6774 10.492, since scaling is otherwise too small


%% PLOT FIGURE
h1 = gca;hold on;
curaxis                  = gca;
reffile                  = input.reffile;
settings.subfig          = 1;
settings.year            = input.time1;
settings.color           = 'b';
settings.marker          = 'none';
settings.curaxis         = curaxis;
settings.orientation     = 'hor';
settings.xlab            = 'Alongshore distance (km) \rightarrow';
settings.ylab            = '';
settings.offsety         = 100;
settings.fontsize        = 12;
settings.linewidth       = 4;
settings.linestyle       = '-';
settings.axcolor         = [0.2 0.2 0.2];
settings.backgroundcolor = [1 1 1];
if isfield(input,'xlim'); settings.xlim=input.xlim; end
if isfield(input,'ylim'); settings.ylim=input.ylim; end
if  ~isempty(findstr(lower(input.type),'coast')) || ~isempty(findstr(lower(input.type),'cst'))
    settings.title   = ['Coastline position w.r.t. initial situation [m]'];
    hline(1)         = UBlineplot(reffile,settings);hold on;
    settings.color   = 'r';
    settings.marker  = 'none';
    settings.linestyle  = '--';
    hline(2)         = UBlineplot(input.file,settings);
else
    settings.title   = ['Comparison of alongshore sediment transports [\times 10^3 m^3/s]'];
    hline(1)         = UBtransportlineplot(reffile,settings);hold on;
    settings.color   = 'r';
    settings.marker  = 'none';
    settings.linestyle = ':';
    hline(2)         = UBtransportlineplot(input.file,settings);
end

if ~ischar(input.fignum);input.fignum=num2str(input.fignum);end
hleg = legend(hline,{'Reference','Release'},'Location','SouthWest','FontSize',8);
pname = [input.test_id '_fig' input.fignum];
saveplot(gcf, input.output_dir, pname);

close all;
