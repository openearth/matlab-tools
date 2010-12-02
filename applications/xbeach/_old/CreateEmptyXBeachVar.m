function [XB Precision] = CreateEmptyXBeachVar(varargin)
%CREATEEMPTYXBEACHVAR  replaced by "xb_create_var"
%
% The variable contains three main fields:
%   - settings :    In which calculation settings as well as output
%               settings can be specified.
%   - Input :       This contains input like the initial profile, Hs, Tp,
%               grid specification, start and stop times etc.
%   - Output :      In which calculation results can be stored.
%   By use of PropertyName-PropertyValue pairs, the various elements of
%   settings and Input can be set.
%
%   Example
%   createEmptyXBeachVar
%
%   See also XB_run XBeach_Write_Inp XB_Read_Results

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer / Kees den Heijer
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

% Created: 04 Feb 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%%
warning(['"' mfilename '" is replaced by "xb_create_var" and will be deleted.'])

[XB Precision] = xb_create_var(varargin{:});