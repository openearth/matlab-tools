function XB = XBeach_Write_Inp(calcdir, XB, varargin)
%XBEACH_WRITE_INP  replaced by "xb_write_input"
%
% Routine writes an input file params.txt containing the information
% available in the XBeach communication structure XB.
%
% Input:
% calcdir = target directory to put the input file in
% XB      = XBeach communication structure
%
% Output:
% XB      = XBeach communication structure (contains the information as it
% is actually written to the inputfile (is relevant when values are rounded
% in the inputfile)
%
% See also CreateEmptyXBeachVar XBeach_Write_Inp XB_Read_Results

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Pieter van Geer
%
%       Pieter.vanGeer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:

%%
warning(['"' mfilename '" is replaced by "xb_write_input" and will be deleted.'])

XB = xb_write_input(calcdir, XB, varargin{:});