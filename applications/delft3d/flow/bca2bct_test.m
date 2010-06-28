function bca2bct_test()
% BCA2BCT_TEST  test script for bca2bct
%  
% %See also: BCA2BCT, BCT2BCA
%
%
%   See also 

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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 11 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

H.period      = datenum(1999,05,06,0,[180:60:206040],0);
H.refdate     = datenum(1999,05,06);
H.latitude    = 52;

H.ncomponents = 35; % CHECK BCA FILE MANUALLY
bca2bct(['.\bct2bca_test\bct2bca_',         num2str(H.latitude),'noa0.bca'],...
['.\bct2bca_test\TMP_cas_t_predic_',num2str(H.latitude),'noa0.bct'],...
'.\bct2bca_test\bca.bnd',H.period,...
H.ncomponents,...
H.refdate,'latitude',H.latitude);

H.ncomponents = 36; % CHECK BCA FILE MANUALLY
bca2bct(['.\bct2bca_test\bct2bca_',         num2str(H.latitude),'.bca'],...
['.\bct2bca_test\TMP_cas_t_predic_',num2str(H.latitude),'.bct'],...
'.\bct2bca_test\bca.bnd',H.period,...
H.ncomponents,...
H.refdate,'latitude',H.latitude);