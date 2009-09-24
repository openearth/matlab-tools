function [fractions, data, data_info, data_units] = TASS_readDynamic_in(varargin)
% TASS_READDYNAMIC_IN  Routine to read the dynamic plume input file
%
%   Routine reads a dynamic plume input file (*.in) produced by TASS model.
%   The routine takes a filename as an input file. Output produced is an
%   array with data and a variable with column info and
%   units.
%
%   Syntax:
%       [data, data_info, data_units] = TASS_readDynamic_in(varargin)
%
%   Input:
%   For the following keywords, values are accepted (values indicated are the current default settings):
%       'filename', []                  = passive plume output filename
%
%   Output:
%       data                            = 6 column array with output data
%       data_info                       = cell array with column information
%       data_units                      = cell array with column units
%
% See also TASS_readPassive_out

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 22 Feb 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: 


%% defaults
OPT = struct( ...
    'filename', 'd:\Documents and Settings\mrv\VanOord\Projecten\96.8015 TASS P15 Slibpluimmeting\Software\ExampleData\oranje5.in' ...
    );

%% overrule default settings by property pairs, given in varargin
OPT = setProperty(OPT, varargin{:});

if isempty(OPT.filename)
    disp('Error: Input file needed')
    return
end

disp(['Processing: ' OPT.filename])

%% read some basic info from the output file
% skip the first 22 lines
fid = fopen(OPT.filename);
for i = 1:2
    fgetl(fid);
end

% read in the data
nr_fractions = str2double(fgetl(fid));
for i = 1:nr_fractions
    fractions(i) = str2double(fgetl(fid)); %#ok<AGROW>
end

data = fscanf(fid,'%f %f %f %f %f %f %f %f',[8 inf]);

% flip the matrix to get nice column structure
data = data';

% provide info and units
data_info  = {'Time', 'Loss for fraction', 'Loss for fraction', 'Loss for fraction', 'Loss for fraction', 'Loss for fraction', 'Loss for fraction'};
data_units = {'mins', 'kg/s', 'kg/s', 'kg/s', 'kg/s', 'kg/s', 'kg/s'};

if dbstop
    figure(1); clf; hold on
    for i = 2:8 
        plot(data(:,1),data(:,i));
    end
end