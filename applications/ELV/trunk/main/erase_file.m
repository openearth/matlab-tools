%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%erase_directory does this and that
%
%erase_directory(input,fid_log)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%181108 
%   -V. Created for the first time.

function erase_file(path2erase,fid_log)


%erase folder directly
if ispc
    dos(sprintf('DEL /Q %s',path2erase));
elseif isunix
    error('add this')
%     system(sprintf('rm -rf %s',path2erase));
elseif ismac
    warningprint(fid_log,'Are you seriously using a mac? come on... :( very disappointing...');
    error('add this')
else
    warningprint(fid_log,'What kind of operating system are you using? Whatever, I cannot erase the output files! :(');
    error('add this')
end


end
