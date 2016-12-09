function AdisPlotND(adisObject, varargin)
%ADISPLOTND  Plots all 2D planes of an N-dimensional ADIS object
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = AdisPlotND(varargin)
%
%   Input: For <keyword,value> pairs call AdisPlotND() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   AdisPlotND
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
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
% Created: 17 Mar 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Settings
OPT = struct(...
    'ColorLimits',      0.2,            ...
    'ULimits',          10,             ...
    'FilterType',       'zero',         ...
    'FigName',          'AdisPlot',     ...
    'PlotARS',          true,           ...
    'PlotBetaSphere',   true,           ...
    'PrintDir',         '',             ...
    'Print',            false);

OPT = setproperty(OPT, varargin{:});

%% Plotting & filtering

NrDimensions    = numel(adisObject.LimitState.RandomVariables);
NrSubplots      = sum(1:(NrDimensions-1));
MSubplots       = ceil(sqrt(NrSubplots));
NSubplots       = floor(sqrt(NrSubplots)); 

DimCombin       = CombineDimensions(NrDimensions);

filter  = FilterPoints(adisObject, OPT);

aH      = NaN(NrSubplots,1);

for iSubplot = 1:NrSubplots
    Dim1            = DimCombin(iSubplot,1);
    Dim2            = DimCombin(iSubplot,2);
    aH(iSubplot)    = subplot(MSubplots, NSubplots, iSubplot);
    AddARS(aH(iSubplot), NrDimensions, Dim1, Dim2, adisObject, OPT)
    hold(aH(iSubplot),'on')
    AdisPlot2DCrossSection(aH(iSubplot), Dim1, Dim2, filter, adisObject, OPT)
    AddBetaSphere(aH(iSubplot), adisObject, OPT)
    hold(aH(iSubplot),'off')
    
    if iSubplot == 1
        title(['P_{f} = ' num2str(adisObject.Pf)])
    end
end

if OPT.Print
    print('-r600', '-dpng', fullfile(OPT.PrintDir,[OPT.FigName '_' OPT.FilterType]))
end

end

function AdisPlot2DCrossSection(axisHandle, Dim1, Dim2, filter, adisObject, OPT)
scatter(axisHandle, adisObject.LimitState.UValues(filter, Dim1), ...
    adisObject.LimitState.UValues(filter, Dim2), ...
    10*ones(size(adisObject.LimitState.UValues(filter,1))), ...
    adisObject.LimitState.ZValues(filter, 1), 'filled', 'MarkerEdgeColor','k')

scatter(0,0,10,'k','+')

xlabel(axisHandle, adisObject.LimitState.RandomVariables(Dim1).Name)
ylabel(axisHandle, adisObject.LimitState.RandomVariables(Dim2).Name)

axis equal
colormap(axisHandle, [cbrewer('seq','Reds',200); flipud(cbrewer('seq','YlOrRd',200))])
caxis(axisHandle, [-OPT.ColorLimits OPT.ColorLimits])
axis(axisHandle, [-OPT.ULimits OPT.ULimits -OPT.ULimits OPT.ULimits])
colorbar
end

function AddARS(axisHandle, nrDimensions, Dim1, Dim2, adisObject, OPT)
if OPT.PlotARS
    if adisObject.LimitState.ResponseSurface.GoodFit
    lim             = linspace(-OPT.ULimits,OPT.ULimits,1000);
    [xGrid, yGrid]  = meshgrid(lim,lim);
    
    dims                = 1:nrDimensions;
    grid                = NaN(length(xGrid(:)),nrDimensions);
    grid(:,Dim1)        = xGrid(:);
    grid(:,Dim2)        = yGrid(:);
    OtherDims           = dims(dims ~= Dim1 & dims ~= Dim2);
    grid(:,OtherDims)   = zeros(length(xGrid(:)),numel(OtherDims));
    zGrid               = reshape(polyvaln(adisObject.LimitState.ResponseSurface.Fit, grid), size(xGrid));
    
    pcolor(axisHandle, xGrid, yGrid, zGrid);
    shading flat
    else
        warning('This response surface does not have a good fit to the data!');
    end
end
end

function AddBetaSphere(axisHandle, adisObject, OPT)
if OPT.PlotBetaSphere
    [xMin, yMin]    = cylinder(adisObject.LimitState.BetaSphere.MinBeta, 100);
    [xMax, yMax]    = cylinder(adisObject.LimitState.BetaSphere.BetaSphereUpperLimit, 100);
    
    plot(axisHandle,xMin(1,:),yMin(1,:),':g');
    plot(axisHandle,xMax(1,:),yMax(1,:),'-g');
end
end

function filter = FilterPoints(adisObject, OPT)
switch OPT.FilterType
    case 'all'
        filter = adisObject.LimitState.EvaluationIsEnabled;
    case 'exact'
        filter = adisObject.LimitState.EvaluationIsExact & adisObject.LimitState.EvaluationIsEnabled;
    case 'approx'
        filter = ~adisObject.LimitState.EvaluationIsExact & adisObject.LimitState.EvaluationIsEnabled;
    case 'zero'
        filter = adisObject.EvaluationApproachesZero & adisObject.LimitState.EvaluationIsEnabled;
    case 'exactzero'
        filter = adisObject.LimitState.EvaluationIsExact & adisObject.EvaluationApproachesZero & adisObject.LimitState.EvaluationIsEnabled;
    otherwise
        error([OPT.FilterType ' is not a valid filter type!'])
end
end

function dimCombin = CombineDimensions(nrDimensions)
v = 1:nrDimensions;
k = 2;
[m, n] = size(v);

if min(m,n) ~= 1
   error(message('stats:combnk:VectorRequired'));
end

if n == 1
   n = m;
   flag = 1;
else
   flag = 0;
end

if n == k
   c = v(:).';
elseif n == k + 1
   tmp = v(:).';
   c   = tmp(ones(n,1),:);
   c(1:n+1:n*n) = [];
   c = reshape(c,n,n-1);
elseif k == 1
   c = v.';
elseif n < 17 && (k > 3 || n-k < 4)
   rows = 2.^(n);
   ncycles = rows;

   for count = 1:n
      settings = (0:1);
      ncycles = ncycles/2;
      nreps = rows./(2*ncycles);
      settings = settings(ones(1,nreps),:);
      settings = settings(:);
      settings = settings(:,ones(1,ncycles));
      x(:,n-count+1) = settings(:);
   end

   idx = x(sum(x,2) == k,:);
   nrows = size(idx,1);
   [rows,ignore] = find(idx');
   c = reshape(v(rows),k,nrows).';
else 
   P = [];
   if flag == 1,
      v = v.';
   end
   if k < n && k > 1
      for idx = 1:n-k+1
         Q = combnk(v(idx+1:n),k-1);
         P = [P; [v(ones(size(Q,1),1),idx) Q]];
      end
   end
   c = P;
end
dimCombin   = flipud(c);
end