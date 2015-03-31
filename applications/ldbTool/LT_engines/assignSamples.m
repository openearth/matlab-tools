function assignSamples(x,y,zValue,dist,fileName);
%ASSIGNSAMPLES Assign samples to a line
%
% This tool assigns samples along a line at specified distances from each
% other and saves the samples to xyz-file.
%
% Syntax:
% assignSamples(x,y,zValue,dist,fileName)
%
% x:        x-coordinates of the line
% y:        y-coordinates of the line
% zValue:   z value of the samples to assign
% dist:     resolution of the output samples (distance between them)
% fileName: name of the output sample file
%
% See also: LDBTOOL

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Code
xi=[x(1)];
yi=[y(1)];

distance=sqrt((x(2:end)-x(1:end-1)).^2+(y(2:end)-y(1:end-1)).^2);
for ii=1:length(distance)
    steps=distance(ii)/dist-1;
    if round(steps)>=1
        xi=[xi ; repmat(nan,round(steps),1)];
        yi=[yi ; repmat(nan,round(steps),1)];
    end
    xi=[xi ; x(ii+1)];
    yi=[yi ; y(ii+1)];
end

if ~isempty(which('inpaint_nans'))
    xi=inpaint_nans(xi,2);
    yi=inpaint_nans(yi,2);
else
    xi=inpaintn(xi);
    yi=inpaintn(yi);
end    

xyz=[];

try
    [xyz]=samples('read',fileName);
end

xyz=[xyz;[xi yi repmat(zValue,size(xi))]];

samples('write',fileName,xyz);