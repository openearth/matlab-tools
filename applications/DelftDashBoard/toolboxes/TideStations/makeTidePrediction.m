function wl = makeTidePrediction(tim, components, amplitudes, phases, latitude, varargin)
%MAKETIDEPREDICTION  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   wl = makeTidePrediction(tim, components, amplitudes, phases, latitude, varargin)
%
%   Input:
%   tim        =
%   components =
%   amplitudes =
%   phases     =
%   latitude   =
%   varargin   =
%
%   Output:
%   wl         =
%
%   Example
%   makeTidePrediction
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
timeZone=0;
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'timezone'}
                timeZone=varargin{i+1};
        end
    end
end

const=t_getconsts;
k=0;
for i=1:length(amplitudes)
    cmp=components{i};
    cmp = delft3d_name2t_tide(cmp);
    if length(cmp)>4
        cmp=cmp(1:4);
    end
    name=[cmp repmat(' ',1,4-length(cmp))];
    ju=strmatch(name,const.name);
    if isempty(ju)
        disp(['Could not find ' name ' - Component skipped.']);
    else
        %         switch lower(cmp)
        %             case{'m2','s2','k2','n2','k1','o1','p1','q1','mf','mm','m4','ms4','mn4'}
        k=k+1;
        names(k,:)=name;
        freq(k,1)=const.freq(ju);
        tidecon(k,1)=amplitudes(i);
        tidecon(k,2)=0;
        % convert time zone
        if timeZone~=0
            phases(i)=phases(i)+360*timeZone*const.freq(ju);
            phases(i)=mod(phases(i),360);
        end
        tidecon(k,3)=phases(i);
        tidecon(k,4)=0;
    end
    %     end
end
wl=t_predic(tim,names,freq,tidecon,latitude);

