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
%

function nt=NEFIS_nt(fpath_res,res_type)

NFStruct=vs_use(fpath_res,'quiet');
ITMAPC=vs_let(NFStruct,sprintf('%s-info-series',res_type),sprintf('IT%sC',upper(res_type)),'quiet'); %results time vector
nt=numel(ITMAPC); %there must be a better way... ask Bert!

end %function