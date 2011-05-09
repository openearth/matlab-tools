function Struct = csv2struct(filename,PreAlloc)
% CSV2STRUCT Read a comma separated data file.
%     STRUCT = CSV2STRUCT(FILENAME) reads a comma
%     separated data formatted file FILENAME.  The
%     result is returned in STRUCT.  The first
%     line should contain the FieldNames, the second
%     line (first data line) determines whether values
%     are read as strings or numbers.
%
%     If the number of data lines in the file is known
%     in advance, one can specify a preallocation size
%     STRUCT = CSV2STRUCT(FILENAME,PREALLOCATE).

% (c) copyright, H.R.A. Jagers, 2000
%     WL | Delft Hydraulics / University of Twente, The Netherlands

% Open file
fid = fopen(filename, 'r');
if fid < 0
  error(sprintf('Can''t open file "%s" for reading.',filename));
end

% Read header line
header = fgetl(fid);

% Convert header string to a cell array with field names.
NFld=length(findstr(header,','))+1;
fields = cell(NFld,1);
for i=1:NFld,
  [fields{i},header]=strtok(header,',');
  if length(fields{i})>31,
    warning(sprintf('Fieldname too long: %s',fields{i}));
    fields{i}=fields{i}(1:31);
  end;
end;

% initialize some arrays
values=cell(NFld,1);
if nargin==1,
  PreAlloc=0;
elseif ~isnumeric(PreAlloc) | ~isequal(size(PreAlloc),[1 1]),
  error('Invalid preallocation parameter.');
end;
numeric=zeros(NFld,1);

% determine data types
tmpline = fgetl(fid);
fclose(fid);
if ~ischar(tmpline), break, end
for i=1:NFld,
  [Tok,tmpline]=strtok(tmpline,',');
  [Num,NRead]=sscanf(Tok,'%f%s');
  numeric(i)=(NRead==1); % only some recognizable number
                         % and no other characters
end;

% compose format string
FormatStr(1:NFld)={'%f,'};
FormatStr(~numeric)={'%[^,],'};
FormatStr{NFld}=FormatStr{NFld}(1:end-1); % remove last comma
FormatStr=[FormatStr{:}]; % combine to format string

% call textread
[values{1:NFld}]=textread(filename,FormatStr,PreAlloc,'headerlines',1);

% build structure
Struct=[];
for i=1:NFld,
  % remove preallocated but unused data
  Struct=setfield(Struct,fields{i},values{i});
end;