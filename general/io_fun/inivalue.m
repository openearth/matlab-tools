function varargout=inivalue(fileName,varargin)
%INIVALUE   load key, section or entire contents of *.ini keyword file
%
%    keyValue      = inivalue(fileName, sectionName, keyName)
%    sectionValues = inivalue(fileName, sectionName)
%    fileValues    = inivalue(fileName)
%
% reads values of one keyName, one sectionName or entire file from fileName.
% 
% Example: a sample *.ini file (sample.ini) may have entries:
%
%    +------------
%    |  [XYZ]
%    |  abc = 123
%    |  [ZZZ]
%    |  abc = 890
%    +-------------
%
%    inivalue('sample.ini','XYZ','abc') -> '123' 
%    inivalue('sample.ini','ZZZ','abc') -> '890' 
%
%    inivalue('sample.ini','ZZZ')       ->  ans.abc=123
%    inivalue('sample.ini','ZZZ')       ->  ans.abc=890
%
%    inivalue('sample.ini')             ->  ans.XYZ.abc=123
%                                           ans.ZZZ.abc=890
%
% if sectionName or the keyName is not found, it returns []
% if the keyName is empty, the entire section is returned as struct.
% if the sectionName is empty, the entire file is returned as struct.
%
% Note that a *.url file is has the *.ini file format.
%
%See also: textread, setProperty, xml_read, xml_load

% Based on code fragments from: http://www.mathworks.com/matlabcentral/fileexchange/5182-ini-file-reading-utility
% Created By: Irtaza Barlas
% Created On: June 9, 2004
% Created For: IAS Inc.

fid = 0;

sectionName = [];
keyName     = [];
if nargin > 1; sectionName = varargin{1};end
if nargin > 2; keyName     = varargin{2};end

if exist(fileName) ~= 2 
    error(['file finding file: ', fileName]);
end;

fid = fopen(fileName);
if fid<=0
    error(['file opening file: ', fileName]);
    floce(fid)
end;
   
   sectionString = ['[' sectionName ']'];
   sectionFound  = 0;
   rec           = fgetl(fid);
   
   while sectionFound~=1
   
      if isempty(rec)
         rec = fgetl(fid);
         continue;
      elseif rec==-1
         break;
      end;

      if isempty(sectionName) | strcmp(strtrim(rec), sectionString) > 0 % allow leading spaces
      
          if isempty(sectionName)
             i0=find(rec=='[');
             i1=find(rec==']');
             section = rec(i0+1:i1-1);
          else
             section = sectionName;
          end
          
       %% look for the key
          
          sectionFound = 1;
          keyFound     = 0;
          rec          = fgetl(fid);
          
          while keyFound==0

             if isempty(rec)==1
                  rec = fgetl(fid);
                  continue;
              end;
              if rec==-1 % EOF
                  break;
              end;
              if isempty(strtrim(rec)) == 0 
                  rec = strtrim(sscanf(rec, '%c')); % keep all whitespaces except leading and trailing
                  if rec(1)=='[' % next section                   
                      break;
                  end;
                  
              %% look for the value
              
                  eq_idx=find(rec=='=');
                  if ~isempty(eq_idx) %~=1 & eq_idx(1)>1 
                      key=strtrim(rec(1:eq_idx(1)-1));
                      if isempty(keyName) | strcmp(key, keyName)>0 
                          [rs, cs]=size(rec);
                          if eq_idx(1)>=cs
                              keyValue = '';
                          else
                              keyValue=strtrim(rec(eq_idx(1)+1:end));
                          end;
                          if strcmp(key, keyName)>0 
                             keyFound = 1;
                             out      = keyValue;
                             break;
                          else
                             if isempty(sectionName)
                             out.(section).(key) = keyValue;
                             else
                             out.(key) = keyValue;
                             end
                          end

                      end;
                  end;               
              end;
              
              rec = fgetl(fid);
              if rec==-1
                  break
              end
              
              rec = strtrim(sscanf(rec, '%c')); % keep all whitespaces except leading and trailing

	      if rec(1)=='[' % next section                   

                 if isempty(sectionName)
                    i0=find(rec=='[');
                    i1=find(rec==']');
                    section = rec(i0+1:i1-1);
                 else
                    section = sectionName;
                 end

                 rec = fgetl(fid);

	      end
	      
          end; % keyFound
          break;
      end; % sectionString
      rec = fgetl(fid);
   end; % sectionFound
   fclose(fid);
   varargout = {out};
