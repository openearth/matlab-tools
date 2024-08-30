%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function str=svn_info

fpath_oet=which('oetsettings');

if isempty(fpath_oet)
    str='No OET';
else
    fdir=fileparts(fpath_oet);
    cmd=sprintf('svn info %s',fdir);
    [~,str]=system(cmd);
end

end %function