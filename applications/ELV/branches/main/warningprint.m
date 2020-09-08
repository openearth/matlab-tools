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

