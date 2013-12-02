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
% See also: 

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

    %% Resolve for international standard
   [V(iwns).long_name,...
    V(iwns).standard_name] = donar.resolve_wns(WNS{iwns});
   [V(iwns).long_units,...
    V(iwns).units] = donar.resolve_ehd(V(1).hdr.EHD{2});
    
    %% duplicate relevant block meta-data into array format
    V(iwns).ftell = cell2mat({B(index).ftell}')';
    V(iwns).nline = [B(index).nline];
    V(iwns).nval  = [B(index).nval ];
    
end % iwns

