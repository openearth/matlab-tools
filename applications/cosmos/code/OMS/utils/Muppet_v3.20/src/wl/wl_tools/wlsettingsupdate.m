function wlsettingsupdate(currentversion)
%WLSETTINGSUPDATE

%This function is reserved for updating the wlsettings.m
%files in the user directories.

if nargin==0
   return
end

latestversion = wlsettings;
if latestversion>currentversion
   Caller = evalin('caller','which(''wlsettings'')');
   Latest = which('wlsettings');
   if ~isequal(Caller,Latest)
      [SUCCESS,MESSAGE,MESSAGEID] = copyfile(Latest,Caller,'f');
      %if ~SUCCESS
      %   fprintf('New WLSETTINGS function available.\n');
      %   fprintf('Automatic update failed, update manually.\n');
      %end
   end
elseif latestversion<currentversion & strcmp(lower(getenv('USERID')),'jagers')
   Caller = evalin('caller','which(''wlsettings'')');
   Latest = which('wlsettings');
   if ~isequal(Caller,Latest)
      fprintf('Uploading new WLSETTINGS function.')
      [SUCCESS,MESSAGE,MESSAGEID] = copyfile(Caller,Latest,'f');
      if ~SUCCESS
         fprintf('Automatic upload failed, try it manually.\n');
      end
   end
end