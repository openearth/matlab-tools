function varargout = struct2nc(outputfile,D,varargin)
%STRUCT2NC   save struct with 1D arrays to netCDF file (beta)
%
%   nc2struct(ncfile,dat    ,<keyword,value>)
%   nc2struct(ncfile,dat,atr,<keyword,value>)
%
%   ncfile - netCDF file name
%   dat    - structure of 1D arrays of numeric/character data
%   atr    - optional structure of file and variable attributes
%                 atr.att_name.var_name
%            NOT: atr.var_name.att_name
%
% Note that this function has limited applicability only
% because it does the naming of dimensions based on size only
% and not on the actual meaning of the dimension.
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
%  M.units.eta             = 'meter';
%  M.standard_name.datenum = 'days since 0000-0-0 00:00:00 +00:00';
%  M.standard_name.eta     = 'sea_surface_height';
%  struct2nc('file.nc',D,M);
%
% Example 2:
%
%  [D,M.units] = xls2struct('file_created_with_struct2xls.xls');
%  struct2nc('file.nc',D,M);
%
%See also: NC2STRUCT, XLS2STRUCT,  
%          STRUCT2XLS, SDSAVE_CHAR, SDLOAD_CHAR, NC2STRUCT, NC_GETALL

% TO DO: allow for meta/attribute info struct: atr.var_name.att_name
% TO DO: pass global attributes as <keyword,value> or as part of M.
% TO DO: fix issue that space is considered as end-of-line

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

if nargin==0
   varargout = {OPT};
   return
end

%% Units

if odd(nargin)
    M           = varargin{1};
    varargin{1} = [];
    attnames    = fieldnames(M);
    natt        = length(attnames);
else
    natt        = 0;
end

%% Parse struct to netCDF

fldnames = fieldnames(D);
nfld     = length(fldnames);

%% 0 Create file

nc_create_empty (outputfile);

%% 1 Add global meta-info to file
%  Add overall meta info:
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents

for iatt=1:natt
    attname = attnames{iatt};
    if ~isstruct(M.(attname)); % others are variable attributes
        nc_attput(outputfile, nc_global,attname,M.(attname));
    end
end

%% 2 Create dimensions

dimension_lengths = [];

for ifld=1:nfld
    
    fldname = fldnames{ifld};
    
    if iscellstr(D.(fldname))
        D.(fldname) = char(D.(fldname));
    end
    
    dimension_lengths = [dimension_lengths size(D.(fldname))];
    
end

dimension_lengths = sort(unique(dimension_lengths));
dimension_lengths = setdiff(dimension_lengths,0);
for ilen=1:length(dimension_lengths)
    nc_add_dimension(outputfile, ['dimension_length_',num2str(dimension_lengths(ilen))], dimension_lengths(ilen));
end

%% 3 Create variables

clear nc
ifld = 0;

for ifld=1:nfld
    
    fldname = fldnames{ifld};
    
    nc(ifld).Name               = fldname;
    nc(ifld).Nctype             = nc_type(class(D.(fldname)));
    
    dimensions = {};
    for idim=1:length(size(D.(fldname)))
        dimension_length = ['dimension_length_',num2str(size(D.(fldname),idim))];
        dimensions{idim} = dimension_length;
    end
    
    nc(ifld).Dimension          = dimensions;
    
    par_att = 0;
    for iatt=1:natt
        attname                     = attnames{iatt};
        if isstruct(M.(attname)) % others are file attributes
            if isfield(M.(attname),fldname)
                par_att                     = par_att + 1;
                nc(ifld).Attribute(par_att) = struct('Name',attname,'Value', M.(attname).(fldname));
            end
        end
    end
    
end

%% 4 Create variables with attibutes
%  When variable definitons are created before actually writing the
%  data in the next cell, netCDF can nicely fit all data into the
%  file without the need to relocate any info.

% var2evalstr(nc)

for ifld=1:length(nc)
    fldname = fldnames{ifld};
    if OPT.disp;disp([num2str(ifld),' ',nc(ifld).Name]);end
    if sum(~ismember(nc(ifld).Dimension,'dimension_length_0')) == 2
        nc_addvar(outputfile, nc(ifld));
    end
end

%% 5 Fill variables

for ifld=1:nfld
    
    fldname = fldnames{ifld};
    
    if ~length(D.(fldname))==0
        
        % The MEXNC and JAVA netCDF interfaces cannot deal with the
        % character 0 (the Matlab native interface can).
        % You can solve this by writing to the file per line
        % (slow for much lines), or replacing all 0s with a space character.
        % 0 characters can end up in a string when you expand it by
        % indexing a non-existing cell. Example:
        % >>  a = repmat(' ',[2 2])
        % >>  a(20) = 'b'
        % >>  a==0
        %
        % The default fill value is 0, not ' '. Use strvcat() etc instead.
        
        if ischar(D.(fldname))
            
            nullmask = D.(fldname)==0;
            D.(fldname)(nullmask) = ' ';
            %col = size(D.(fldname),2);
            %for row=1:size(D.(fldname),1)
            %nc_varput(outputfile, fldname , D.(fldname)(row,:),[row 1]-1,[1 col],[1 1]); % zero-based !!
            %end
        end
        nc_varput(outputfile, fldname , D.(fldname)); % cannot handle logicals
        
    end
    
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