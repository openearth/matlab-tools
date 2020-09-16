%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 246 $
%$Date: 2020-07-08 10:57:48 +0200 (Wed, 08 Jul 2020) $
%$Author: chavarri $
%$Id: erase_directory.m 246 2020-07-08 08:57:48Z chavarri $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/erase_directory.m $
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

function erase_directory(path2erase,fid_log)


%erase folder directly
if ispc
    dos(sprintf('RD /S /Q %s',path2erase));
elseif isunix
    system(sprintf('rm -rf %s',path2erase));
elseif ismac
    warningprint(fid_log,'Are you seriously using a mac? come on... :( very disappointing...');
else
    warningprint(fid_log,'What kind of operating system are you using? Whatever, I cannot erase the output files! :(');
end


end
