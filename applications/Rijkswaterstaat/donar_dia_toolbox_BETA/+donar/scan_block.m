function [iline, ival, bob]= scan_block(fid,varargin)
%scan_block    fast scan donar dia data block without reading data
%
% [iline, ival]= scan_block(fid,<keyword,value>)
%
% scans a data block to determine number of lines andf number
% of values (can be kore per line). The file pointer should be
% where it is after donar.read_header(). Optionally repositions 
% the file pointer after scanning with keyword 'rewind'=1.
%
% [iline, ival,position] = donar.scan_block(fid) returns the
% ftell position of the begin of the block.
%
% See also: scan_file = read_header + scan_block, read_block

% warning('TO DO: return # ncolumns')

OPT.rewind = 0;

OPT = setproperty(OPT,varargin);

    bob = ftell(fid); % begin of block

    rec = fgetl(fid);
    if rec == -1, temp = -1; return; end %Is it the end of the file?
    
    iline = 0;
    ival  = 0;

    % STOP at each [wrd]    
    while ~(strcmpi(rec(1),'[') | rec==-1)
        p     = strfind(rec,':');
        ival  = ival + length(p);
        iline = iline+1;
        eob   = ftell(fid); % end of block
        rec   = fgetl(fid);
    end
    
    if OPT.rewind
       fseek(fid,bob,'bof'); % remedy against last rec, that belonhg to block and not header
    else
       fseek(fid,eob,'bof');        
    end
