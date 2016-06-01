function boundaries = ddb_DFlowFM_initializeBoundary(boundaries,x,y,name,ib,t0,t1)
%ddb_DFlowFM_initializeBoundary  One line description goes here.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
boundaries(ib).filename=[name '.pli'];
boundaries(ib).name=name;
boundaries(ib).type='waterlevelbnd';
boundaries(ib).handle=NaN;

for ip=1:length(x)

    boundaries(ib).x(ip)=x(ip);
    boundaries(ib).y(ip)=y(ip);
    
    % Astro
    boundaries(ib).nodes(ip).astronomiccomponents(1).component='M2';
    boundaries(ib).nodes(ip).astronomiccomponents(1).amplitude=0.0;
    boundaries(ib).nodes(ip).astronomiccomponents(1).phase=0.0;
    
    % Harmo
    boundaries(ib).nodes(ip).harmoniccomponents(1).component=725;
    boundaries(ib).nodes(ip).harmoniccomponents(1).amplitude=0.0;
    boundaries(ib).nodes(ip).harmoniccomponents(1).phase=0.0;
    
    % Time series
    boundaries(ib).nodes(ip).timeseries.time=[t0 t1];
    boundaries(ib).nodes(ip).timeseries.value=[0 0];

    boundaries(ib).nodes(ip).cmp=1;
    boundaries(ib).nodes(ip).tim=0;
    boundaries(ib).nodes(ip).cmptype='astronomic';
    
    boundaries(ib).nodes(ip).cmpfile        = [boundaries(ib).name '_' num2str(ip,'%0.4i')];
    boundaries(ib).nodes(ip).bc.function    = [boundaries(ib).name '_' num2str(ip,'%0.4i')];
    boundaries(ib).nodes(ip).bc.Quantity1   = 'astronomic';
    boundaries(ib).nodes(ip).bc.Unit1       = 'astronomic component';
    boundaries(ib).nodes(ip).bc.Quantity2   = '-';
    boundaries(ib).nodes(ip).bc.Unit2       = 'boundaries(ib).type';
    boundaries(ib).nodes(ip).bc.Quantity3   = 'm';
    boundaries(ib).nodes(ip).bc.Unit3       = '';
    
    boundaries(ib).cmpfile{ip}=[boundaries(ib).name '_' num2str(ip,'%0.4i')];
    boundaries(ib).activenode=1;
    boundaries(ib).nodenames{ip}=num2str(ip);

end
