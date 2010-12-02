function XB = XBeach_1D(varargin)
%XBEACH_1D  replaced by "xb_generate_model_1D"
%
%
%
% syntax:
% XB = XBeach_1D('calcdir', calcdir...
%           'xInitial', xInitial,...
%           'zInitial', zInitial,...
%           'D50', D50,...
%           'WL_t', WL_t,...
%           'Hsig_t', Hsig_t,...
%           'Tp_t', Tp_t,...
%           'T', T,...
%           'morfac', morfac,...
%           'morstart', morstart)
%
% input:
%
% output:
%
% See also

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@deltares.nl	
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
warning(['"' mfilename '" is replaced by "xb_generate_model_1D" and will be deleted.'])

XB = xb_generate_model_1D(varargin{:});