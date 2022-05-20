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
%writes reference in tex file

%     id                    = #0001#
expr='\w+([.-]?\w+)*';
str_aux_r=regexp(str_aux,expr,'match');

%%

tok=regexp(grainp{kl,1},'\$GSLEVUNLA Branch\s+(\d+)\s+AT\s+(\d+)\s+(-?\d+.\d+)','tokens');

%maybe decimal, maybe not
tok=regexp(t2,'([+-]?(\d+(\.\d+)?)|(\.\d+))','tokens')
