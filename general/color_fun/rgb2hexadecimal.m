function hex = rgb2hexadecimal(rgb)
%RGB2HEXADECIMAL  Converts rgb color codes to hexadecimal color codes.
%
%   Matlab works with normalized rgb color codes. Often hexadecimal 
%   notation is used (for example in html or in Goggle Earth). This
%   function converts rgb colors (both normalized and ranging from 1 to 256)
%   to hexadecimal notation.
%
%   Syntax:
%   hex = rgb2hexadecimal(rgb)
%
%   Input:
%   rgb = rgb color specification. This is typically a 1x3 numerical array
%           with numbers (0-1 or 1-256) indicating the red (first column),
%           green (second column) and blue (third column) colors (also: 
%           [R G B] in which R = Red color, G = Green color and B = blue 
%           color). If also transparancy should be expressed in the 
%           hexadecimal notation four columns should be used [T R G B] 
%           (in which T = transparancy).
%
%   Output:
%   hex = hexadeximal notation. 
%
%   Example
%   % this gives the hexadecimal notation of the color blue:
%   hex = rgb2hexadecimal([0 0 1]);
%
%   % The following code produces the hexadecimal notation of the color red
%   % with a transparancy of 50%:
%   hex = rgb2hexadecimal([0.5 1 0 0]);
%   
%
%   See also rgb2dec rgb2gray rgb2hsv

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 30 Jun 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Create hexadecimal range
% The range consists of the numbers 0 to 9 followed by A, B, C, D, E, F.
seq = cat(1,strread(num2str(0:9),'%s'),{'A','B','C','D','E','F'}');
hexdigit = repmat(seq,length(seq),1);
for i=1:length(hexdigit)
    hexdigit{i} = cat(2,seq{ceil((i/length(hexdigit))*length(seq))},hexdigit{i});
end

%% loop rgb colors
clr = cell(1,length(rgb));
for i=1:length(rgb)
    if rgb(i) <= 1
        % normalized specification (Matlab)
        clr{i} = hexdigit{max([1,round(rgb(i) * length(hexdigit))])};
    else
        % range to 1-256 (often used in many other languages
        clr{i} = hexdigit{round(rgb(i))};
    end
end

%% prepare output
hex = cat(2,clr{:});
