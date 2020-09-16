%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 137 $
%$Date: 2017-07-20 09:50:06 +0200 (Thu, 20 Jul 2017) $
%$Author: V $
%$Id: warningprint.m 137 2017-07-20 07:50:06Z V $
%$HeadURL: https://repos.deltares.nl/repos/ELV/branches/V0171/main/warningprint.m $
%
%warningprint does this and that
%
%warningprint(fid_log, text)
%
%INPUT:
%   -input = input structure
%
%OUTPUT:
%   -
%
%HISTORY:

function warningprint(fid_log, text)
if isnan(fid_log)==1
    warning('No log file specified, warning is only printed to the screen');
    warning(text);
else
    %   Display warning message
    %   Write output to logfile
    warning(text);
    fprintf(fid_log,'!!WARNING!!: %s \n',text);
end
end

