function varargout=sbkcsv(cmd,varargin),
% SBKCSV Read/write Sobek CSV file
%
%       [Time,Data]=sbkcsv('read','FileName');
%       Reads the data from a Sobek comma separated file.
%
%       No write options implemented yet.

% Copyright (c) 18/5/2000 H.R.A.Jagers (bert.jagers@wldelft.nl)
%                         WL | Delft Hydraulics, The Netherlands
%                         http://www.wldelft.nl

switch cmd,
case {'open','read'},
  varargout=Local_csv_read(varargin{:});
case 'write',
  error('Not yet implemented.');
otherwise,
  error(sprintf('Unknown command: %s.',cmd));
end;

function OUT=Local_csv_read(filename)

fid=fopen(filename,'r');
for i=1:4, Line=fgetl(fid); end;
fclose(fid);
N=length(findstr(',',Line)); % count number of commas in Parameter line

X(1:N)={', %f'};
FormatStr=sprintf('%s','%d/%d/%d %d:%d:%d',X{1:N});
[Y M D h m s X{1:N}]=textread(filename,FormatStr,'headerlines',5);
Time=datenum(Y,M,D,h,m,s);
Data=[X{1:N}];

OUT={Time,Data}; % Add parameter names?