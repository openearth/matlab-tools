function block_data = read_block(fid,ncolumn,nval)
%READ_BLOCK reads one block of donar data
%
%    block_data = donar.read_block(fid,ncolumn,nval) 
%
% reads the datablock into a call matrixs. NOTE the file
% pointer should be where it was after donar.read_header()
% or be put at ftell position returned by donar.scan_block().
% read_block leaves the pointer at the end of the block,
% at the start of the next header or eof. This way, an 
% entire file can be read by alternatingly calling
% donar.read_header() and donar.scan_block(). 
%
% ncolumn is the number of ;-separated columns inside one
% DONAR tuple (that are :-separated). Note that the donar
% value x/y is here parsed into 2 seperate columns x and y,
% so block_data will be size [:, ncolumn+1].
%
% Use donar.squeeze_block to remove nodatavalue data.
%
% See also: scan_block, squeeze_block

OPT.format   = '%s';

    fmt  = repmat(OPT.format,[1 ncolumn+1]); % variable column has sub-column
    temp = textscan(fid,fmt,nval,'delimiter',';:/');
    
    %% make number from text
    for i=1:ncolumn+1
        temp{i} = str2num(char(temp{i}));
    end

if isempty(temp{ncolumn})

   block_data = [];

else

   block_data = cell2mat(temp);

end
