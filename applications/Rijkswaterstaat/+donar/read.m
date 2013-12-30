function [Data, M] = read(File,ivar,ncolumn,varargin)
%READ read one variable from DONAR dia file (aggregating blocks)
%
%   [D,M] = donar.read(Info, variable_index, ncolumn)
%
% reads one variable from a dia file info array D, merging the internal
% dia blocks, where Info is the result from donar.open(),
% variable_index is the index of the variables found
% in the donar file (varies per file), and ncolumn is
% the number of data columns (where ncolumn is the variable column),
% needed internally to reshape the ascii donar data. M 
% contains a copy of the relevant variable metadata from Info.
%
% The coordinate columns 1+2 are parsed (WGS84 ONLY yet),
% and the date columns 3 is converted to Matlab datenumbers.
% Two extra columns are added next t ncolumn: dia flags and dia block index
%
% Note that timezone information is NOT in de dia files !
%
% Example: 
%
%  File            = donar.open(diafile)
%                    donar.disp(File)
% [data, metadata] = donar.read(File,1,6) % 1st variable, residing in 6th column
%
%See also: open, read, disp

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat (SPA Eurotracks)
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
% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

% TODO determine percentage nodatavalue

    OPT.disp        = 100;
    OPT.nodatavalue = []; % default to squeeze them out
    
    if nargin==0
        Data = OPT;return
    end
    OPT = setproperty(OPT,varargin);

    fid  = fopen(File.Filename,'r');

%% read data from multiple blocks into one array

    i0  = 1;
    nbl = length(File.Variables(ivar).index);    
    if OPT.disp > 0
       disp([mfilename,' loading: ',File.Variables(ivar).hdr.PAR{1},': ',File.Variables(ivar).long_name]) % in case one of first OPT.disp blocks is BIG
       disp([mfilename,' loaded block ',num2str(0),'/',num2str(nbl)])
    end
    
    Data = repmat(nan,[sum(File.Variables(ivar).nval),ncolumn+2]); % extra column for flags and for dia index

    for ibl=1:nbl
       i1 = sum(File.Variables(ivar).nval(1:ibl));
       if mod(ibl,OPT.disp)==0
       disp([mfilename,' loaded block ',num2str(ibl),'/',num2str(nbl),' (',num2str(ibl/nbl*100),'%)'])
       end
       fseek(fid,File.Variables(ivar).ftell(2,ibl),'bof');% posituion file pointer
       Data(i0:i1,1:end-1) = donar.read_block(fid,ncolumn,File.Variables(ivar).nval(ibl));
       Data(i0:i1,  end  ) = ibl;
       i0 = i1+1;
    end % ibl
    fclose(fid);
    
 %% Remove or NaNify nodatavalues

    Data = donar.squeeze_block(Data,ncolumn,'nodatavalue',OPT.nodatavalue);
    
 %% either do both inline D{i}, or do both explicit D{i}(:,column)

    Data(:,1) = donar.parse_coordinates(Data(:,1));
    Data(:,2) = donar.parse_coordinates(Data(:,2));
    Data      = donar.parse_time(Data, ncolumn - [2 1]); % has to be inline due to sorting by parse_time
     
 %% copy relevant meta-data fields (not dia-file specific)
 %  Should perhaps better be in se[erate substruct of File

    OPT.metafields = {'WNS','hdr','long_name','standard_name','long_units','units'};
    for ifld=1:length(OPT.metafields)
        try
        fld = OPT.metafields{ifld};
        M.(fld) = File.Variables(ivar).(fld);
        end
    end
