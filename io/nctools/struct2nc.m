function varargout = struct2xls(outputfile,D,varargin)
%STRUCT2NC   save struct with 1D vectors to netCDF file (beta)
%
%   STRUCT2NC(ncfile        ,<keyword,value>)
%   STRUCT2NC(ncfile,dat    ,<keyword,value>)
%   STRUCT2NC(ncfile,dat,atr,<keyword,value>) 
%
%   ncfile - netCDF file name
%   dat    - structure of 1D arrays of numeric data
%   atr    - optional structure of file and variable attributes
%
% Note that this function has limited applicability only
% because it does the naming of dimensions based on size only
% and not on the actual meaning of the dimension.
%
% Implemented <keyword,value> pairs are:
% * dimension_name = common dimension name of 1D variables (default 'catalog_length')
%
% STRUCT2NC can be used to generate an experimental development: 
% creating a catalog.nc for a THREDDS OPeNDAP server as an alternative
% to the difficult-to-parse catalog.xml.
%
% Example 1:
%
%  D.datenum               = datenum(1970,1,1:.1:3);
%  D.eta                   = sin(2*pi*D.datenum./.5);
%  M.terms_for_use         = 'These data can be used freely for research purposes provided that the following source is acknowledged: OET.';
%  M.disclaimer            = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
%  M.units.datenum         = 'time';
%  M.units.eta             = 'sea_surface_height';
%  M.standard_name.datenum = 'days since 0000-0-0 00:00:00 +00:00';
%  M.standard_name.eta     = 'meter';
%  struct2nc('file.nc',D,M);
%
% Example 2:
%
%  [D,M.units] = xls2struct('file_created_with_struct2xls.xls');
%  struct2nc('file.nc',D,M);
%
%See also: STRUCT2XLS, XLS2STRUCT, SDSAVE_CHAR, SDLOAD_CHAR, NC_GETALL

% TO DO: , NC2STRUCT
% TO DO: pass global attributes as <keyword,value> or as part of M.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Initialize

   OPT.dump              = 0;
   OPT.disp              = 0;
   OPT.pause             = 0;
   OPT.dimension_name    = 'catalog_length';

%% Units

   if odd(nargin)
      M           = varargin{1};
      varargin{1} = [];
      attnames    = fieldnames(M);
      natt        = length(attnames);
   end

%% Parse struct to netCDF

   fldnames = fieldnames(D);
   nfld     = length(fldnames);

   %% 0 Create file

   nc_create_empty (outputfile);

   %% 1 Add global meta-info to file
   % Add overall meta info:
   % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   
      for iatt=1:natt
      attname = attnames{iatt};
      if ~isstruct(M.(attname)); % others are variable attributes
      nc_attput(outputfile, nc_global,attname,M.(attname));
      end
      end
      
   % nc_attput(outputfile, nc_global, 'title'           , '');
   % nc_attput(outputfile, nc_global, 'institution'     , '');
   % nc_attput(outputfile, nc_global, 'source'          , '');
   % nc_attput(outputfile, nc_global, 'history'         , ['Created by: $HeadURL$']);
   % nc_attput(outputfile, nc_global, 'references'      , '');
   % nc_attput(outputfile, nc_global, 'email'           , '');
   % nc_attput(outputfile, nc_global, 'comment'         , 'Test to see whether catalog.nc is handier than catalog.xml');
   % nc_attput(outputfile, nc_global, 'version'         , '');
   % nc_attput(outputfile, nc_global, 'Conventions'     , '');
   % nc_attput(outputfile, nc_global, 'terms_for_use'   , 'These data can be used freely for research purposes provided that the following source is acknowledged: Rijkswaterstaat.');
   % nc_attput(outputfile, nc_global, 'disclaimer'      , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

   %% 2 Create dimensions
   
   nc_add_dimension(outputfile, OPT.dimension_name, length(D.(fldnames{1})))

   charlen = [];

   for ifld=1:nfld
   
      fldname = fldnames{ifld};
      
      if iscellstr(D.(fldname))
         D.(fldname) = char(D.(fldname));
      end
      
      if ischar(D.(fldname))
         charlen = [charlen size(D.(fldname),2)];
      end
   end

   charlen = sort(unique(charlen));
   for ilen=1:length(charlen)
   nc_add_dimension(outputfile, ['char_length_',num2str(charlen(ilen))], charlen(ilen));
   end

   %% 3 Create variables

   clear nc
   ifld = 0;

   for ifld=1:nfld
   
      fldname = fldnames{ifld};
      
      nc(ifld).Name         = fldname;
      nc(ifld).Nctype       = nc_type(class(D.(fldname)));
      if ischar(D.(fldname))
      char_dim = ['char_length_',num2str(size(D.(fldname),2))];
      nc(ifld).Dimension    = {'catalog_length',char_dim};
      else
      nc(ifld).Dimension    = {'catalog_length'};
      end
      
      par_att = 0;
      for iatt=1:natt
      attname = attnames{iatt};
      if isstruct(M.(attname)) % others are file attributes
      par_att = par_att + 1;
      nc(ifld).Attribute(par_att) = struct('Name',attname,'Value', M.(attname).(fldname));
      end
      end

   end

   %% 4 Create variables with attibutes
   % When variable definitons are created before actually writing the
   % data in the next cell, netCDF can nicely fit all data into the
   % file without the need to relocate any info.
   
   % var2evalstr(nc)

   for ifld=1:length(nc)
       if OPT.disp;disp([num2str(ifld),' ',nc(ifld).Name]);end
       nc_addvar(outputfile, nc(ifld));
   end

   %% 5 Fill variables

   for ifld=1:nfld
   
      fldname = fldnames{ifld};

      nc_varput(outputfile, fldname  , D.(fldname));

   end

   %% 6 Check

   if OPT.dump
       nc_dump(outputfile);
   end

   %% Pause

   if OPT.pause
       pausedisp
   end

%% EOF