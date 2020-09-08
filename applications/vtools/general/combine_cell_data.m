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
%combines the data in a cell array into a cell array or matrix. The benefit
%is that it preserves the empty values. 

%INPUT
%   -data_type: 1 = character, 2=double

function aux_v2=combine_cell_data(aux_v,data_type,pos)

nv=numel(aux_v);
aux_v2=cell(1,nv);
for kv=1:nv
    if isempty(aux_v{1,kv})
        if data_type==1 
            aux_v2{1,kv}='';
        elseif data_type==2
            aux_v2{1,kv}=NaN;
        end 
    else
        if isa(aux_v{1,kv},'double')
            if isnan(pos(kv))
                aux_v2{1,kv}=NaN;
            else
                
%                 if numel(aux_v{1,kv})>=pos(kv)
                    aux_v2{1,kv}=aux_v{1,kv}(pos(kv));
%                 else
%                     aux_v2{1,kv}=NaN;
%                 end
            end
        else
            aux_v2{1,kv}=aux_v{1,kv}{1,1};
        end
    end
end

if data_type==2
    aux_v2=cell2mat(aux_v2);
end