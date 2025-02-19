%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19094 $
%$Date: 2023-07-27 18:08:29 +0200 (Thu, 27 Jul 2023) $
%$Author: chavarri $
%$Id: bib_add_tags.m 19094 2023-07-27 16:08:29Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/latex/bib_add_tags.m $
%
%Replace non-ascii in latex

function lin=latex_nonascii(lin)

lin=strrep(lin,'á','\''a');
lin=strrep(lin,'é','\''e');
lin=strrep(lin,'í','\''i');
lin=strrep(lin,'ó','\''o');
lin=strrep(lin,'ú','\''u');

lin=replace_especial(lin,'\&','&');

end %function

%%
%% FUNCTIONS
%%

function lin=replace_especial(lin,str_new,str_old)

str_impossible='ñíáúó42';
lin=strrep(lin,str_new,str_impossible);
lin=strrep(lin,str_old,str_new);
lin=strrep(lin,str_impossible,str_new);

end %function