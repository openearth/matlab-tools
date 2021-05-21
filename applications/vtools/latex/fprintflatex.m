%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17028 $
%$Date: 2021-02-01 13:22:57 +0100 (Mon, 01 Feb 2021) $
%$Author: chavarri $
%$Id: fprintflatex.m 17028 2021-02-01 12:22:57Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/fprintflatex.m $
%
%get absolute limits

function fprintflatex(fid,str)

fprintf(fid,strcat(strrep(str,'\','\\'),'\n'));

end %function
