%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 2 $
%$Date: 2021-05-21 09:51:39 +0200 (Fri, 21 May 2021) $
%$Author: chavarri $
%$Id: cut_common_time.m 2 2021-05-21 07:51:39Z chavarri $
%$HeadURL: file:///P:/11205272_waterverd_verzilting_2020/023_RMM2021/04_data_rework/04_scripts/svn/cut_common_time.m $
%

function [tim_cell,val_cell,tim_0,tim_f]=cut_common_time(tim_cell,val_cell)


tim_0=max(cellfun(@(X)min(X),tim_cell));
tim_f=min(cellfun(@(X)max(X),tim_cell));

ns=numel(tim_cell);
for ks=1:ns
    bol_out=tim_cell{1,ks}<tim_0|tim_cell{1,ks}>tim_f;
    tim_cell{1,ks}(bol_out)=[];
    val_cell{1,ks}(bol_out)=[];
end

end %function

