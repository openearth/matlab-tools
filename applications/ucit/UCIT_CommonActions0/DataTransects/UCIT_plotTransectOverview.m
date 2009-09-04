function UCIT_displayTransectOutlines
%PLOTTRANSECTOVERVIEW   this routine displays all transect outlines
%
% This routine displays all transect outlines.
%              
% input:       
%    function has no input
%
% output:       
%    function has no output
%
% see also ucit, plotDotsInPolygon 

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

%% check popups to see if this option is valid
[check]=UCIT_checkPopups(1, 4);
if check == 0
    return
end

%% get metadata (either from the console or the database)
tic
disp('getting metadata...');
[d] = UCIT_getMetaData;
toc

%% now plot the transectcontours gathered in d

UCIT_plotFilteredTransectContours(d);

