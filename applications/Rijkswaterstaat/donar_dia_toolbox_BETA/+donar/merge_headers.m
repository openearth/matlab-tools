function V = merge_headers(B,varargin)
%merge_headers  compiles variable information from blocks
%
% Variables = donar.merge_headers(Blocks)
%
% merges similar headers into Variable array, where each
% item contains one unique parameter, using the output Blocks
% from donar.scan_file. Variables contains the indices
% into the associated Blocks array from donar.scan_file.
% The lenght of Variables is the number of unque variables.
% All header fields are reduced to their unique value, or
% kept is they vary within one variable.
%
% merge_headers also resolves the CF names and CF units for use
% in international context.
%
% merge_headers condenses the information from scan_file
% in a tuple-format of information_per_block into the
% a list-format with all information in an array.
% * 'index' - a vector, containing the associated block indices (1-based)
% * 'ftell' - an array, containing the copied ftell values
% * 'nline' - an array, containing the copied nline values
% * 'nval'  - a vector, containing the copied nval values, such
%             that sum(S.nval) gives the total number of values
%             for unique hdr combination.
%
%%%% S = donar.merge_headers({Info1,Info2}) does the same
%%%% across multiple files. 
%
%See also: open = scan_file + merge_headers, scan_file = read_header + scan_block

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat
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

%% harvest headers into matrix
for i=1:length(B)
   hdr(i) = B(i).hdr;
end

%% get unique variable names, one per block by definition
WNS = unique([hdr.WNS]);
for iwns=1:length(WNS)
    V(iwns).WNS   = WNS{iwns};
    V(iwns).index = [find(strcmp([hdr.WNS],WNS{iwns}))];
end

%% check rest, except of course place and time: hdr.TYD, hdr.BGS
% this actually does not happen for any CTD, Meetvis and Ferrybox data
fldnames = fields(B(1).hdr);

for iwns=1:length(WNS)
    index = V(iwns).index;
    if iwns==1
        V(iwns).hdr = [];
    end
    % Copy unique values from headers, and if not unque, 
    % simply copy all values. TYD and BGS do not have to be unique.
    iblk0 = index(1);
    unique_meta_data = true;
    for ifld=1:length(fldnames)
       fld_is_unique = true;
       for iblk  = V(iwns).index
         fld = fldnames{ifld};
         if ~isequal(B(iblk0).hdr.(fld),...
                     B(iblk ).hdr.(fld));
            fld_is_unique = false;
         end % if
       end % iblk
       if strcmpi(fld,'TYD') | strcmpi(fld,'BGS')
           V(iwns).hdr.(fld) =  [];
       elseif fld_is_unique
           V(iwns).hdr.(fld) =  hdr(index(1)).(fld);
       else
           V(iwns).hdr.(fld) = {hdr(index   ).(fld)};
       end
    end % ifld

    %% Resolve for international standards
   [V(iwns).long_name,...
    V(iwns).standard_name] = donar.resolve_wns(WNS{iwns});
   [V(iwns).long_units,...
    V(iwns).units] = donar.resolve_ehd(V(1).hdr.EHD{2});
    
    %% duplicate relevant block meta-data into array format
    V(iwns).ftell = cell2mat({B(index).ftell}')';
    V(iwns).nline = [B(index).nline];
    V(iwns).nval  = [B(index).nval ];
    
end % iwns

