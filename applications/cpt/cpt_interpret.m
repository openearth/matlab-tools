function [type,typeName,OPT] = cpt_interpret(qt,Rf,varargin)
%CPT_INTERPRET  get soil types from a cone penetration test
%
%   Simplified interpretation of cone penetration tests (cpt's) based on
%   Guide to Cone Penetration Testing for Geotechnical Engineering, 
%   P. K. Robertson and K.L. Cabal (Robertson) 3rd Edition January 2009.
%   Currently only the soil behavior type (SBT is determined by use of the
%   CPT Soil Behavior Type (SBT) chart (Robertson et al., 1986).
%
%    "The most commonly used CPT soil behavior type chart was suggested by
%     Robertson et al. (1986) and is shown in Figure 15. This chart uses the basic
%     CPT parameters of cone resistance, qt and friction ratio, Rf. The chart is
%     global in nature and can provide reasonable predictions of soil behavior type
%     for CPT soundings up to about 60ft (20m) in depth. The chart identifies
%     general trends in ground response, such as, increasing relative density (Dr)
%     for sandy soils, increasing stress history (OCR), soil sensitivity (St) and void
%     ratio (e) for cohesive soils. Overlap in some zones should be expected and
%     the zones should be adjusted somewhat based on local experience."
%
%   (Guide to Cone Penetration Testing for Geotechnical Engineering)

%   Syntax:
%   cpt_interpret
%
%   Input:
%       Rf = Friction Ratio
%             The ratio, expressed as a percentage, of the sleeve friction, fs, to the
%             cone resistance, qt, both measured at the same depth.
%             Rf = (fs/qt) x 100%
%       qt = Cone resistance
%
%   Example
%   qt = [linspace(0.1,10,50) linspace(10,100,50)];
%   Rf = linspace(0,8,100);
%   cpt_interpret(qt,fr,'plot',true)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       tda
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 19 Apr 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% set defaults
OPT.plot = false; % shows the result on the SBT chart
  
if nargin==0
    return
end

OPT = setproperty(OPT, varargin{:});
%% map input to image
X        = imread('cpt_sbt_colors.png');
qt0      = round(max(min((2-log10(qt))*200,600),1));
Rf0      = round(max(min(Rf*100,800),1));
type     = X(sub2ind(size(X),qt0,Rf0));
typeName = {...
    'Sensitive fine grained',...
    'Organic material',...
    'Clay',...
    'Silty Clay to clay',...
    'Clayey silt to silty clay',...
    'Sandy silt to clayey silt',...
    'Silty sand to sandy silt',...
    'Sand to silty sand',...
    'Sand',...
    'Gravelly sand to sand',...
    'Very stiff fine grained*',...
    'Sand to clayey sand*'};


%% optional: make a plot
if OPT.plot
    image(imread('cpt_sbt_image.png'));
    xlabel('friction ratio (%)')
    ylabel('Cone resistance q_t (MPa)')
    set(gca,'YTick',[1 200 400 600])
    set(gca,'YTickLabel',{'100','10','1','0.1'})
    set(gca,'XTick',[1 100:100:800])
    set(gca,'xTickLabel',{'0','1','2','3','4','5','6','7','8'})
    hold on

    colormap(prism(12))
    plot(Rf0,qt0,'*k',Rf0,qt0,'ko')
    plotc(Rf0,qt0,type)
    hold off
end