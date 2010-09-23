function OK = bca2bct_test()
% BCA2BCT_TEST  test script for bca2bct
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
% Created: 11 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

   MTest.category('DataAccess');

%% define

   OPT.bcafile     = ['bca2bct.bca']; % generated manually
   OPT.bctfile     = ['bca2bct.bct']; % to generate
   OPT.bndfile     = ['bca2bct.bnd'];
   OPT.period      = datenum(2010,06,01,0,0:1:24*60,0);
   OPT.refdate     = datenum(2010,01,01);
   OPT.latitude    = nan; % avoid nodal factors for test
   
   OPT2.plot = 0;
   
   BCT = bca2bct(OPT);

%% run

  %BCT = bct_io('read','bca2bct.bct');
   t   = BCT.Table.Data(:,1);
   T   = [12 6]; % does not work for S1 for some reason.
   S2  = BCT.Table.Data(:,2);
   S2r = cos(2*pi*(t-t(1))/60/T(1)); % reference
   dS2 = S2-S2r;
   
   S1  = BCT.Table.Data(:,3);
   S1r = cos(2*pi*(t-t(1))/60/T(2)-pi); % reference
   dS1 = S1-S1r;

%% plot

   if OPT2.plot
   
      FIG = figure;
    
      % S2
      subplot(2,1,1)
      plot(t,S2,'b.')
      hold on
      plot(t,S2r,'g')
      subplot(2,1,2)
      plot(t,dS2,'r')
      hold on
      
      
      % S1
      subplot(2,1,1)
      plot(t,S1,'b.')
      hold on
      plot(t,S1r,'g')
      subplot(2,1,2)
      plot(t,dS1,'r')
      
      pausedisp
      try;close(FIG);end
   end

%% check

   OK = all(dS2 < .5e-2) & ...
        all(dS1 < .5e-2);
