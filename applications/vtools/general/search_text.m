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
%Backward-compatible wrapper for text search in line-based ASCII files.

function [kl_tok,fline_got]=search_text(path_ascii,tok_find,kl_start)

[kl_tok,fline_got]=search_text_ascii(path_ascii,tok_find,kl_start);

end %function
