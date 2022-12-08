%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
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

