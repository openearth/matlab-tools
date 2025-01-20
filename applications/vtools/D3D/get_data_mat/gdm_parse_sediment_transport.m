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

if ~isfield(flg_loc,'sediment_transport')
    flg_loc.sediment_transport=gdm_struct_sediment_transport();
end

%modify variable names or skip
if ismember('cel_morpho',flg_loc.var)
    if isfield(flg_loc,'sedtrans') %sediment transport offline
        nst=numel(flg_loc.sedtrans); %number of different sediment transport relations
        %modify name 'cel_morpho' with the name of each sediment transport relation
        idx_cm=find_str_in_cell(flg_loc.var,{'cel_morpho'});

        flg_loc.var(idx_cm)=[]; %remove 'cel_morpho'

        [vals2add,def_v]=gdm_flags_plot_and_default();

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

        for kst=1:nst
            flg_loc.var=cat(2,flg_loc.var,{sprintf('cel_morpho_%s',flg_loc.sedtrans_name{kst})}); %add 'cel_morpho_%s'
        end %kst
%     else %read sediment transport parameters from files
%         nst=1; %there can only be one
    end
end

%add sediment transport information
if isfield(simdef.file,'sed') && ~isempty(simdef.file.sed) %A test on `simdef.D3D.ismor` is not strong, because it can be used for sediment transport offline.
    fpath_sed=simdef.file.sed;
    if iscell(simdef.file.sed)
        fpath_sed=simdef.file.sed{1};
    end
    dk=D3D_read_sed(fpath_sed);
end

if isfield(flg_loc,'sedtrans') %sediment transport offline
    %store sediment transport relation at the location of the variable
    nst=numel(flg_loc.sedtrans); %number of different sediment transport relations
    nv=numel(flg_loc.var);
    for kst=1:nst
        flg_loc.sediment_transport(nv+kst).dk                   =dk;
        flg_loc.sediment_transport(nv+kst).sedtrans             =flg_loc.sedtrans{kst};
        flg_loc.sediment_transport(nv+kst).sedtrans_param       =flg_loc.sedtrans_param{kst};
        flg_loc.sediment_transport(nv+kst).sedtrans_hiding      =flg_loc.sedtrans_hiding(kst);
        flg_loc.sediment_transport(nv+kst).sedtrans_hiding_param=flg_loc.sedtrans_hiding_param(kst);
        flg_loc.sediment_transport(nv+kst).sedtrans_mu          =flg_loc.sedtrans_mu(kst);
        flg_loc.sediment_transport(nv+kst).sedtrans_mu_param    =flg_loc.sedtrans_mu_param(kst);
        if isfield(flg_loc,'sedtrans_sbform')
            flg_loc.sediment_transport(nv+kst).sedtrans_sbform      =flg_loc.sedtrans_sbform(kst);
        end
        
        if isfield(flg_loc,'sedtrans_wsform')
            flg_loc.sediment_transport(nv+kst).sedtrans_wsform      =flg_loc.sedtrans_wsform(kst);
        end
        
        if isfield(flg_loc,'sedtrans_theta_c')
            flg_loc.sediment_transport(nv+kst).sedtrans_theta_c     =flg_loc.sedtrans_theta_c(kst);
        end
    end
end

end %function 