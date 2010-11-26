function OK = bct2bca_test()
% BCT2BCA_TEST  test script for BCT2BCA
%
%  using test data in ..\..\..\..\test\
%  
% See also: BCA2BCT, BCT2BCA

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben de Boer + Pieter van Geer
%
%       Gerben.deboer@deltares.nl + pieter.vangeer@deltares.nl
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
% Created: 22 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.DataAccess;

%% define

   OPT.components  = {'S2','S4'};

   OPT.bcafile     = ['bct2bca.bca']; % to generate
   OPT.bctfile     = ['bct2bca.bct']; % generated offline with bca2bct_test and renamed
   OPT.bndfile     = ['bca2bct.bnd']; % same 
   OPT.period      = datenum(2010,06,01,0,0:1:24*60,0);
   OPT.latitude    = nan; % avoid nodal factors for test


   OPT.plot        = 0;
   OPT.pause       = 1;
   OPT.output      = 'none';
   OPT.residue     = ['bct2bca_res.bct'];
   OPT.prediction  = ['bct2bca_pred.bct'];

%% run

   BCA = bct2bca(OPT);

%% check

OK = all((BCA.DATA(1).amp - [  1   0]') < 5e-2 & ...
         (BCA.DATA(2).amp - [  0   1]') < 5e-2 & ...
         (BCA.DATA(1).phi - [360 Inf]') < 5e-2 & ... % the phi at zero amp means nothing
         (BCA.DATA(2).phi - [Inf 180]') < 5e-2);     % the phi at zero amp means nothing
