function varargout = udunits2datenum(varargin)
%UDUNITS2DATENUM   converts date(s) in ISO 8601 units to Matlab datenumber(s)
%
%    datenumbers = udunits2datenum(time,isounits)
%    datenumbers = udunits2datenum(timestring)
%
% Examples (N.B. vectorized):
%
%    [datenum,<zone>] = udunits2datenum( [602218 648857], 'days since 0000-0-0 00:00:00 +01:00')
%    [datenum,<zone>] = udunits2datenum( [602218 648857],{'days since 0000-0-0 00:00:00 +01:00',...
%                                                         'days since 0000-0-0 00:00:00 +01:00'})
%    [datenum,<zone>] = udunits2datenum({'602218           days since 0000-0-0 00:00:00 +01:00',...
%                                        '648857           days since 0000-0-0 00:00:00 +01:00'})
%    [~      ,<zone>] = udunits2datenum(                  'days since 0000-0-0 00:00:00 +01:00')
%
% where <zone> is optional and has the length of isounits.
%
%See web: <a href="http://www.unidata.ucar.edu/software/udunits/">http://www.unidata.ucar.edu/software/udunits/</a>
%See also: NC_CF_time, DATENUM, DATESTR, ISO2DATENUM, TIME2DATENUM, XLSDATE2DATENUM

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

%% Handle input

   if     nargin==1
      if     iscell(varargin{1});celltime =         varargin{1};
      elseif ischar(varargin{1});celltime = cellstr(varargin{1});
      end

      for irow=1:length(celltime)
      ind = strfind(celltime{irow},'since');
     [a,b] = strtok(celltime{irow}(1:ind-1)); % a can be missing
      if isempty(strtrim(b))
         b = a;
         a = '';
      end
      time{irow}     = a;
      isounits{irow} = [b ' ' celltime{irow}(ind:end)];
      end
      time = str2num(char(time));
      time = double(time(:)');% to prevent erroneous roundoff
      
   elseif nargin==2
      time      = double(varargin{1}); % to prevent erroneous roundoff
      isounits  = cellstr(varargin{2});
   end   
   
%% Interpret unit and reference date string

      refdatenum = repmat(nan,[1 length(isounits)]);
   for irow=1:length(isounits)
      rest              = isounits{irow};
     [units{irow},rest] = strtok(rest);
     [dummy      ,rest] = strtok(rest);
     [refdatenum(irow),...
      zone{irow}]       = iso2datenum(rest);
   end

   if length(time) >1 & length(isounits)==1
      datenumbers = time.*convert_units(units{1},'day') + refdatenum;
   else
      %% create matrix of factors to have a factorized multiplication below
      unitfactor = repmat(nan,size(time));
      for irow=1:length(time)
         unitfactor(irow) = convert_units(units{irow},'day');
      end
      datenumbers = time.*unitfactor + refdatenum;
   end
   
%% Output

   if     nargout<2
      varargout = {datenumbers};
   elseif nargout==2
      varargout = {datenumbers,strtrim(zone)};
   else
      error('to much output parameters')
   end

   
%% EOF   