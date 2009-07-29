function data = pontosdatread(datfilename)
%PONTOSDATREAD reads the input data from a PonTos dat file and puts them
% in a struct (ALPHA RELEASE, UNDER CONSTRUCTION)
%
%   PonTos is an integrated conceptual model for Shore Line Management,
%   developed to assess the long-term and large-scale development
%   of coastal stretches. It is originally based on the multi-layer model
%   that was used to predict the development of the Dutch Wadden coast
%   [Steetzel, 1995].
%
%   The input of the PonTos-model for a specific case is gathered in a
%   file Case.DAT. This is a TEGAGX formatted ASCII file.
%
%   Syntax:
%   data = pontosdatread(datfilename)
%
%   Input:
%   datfilename  = filename of the PonTos dat file (PonTos input)
%
%   Output:
%   data = struct containing PonTos input blocks
%
%   Example
%   datfilename =
%   'l:\A2112\Morfologie\PonTos\Voorbeeld invoer\Run_t_Sch_PBV1n_50.dat';
%   data = pontosdatread(datfilename);
%
%   See also tekal.m from the Delft3D matlab toolbox

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Alkyon Hydraulic Consultancy & Research
%       Bart Grasmeijer
%
%       bart.grasmeijer@alkyon.nl
%
%       P.O. Box 248
%       8300 AE Emmeloord
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Jul 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id: oettemplate.m 688 2009-07-15 11:46:33Z damsma $
% $Date: 2009-07-15 13:46:33 +0200 (Wed, 15 Jul 2009) $
% $Author: damsma $
% $Revision: 688 $
% $HeadURL: https://repos.deltares.nl/repos/OpenEarthTools/trunk/matlab/general/oet_template/oettemplate.m $
% $Keywords: $

%%

FileInfo = tekal('open',datfilename);
data = struct;
for i = 1:length(FileInfo.Field)
    if ~strcmp(FileInfo.Field(i).Name,'CMT')
        data.(FileInfo.Field(i).Name) = tekal('read',FileInfo,i);
    end
end




