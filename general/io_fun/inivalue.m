function [ret]=inivalue(fileName, sectionName, keyName)
%INIVALUE   load one key from an ini keyword file
%
%    value = inivalue(fileName, sectionName, keyName)
%
% reads value of keyName from sectionName in fileName.
% 
% Example: a sample ini file (sample.ini) may have entries:
%    +------------
%    |  [XYZ]
%    |  abc = 123
%    |  [ZZZ]
%    |  abc = 890
%    +-------------
%
%    inivalue('XYZ','abc', 'sample.ini') will return '123' 
%    inivalue('ZZZ','abc', 'sample.ini') will return '890' 
%
% if sectionName or the keyName is not found, it returns []
% if the keyName is empty, then [] is returned too.
%
%See also: textread

% Based on code from: http://www.mathworks.com/matlabcentral/fileexchange/5182-ini-file-reading-utility
% Created By: Irtaza Barlas
% Created On: June 9, 2004
% Created For: IAS Inc.

try
    ret = [];
a=0;
if nargin~=3
    return;
end;
if exist(fileName) ~= 2 
    return;
end;
if isempty(sectionName)==1 | isempty(keyName)==1 
    return;
end;

a = fopen(fileName);
if a<=0
    return;
end;

appstr=['[' sectionName ']'];
found_app=0;
st = fgetl(a);
while found_app~=1
    if isempty(st)==1 
        st = fgetl(a);
        continue;
    elseif st==-1
        break;
    end;
   if strcmp(st, appstr)>0
       % look for the key
       found_app=1;
       found_key=0;
       kst = fgetl(a);
       while found_key==0
           if isempty(kst)==1
               kst = fgetl(a);
               continue;
           end;
           if kst==-1
               break;
           end;
           if isempty(kst) == 0 
               kst = strtrim(sscanf(kst, '%c')); % helps eliminate whitespaces
               if kst(1)=='['   % next key                   
                   break;
               end;
               % find equal to sign
               eq_idx=find(kst=='=');
               if ~isempty(eq_idx) %~=1 & eq_idx(1)>1 
                   key=strtrim(kst(1:eq_idx(1)-1));
                   if strcmp(key, keyName)>0 
                       [rs, cs]=size(kst);
                       if eq_idx(1)>=cs
                           ret = '';
                       else
                           ret=strtrim(kst(eq_idx(1)+1:end));
                       end;
                       found_key=1;
                       break;
                   end;
               end;               
           end;
           kst = fgetl(a);
       end;
       break;
   end;
   st = fgetl(a);
end;
fclose(a);
catch
    if a>0 
        fclose(a);
    end;
    [ret, rid] = lasterr;
end;