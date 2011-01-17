function measDist
%MEASDIST Measure distance in figure
%
% See also: LDBTOOL, DISTANCE, DRAWBAR

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
% pick some boundaries
uo = []; vo = []; button = [];

[uo,vo,lfrt] = ginput(1);
button = lfrt;
hold on; hp = plot(uo,vo,'r+-');

while lfrt == 1&length(uo)<2
    [u,v,lfrt] = ginput(1);
    uo=[uo;u]; vo=[vo;v]; button=[button;lfrt];      
    delete(hp);
    hp = plot(uo,vo,'r+-','linewidth',2);
end

% Bail out at ESCAPE = ascii character 27
if lfrt == 27
    delete(hp)
    return
end

uiwait(msgbox(['Distance is ' num2str(sqrt(diff(uo)^2+diff(vo)^2),'%12.3f')]));

delete(hp);