function varargout = legendxdir(varargin)
%legendxdir  Changes the x-direction of a legend.
%
%   This function has the same functionality as Matlabs' legend. One
%   property value pair is added to change the direction of the x axis.
%   This switches the text and line objects in horizontal direction.
%
%   Syntax:
%   legendxdir(legh);
%   legendxdir(...,'xdir','reverse');
%   legendxdir(...,'xdir','normal');
%   [legh,objh,outh,outm] = legendxdir(...);
%
%   Input:
%   legh    - Specifying a legend handle as the first input argument forces
%            the function to change the specified legend.
%   'xdir' - The xdir property can have two values:
%                reverse {default}:
%                   places the text objects to the left of the legend and
%                   the lines at the right.
%                normal:
%                   Plots a legend the same as the legend function
%
%   Output:
%   legh - a handle to the legend axes
%   objh - a vector containing handles for the text, lines, and patches in 
%          the legend
%   outh - a vector of handles to the lines and patches in the plot
%   outm - a cell array containing the text in the legend. 
%
%   Example
%   x = 0:.2:12;
%   plot(x,bessel(1,x),x,bessel(2,x),x,bessel(3,x));
%   legh = legend('First','Second','Third');
%   legendxdir(legh,'xdir','reverse');
%
%   See also legend

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

% Created: 04 Jun 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: legend$

%% Set defaults
xdir = 'reverse';

%% process input
if nargin == 1 && ishandle(varargin{1}) && strcmp(get(varargin{1},'Tag'),'legend')
    % legend handle is given
    leg = varargin{1};
else
    % subtract extra input arguments from varargin
    id = find(strcmpi(varargin,'xdir'));
    if ~isempty(id)
        xdir = varargin{id+1};
        if all(~strcmp(xdir,{'normal','reverse'}))
            error('PlotDuneErosion:WrongProperty','Parameter xdir can only be "normal" or "reverse"');
        end
        varargin(id:id+1) = [];
    end
    % use the remaining input arguments to create a legend with legend
    [leg argsout{1} argsout{2} argsout{3}] = legend(varargin{:});
end

%% construct output
varargout = {leg};
if exist('argsout','var')
    varargout = cat(2,{leg},argsout);
end

%% determine axes direction
olddir = get(leg,'XDir');
samedir = strcmp(olddir,xdir);
if samedir
    % No need to change anything
    return
end

%% set horizontal alignent variable
switch xdir
    case 'normal'
        horalign = 'left';
    case 'reverse'
        horalign = 'right';
end

%% Set the direction of the legend axes
set(leg,'XDir',xdir);

%% Gather strings handles
strings = findobj(leg,'Type','text');

%% First adjust HorizontalAlignment of the strings
set(strings,'HorizontalAlignment',horalign)

%% Also adjust the position of the strings
for istr = 1:length(strings)
    pos = get(strings(istr),'Position');
    newpos = pos;
    newpos(1) = 1-pos(1);
    set(strings(istr),'Position',newpos);
end

%% done...
