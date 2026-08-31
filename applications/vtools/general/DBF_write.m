%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Write a dBase III (dbf) file such as the attribute table of an ESRI
%shapefile. <shapewrite> can only store numeric attributes; this function
%also stores character attributes.
%
%INPUT
%   - fpath_dbf = path to the dbf-file to write
%   - names = cell string with the field names (truncated to 10 characters)
%   - values = cell array with one entry per field. Each entry is either a
%       numeric vector (stored as type 'N') or a cell string (stored as
%       type 'C'). All entries must have the same number of elements.
%
%TODO:
%   -
%
%E.G.
%
% DBF_write('c:\temp\trial.dbf',{'ID','NAME','MEAN'},{(1:3)',{'a';'b';'c'},[1.5;2.5;NaN]});

function DBF_write(fpath_dbf,names,values)

%% CHECK

if ~iscellstr(names)
    error('<names> must be a cell string')
end
if ~iscell(values)
    error('<values> must be a cell array')
end
nfld=numel(names);
if numel(values)~=nfld
    error('<names> has %d entries but <values> has %d',nfld,numel(values))
end
if nfld==0
    error('At least one field is required')
end

nrec=numel(values{1});
for kf=1:nfld
    if numel(values{kf})~=nrec
        error('Field <%s> has %d records; expected %d',names{kf},numel(values{kf}),nrec)
    end
end

%% FORMAT FIELDS

str_c=cell(nfld,1); %character matrix per field
type_v=repmat(' ',nfld,1);
width_v=NaN(nfld,1);
dec_v=zeros(nfld,1);

for kf=1:nfld
    val=values{kf};
    if isnumeric(val) || islogical(val)
        [str_c{kf},dec_v(kf)]=numeric_to_char(double(val(:)));
        type_v(kf)='N';
    elseif iscell(val)
        str_c{kf}=char_to_char(val(:));
        type_v(kf)='C';
    else
        error('Field <%s> is of unsupported class <%s>. Use a numeric vector or a cell string.',names{kf},class(val))
    end
    width_v(kf)=size(str_c{kf},2);
    if width_v(kf)>254
        error('Field <%s> requires a width of %d characters; the dbf format allows at most 254',names{kf},width_v(kf))
    end
end

%% ASSEMBLE RECORDS

%the leading blank is the <not deleted> flag
rec_str=[repmat(' ',nrec,1),str_c{:}];

%% WRITE

fid=fopen(fpath_dbf,'w','l');
if fid<0
    error('Cannot open file for writing: %s',fpath_dbf)
end

try
    dv=clock; %#ok<CLOCK>
    fwrite(fid,3,'uint8'); %dBase III without memo file
    fwrite(fid,[dv(1)-1900,dv(2),dv(3)],'uint8');
    fwrite(fid,nrec,'uint32');
    fwrite(fid,32+32*nfld+1,'uint16'); %header length
    fwrite(fid,size(rec_str,2),'uint16'); %record length
    fwrite(fid,zeros(1,20),'uint8'); %reserved

    for kf=1:nfld
        name_loc=names{kf};
        if numel(name_loc)>10
            warning('Field name <%s> truncated to <%s>',name_loc,name_loc(1:10))
            name_loc=name_loc(1:10);
        end
        name_v=zeros(1,11);
        name_v(1:numel(name_loc))=double(name_loc);

        fwrite(fid,name_v,'uint8');
        fwrite(fid,type_v(kf),'uchar');
        fwrite(fid,zeros(1,4),'uint8'); %memory address
        fwrite(fid,width_v(kf),'uint8');
        fwrite(fid,dec_v(kf),'uint8');
        fwrite(fid,zeros(1,14),'uint8'); %reserved
    end

    fwrite(fid,13,'uint8'); %end of field descriptors
    fwrite(fid,double(rec_str)','uint8'); %transposed because records are written row-wise
    fwrite(fid,26,'uint8'); %end of file
catch err
    fclose(fid);
    rethrow(err)
end

fclose(fid);

end %function

%% 
%% FUNCTIONS
%% 

%%
%% NUMERIC_TO_CHAR
%%

function [str,dec]=numeric_to_char(val)

bol_fin=isfinite(val);
if all(bol_fin) && all(val(bol_fin)==round(val(bol_fin)))
    dec=0;
    fmt='%11.0f';
else
    dec=15;
    fmt='%24.15f';
end

str=num2str(val,fmt);

%non-finite values are stored as blanks, which is how the dbf format
%represents a missing numeric value
if ~all(bol_fin)
    str(~bol_fin,:)=' ';
end

end %function

%%
%% CHAR_TO_CHAR
%%

function str=char_to_char(val)

bol_bad=~cellfun(@(X)ischar(X)||isstring(X),val);
if any(bol_bad)
    error('All entries of a character field must be char or string')
end

val=cellfun(@(X)char(X),val,'UniformOutput',false);
str=char(val); %pads with blanks on the right

if isempty(str)
    str=repmat(' ',numel(val),1);
end

end %function
