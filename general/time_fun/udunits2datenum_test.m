function success = udunits2datenum(varargin)
%UDUNITS2DATENUM_TEST   unit test for udunits2datenum
%
%See also: UDUNITS2DATENUM

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

% 2009 jul 09: added option to pass only 1 string argument [GJdB]


   success = 1;

   D0.datenum = [602218 648857];


  [D.datenum,D.zone] = udunits2datenum(D0.datenum, 'days since 0000-0-0 00:00:00 +01:00');
  
   if ~(isequal(D.datenum,D0.datenum) & ...
        isequal(D.zone   ,{'+01:00'}))
      success = 0;
      return
   end
   
  [D.datenum,D.zone] = udunits2datenum(D0.datenum,{'days since 0000-0-0 00:00:00 +01:00',...
                                                   'days since 0000-0-0 00:00:00 +01:00'});
   if ~(isequal(D.datenum,D0.datenum) & ...
        isequal(D.zone   ,{'+01:00','+01:00'}))
      success = 0;
      return
   end

  [D.datenum,D.zone] = udunits2datenum({'602218     days since 0000-0-0 00:00:00 +01:00',...
                                        '648857     days since 0000-0-0 00:00:00 +01:00'});

   if ~(isequal(D.datenum,D0.datenum) & ...
        isequal(D.zone   ,{'+01:00','+01:00'}))
      success = 0;
      return
   end

%% EOF