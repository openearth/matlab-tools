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

function flg_loc=gdm_parse_sediment_transport(flg_loc,simdef)

%modify variable names or skip
if ismember('cel_morpho',flg_loc.var)
    if isfield(flg_loc,'sedtrans') %sediment transport offline
        nst=numel(flg_loc.sedtrans); %number of different sediment transport relations
        %modify name 'cel_morpho' with the name of each sediment transport relation
        idx_cm=find_str_in_cell(flg_loc.var,{'cel_morpho'});

        flg_loc.var(idx_cm)=[]; %remove 'cel_morpho'

        nv=numel(flg_loc.var);

        vals2add={'var_idx','sum_var_idx','do_val_B_mor','do_val_B','layer','unit','do_cum','do_area'};

        nva=numel(vals2add);
        for kva=1:nva
            if isfield(flg_loc,vals2add{kva})
                var_aux=flg_loc.(vals2add{kva});
                flg_loc.(vals2add{kva})(idx_cm)=[];
                for kst=1:nst
                    flg_loc.(vals2add{kva})=cat(2,flg_loc.(vals2add{kva}),var_aux(idx_cm));
                end %kst
            end
        end %kva

%         if isfield(flg_loc,'sum_var_idx')
%             sum_var_idx_aux=flg_loc.sum_var_idx;
%             flg_loc.sum_var_idx(idx_cm)=[];
%         end
% 
%         if isfield(flg_loc,'do_val_B_mor')
%             do_val_B_mor_aux=flg_loc.do_val_B_mor;
%             flg_loc.do_val_B_mor(idx_cm)=[];
%         end
% 
%         if isfield(flg_loc,'do_val_B')
%             do_val_B_aux=flg_loc.do_val_B;
%             flg_loc.do_val_B(idx_cm)=[];
%         end
% 
%         if isfield(flg_loc,'do_val_B')
%             unit_aux=flg_loc.do_val_B;
%             flg_loc.do_val_B(idx_cm)=[];
%         end

%         nv=numel(flg_loc.var);
        for kst=1:nst
            flg_loc.var=cat(2,flg_loc.var,{sprintf('cel_morpho_%s',flg_loc.sedtrans_name{kst})}); %add 'cel_morpho_%s'
%             if isfield(flg_loc,'var_idx')
%                 flg_loc.var_idx=cat(2,flg_loc.var_idx,var_idx_aux(idx_cm));
%             end
%             if isfield(flg_loc,'sum_var_idx')
%                 flg_loc.sum_var_idx=cat(2,flg_loc.var_idx,sum_var_idx_aux(idx_cm));
%             end
%             if isfield(flg_loc,'do_val_B_mor')
%                 flg_loc.do_val_B_mor=cat(2,flg_loc.do_val_B,do_val_B_mor_aux(idx_cm));
%             end
%             if isfield(flg_loc,'do_val_B')
%                 flg_loc.do_val_B=cat(2,flg_loc.do_val_B,do_val_B_aux(idx_cm));
%             end
        end %kst
    else %read sediment transport parameters from files
        nst=1; %there can only be one
    end
else
    %sediment transport at this moment only needed for cel_morpho
    flg_loc.sediment_transport=NaN(1,numel(flg_loc.var));
    return
end

%add sediment transport information
dk=D3D_read_sed(simdef.file.sed);

if isfield(flg_loc,'sedtrans') %sediment transport offline
    %store sediment transport relation at the location of the variable
    for kst=1:nst
        flg_loc.sediment_transport(nv+kst).dk                   =dk;
        flg_loc.sediment_transport(nv+kst).sedtrans             =flg_loc.sedtrans{kst};
        flg_loc.sediment_transport(nv+kst).sedtrans_param       =flg_loc.sedtrans_param{kst};
        flg_loc.sediment_transport(nv+kst).sedtrans_hiding      =flg_loc.sedtrans_hiding(kst);
        flg_loc.sediment_transport(nv+kst).sedtrans_hiding_param=flg_loc.sedtrans_hiding_param(kst);
        flg_loc.sediment_transport(nv+kst).sedtrans_mu          =flg_loc.sedtrans_mu(kst);
        flg_loc.sediment_transport(nv+kst).sedtrans_mu_param    =flg_loc.sedtrans_mu_param(kst);
        flg_loc.sediment_transport(nv+kst).sedtrans_sbform      =flg_loc.sedtrans_sbform(kst);
        flg_loc.sediment_transport(nv+kst).sedtrans_wsform      =flg_loc.sedtrans_wsform(kst);
        flg_loc.sediment_transport(nv+kst).sedtrans_theta_c     =flg_loc.sedtrans_theta_c(kst);
    end
else %read sediment transport parameters from files
    error('do')
end

end %function 