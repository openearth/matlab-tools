function [UMN,VMN]=thd_io(cmd,varargin),
% THD_IO Read/write thin dam files
%
%  [UMN,VMN]=thd_io('read',filename);
%  Success=thd_io('write',filename,UMN,VMN);
%
%  See also: THINDAM

% (c) copyright 2000
%     WL | Delft Hydraulics, Delft, The Netherlands
%     H.R.A.Jagers

switch lower(cmd),
case 'read',
  [UMN,VMN]=Local_read_thd(varargin{:});
case 'write',
  OK=Local_write_thd(varargin{:});
  if nargout>0,
    UMN=OK;
  elseif OK<0,
    error('Error writing file');
  end;
end;


function [UMN,VMN]=Local_read_thd(filename),

[M1,N1,M2,N2,D]=textread(filename,'%d %d %d %d %c');
if isempty(D),
  UMN=zeros(0,4);
  VMN=zeros(0,4);
  return
end;
MNMN=[M1,N1,M2,N2];
UMN=MNMN(D=='U',:);
VMN=MNMN(D=='V',:);
if any((D~='U')&(D~='V')),
  warning('Invalid dam directions encountered. Lines skipped.')
end;


function OK=Local_write_thd(filename,UMN,VMN),

OK=0;
fid=fopen(filename,'w');
fprintf('%d %d %d %d U\n',UMN')
fprintf('%d %d %d %d V\n',VMN')
fclose(fid);
OK=1;
