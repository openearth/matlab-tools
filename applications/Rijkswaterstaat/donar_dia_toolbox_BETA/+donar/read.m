function [Data, Meta] = read(File,ivar,ncolumn)
%read read one variable from donar file (across blocks)
%
%   Data = donar.read(Info, variable_index, ncolumn)
%
% reads one variable from a dia file, merging internal
% dia blocks, where Info ios the result from donar.open,
% variable_index is the index of the variables found
% in the donar file (varies per file), and ncolumn is
% the number of column (where ncolumn is the data column),
% needed internally to reshape the ascii donar data.
%
% The coordinate columns 1+2 are parsed (WGS84 ONLY yet),
% the date columns 3 is in Matlab datenumbers.
%
% Example: 
%
%   Info  = donar.open(diafile)
%   [D,M] = donar.read(Info, 1, 6); % 6 columns
%
%See also: donar.open

    OPT.disp        = 100;
    OPT.squeeze     = 0;
    OPT.nodatavalue = []; % default for squeeze

    fid  = fopen(File.Filename,'r');

    i0   = 1;
    if OPT.disp > 0
    disp([mfilename,' loading ',File.Variables(ivar).long_name,':',File.Variables(ivar).long_name]) % in case one of first OPT.disp blocks is BIG
    end
    
    Data = repmat(nan,[sum(File.Variables(ivar).nval),ncolumn+1]);
    for ibl=1:length(File.Variables(ivar).index)
       i1 = sum(File.Variables(ivar).nval(1:ibl));
       if mod(ibl,OPT.disp)==0
       disp([mfilename,' loaded block ',num2str(ibl)])
       end
       fseek(fid,File.Variables(ivar).ftell(2,ibl),'bof');% posituion file pointer
       Data(i0:i1,:) = donar.read_block(fid,ncolumn,File.Variables(ivar).nval(ibl));
       i0 = i1+1;
    end % ibl
    fclose(fid);
    
    %% remove nodatavalues
    Data = donar.squeeze_block(Data,ncolumn,'nodatavalue',OPT.nodatavalue);
    
   %% either do both inline D{i}, or do both explicit D{i}(:,column)
    Data(:,1) = donar.parse_coordinates(Data(:,1));
    Data(:,2) = donar.parse_coordinates(Data(:,2));
    Data      = donar.parse_time(Data, ncolumn - [2 1]); % has to be inline due to sort
     
    %% copy relevant meta-data fields (not dia-file specific)
    OPT.metafields = {'WNS','hdr','long_name','standard_name','long_units','units'};
    for ifld=1:length(OPT.metafields)
        try
        fld = OPT.metafields{ifld};
        Meta.(fld) = File.Variables(ivar).(fld);
        end
    end
     
     