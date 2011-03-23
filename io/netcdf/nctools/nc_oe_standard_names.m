function varargout = nc_oe_standard_names(varargin)
%NC_OE_STANDARD_NAMES  Routine facilitates adding variables that are part of standard-name glossaries
%
%   Routine facilitates adding variables that are part of standard-name glossaries (CF-1.4, OE-1.0, VO-1.0).
%   Works with both the Maltab and SNC netcdf libraries.
%
%   Syntax:
%      nc_oe_standard_names(varargin)
%
%   Example:
%
%      nc_oe_standard_names('outputfile', outputfile, ...
%                           'varname', {'time'}, ...
%                           'oe_standard_name', {'time'}, ...
%                           'dimension', {'time'}, ...
%                           'timezone', '+01:00')
%
%   Standard names supported:
%        (OE-1.0) 'time'
%        (OE-1.0) 'cone_resistance'
%        (OE-1.0) 'sleeve_friction'
%        (OE-1.0) 'pore_pressure'
%
%   See also nc_oe_standard_names_generate

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Van Oord
%       Mark van Koningsveld
%
%       mrv@vanoord.com
%
%       Watermanweg 64
%       POBox 8574
%       3009 AN Rotterdam
%       Netherlands
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

% This tools is part of VOTools which is the internal clone of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 13 Nov 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings
%  defaults
OPT = struct(...
    'nc_library',       'snc', ...                           % snc or matlab 
    'ncid',             '', ...                              % nectdf id (only for matlab library)
    'outputfile',       {[]}, ...                            % name of the nc file. 
    'varname',          {{{'test1'};{'test2'}}}, ...         % variable name
    'oe_standard_name', {{{'test1'};{'test2'}}}, ...         % open earth standard name
    'dimension',        {{{'test1'};{'test2'}}}, ...	     % dimension names					
    'dimid',            [], ...                              % dimension id's for use with matlab nc library only
    ...                                                      %   It is (a little) faster to indicate dimid's than dimension names
    'timezone',         '+01:00' , ...                       % timezone
    'deflate',          false , ...                          % only for netcdf4 files, internally deflates (compresses) variables in NC file
    'additionalAtts',   {[]} ...                             % append these attributes to the default attributes. Must be in form
    );                                                       %    {'name1','name2','name3';'value1','value2','value3'} 

if nargin==0
    varargout = {OPT};
    return
end

% overrule default settings by property pairs, given in varargin

   OPT = setproperty(OPT, varargin{:});

%% check some basic input properties

   if size(OPT.oe_standard_name,1) ~= size(OPT.dimension,1)
       error('nc_oe_standard_names:argChk', 'Input arguments not of equal length')
   end
   
   switch OPT.nc_library
       case 'snc'
           if isempty(OPT.outputfile)
               error('nc_oe_standard_names:outputChk',  'No outputfilename indicated')
           end
       case 'matlab'
           if isempty(OPT.ncid)
               error('nc_oe_standard_names:outputChk',  'No ncid indicated')
           end
       otherwise
           error('nc_oe_standard_names:outputChk',  'unknown nc_library, only snc and matlab are supported')
   end

%% load standard names database

   X = xls2struct(which('nc_oe_standard_names_catalogue.xls'));
   
   if ischar(OPT.oe_standard_name)
      OPT.oe_standard_name = cellstr(OPT.oe_standard_name);
   end

%% one by one add each variable

for i = 1:length(OPT.oe_standard_name)
    
    oe_standard_name = OPT.oe_standard_name{i};

    j = strmatch(oe_standard_name,X.standard_name);

    if strcmpi('time',OPT.oe_standard_name{i})
       X.units{j} = [X.units{j}, OPT.timezone];
    end

    Variable = struct(...
       'Name',       OPT.varname{i} , ...
       'Nctype',    X.nc_type{j}, ... 
       'Dimension', {OPT.dimension(i,:)}, ... 
       'Attribute', struct( ... 
           'Name', ... 
           {'standard_name', 'long_name', 'units', 'fill_value'}, ...
           'Value', ... 
           {X.standard_name{j}, X.long_name{j}, X.units{j}, NaN} ...
           ) ...
        );
    
    % var2evalstr(Variable)

    % append additional attributes
    for jj = 1:size(OPT.additionalAtts,2)
        Variable.Attribute(end+1).Name  = OPT.additionalAtts{1,jj};
        Variable.Attribute(end+0).Value = OPT.additionalAtts{2,jj};
    end
    
    % add variable to output file
    switch OPT.nc_library
        case 'snc'
            nc_addvar(OPT.outputfile, Variable);
            varargout = {[]};       
 	case 'matlab'
            varid = netcdf_addvar(OPT.ncid, Variable );
            if OPT.deflate
                netcdf.defVarDeflate(OPT.ncid,varid,false,true,2);
            end
            varargout = {varid};
    end
end
