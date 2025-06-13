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

mh_series=sprintf('%s-series',res_type);
bol_series=ismember({NFStruct.GrpDat.Name},mh_series);
nt=NFStruct.GrpDat(bol_series).SizeDim;

%This is very expensive if you just want the number of times
% ITMAPC=vs_let(NFStruct,sprintf('%s-info-series',res_type),sprintf('IT%sC',upper(res_type)),'quiet'); %results time vector
% nt=numel(ITMAPC); %there must be a better way... ask Bert!

end %function