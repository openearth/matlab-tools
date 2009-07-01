function standard_name = odvname2standard_name(varargin)
%ODVNAME2STANDARD_NAME   convert between ODV substance name and CF standard_name
%
%   standard_names = odvname2standard_name(ODVcodes)
%
% Note : vectorized for codes, e.g.: odvname2standard_name({'T90','Salinity'})
%
% Examples:
%
%   odvname2standard_name('T90') % gives 'sea_water_temperature'
%
% Note: calling ODVNAME2STANDARD_NAME numerous times is rather slow.
%
%See web: IDsW, CF standard_name table, www.waterbase.nl/metis
%See also: OceanDataView, DONARNAME2STANDARD_NAME

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

   OPT.xlsfile = [filepathstr(mfilename('fullpath')),filesep,'odvname2standard_name.xls'];
   DAT         = xls2struct(OPT.xlsfile);
   codes       = varargin{1};
   if ischar(codes)
      codes = cellstr(codes);
   end
   
   for icode=1:length(codes)
      code                 = codes(icode);
      index                = strmatch(upper(code),upper(DAT.ODV_name));
      standard_name{icode} = DAT.standard_name{index};
   end
   
   %% Return character instead of cell if input is a single character
   if length(codes)==1 & ischar(varargin{1})
      standard_name = char(standard_name);
   end

%% EOF   