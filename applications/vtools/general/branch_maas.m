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
%Branch name of the Maas.

function [br,br_num]=branch_maas(rkm)
nrkm=numel(rkm);
br=cell(nrkm,1);
br_num=NaN(nrkm,1);
for krkm=1:nrkm
%     if rkm(krkm)<230.5
        br{krkm,1}='MA';
%     else
%         br{krkm,1}='BM';
%     end

    %number
    br_num(krkm,1)=branch_maas_str2double(br{krkm});
end

end %function