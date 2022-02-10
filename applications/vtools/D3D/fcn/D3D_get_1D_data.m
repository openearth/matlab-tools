%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17612 $
%$Date: 2021-11-29 15:26:03 +0100 (Mon, 29 Nov 2021) $
%$Author: ottevan $
%$Id: D3D_io_input.m 17612 2021-11-29 14:26:03Z ottevan $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_io_input.m $
%
                
function [z,SZ,time_r,zlab,refdate]=D3D_get_1D_data(flg,branch_v,dire_sim_v,which_v_v,time_data,kt_v,time_cmp,in_read)

%%
if ~isfield(flg,'RefDate')
    flg.RefDate=NaN;
end

    %% not input
simdef.flg.which_p=3; %plot type 

    %% size
    
nb=numel(branch_v);
ns=numel(dire_sim_v);
nv=numel(which_v_v);

    %% max number time steps
    
%preallocate
aux_max_nTt=NaN(ns,1);

for ks=1:ns

in_read.kt=0;
simdef.D3D.dire_sim=dire_sim_v{ks};
simdef=D3D_simpath(simdef);
% out_read=D3D_read(simdef,in_read);
out_read.nTt=NC_nt(simdef.file.map);

aux_max_nTt(ks)=out_read.nTt;

end

max_nTt=min(aux_max_nTt);
fprintf('number of map results = %d \n',max_nTt)

%% CALC

    %% simulations
    

%time
switch time_data
    case 0
        switch time_cmp
            case 1
                in_read.kt=[1,max_nTt];
            case 2
                kt_v_m=[ones(ns,1),aux_max_nTt];
        end
        nt=1;
    case 1
        switch time_cmp
            case 1
                kt_v(isnan(kt_v))=max_nTt;
            case 2
                kt_v_m=NaN(ns,numel(kt_v));
                for ks=1:ns
                    kt_v_m(ks,:)=kt_v;
                    kt_v_m(ks,isnan(kt_v))=aux_max_nTt(ks);
                end 
        end
        nt=size(kt_v,2);
end
   
%preallocate
z=cell(ns,nb,nt,nv);
SZ=cell(ns,nb,nt,nv);
time_r=cell(ns,nb,nt,nv);
zlab=cell(nv);
refdate=cell(ns,1);

for kb=1:nb
    for ks=1:ns
        for kt=1:nt
            for kv=1:nv
                %adapt input
                switch time_data
                    case 0
                        switch time_cmp
                            case 1
%                                 in_read.kt=[kt_v(kt),1];
                            case 2
                                in_read.kt=kt_v_m(ks,:);
                        end
                    case 1
                        switch time_cmp
                            case 1
                                in_read.kt=[kt_v(kt),1];
                            case 2
                                in_read.kt=[kt_v_m(ks,kt),1];
                        end
                end
                in_read.branch=branch_v{kb,1};        
                simdef.D3D.dire_sim=dire_sim_v{ks};
                simdef.flg.which_v=which_v_v(kv); 

                %call
                simdef=D3D_simpath(simdef);
                out_read=D3D_read(simdef,in_read);
                mdf=dflowfm_io_mdu('read',simdef.file.mdf);
                
                %save
                z{ks,kb,kt,kv}=out_read.z;
                SZ{ks,kb,kt,kv}=out_read.SZ;
                time_r{ks,kb,kt,kv}=out_read.time_r;
                zlab{kv}=out_read.zlabel;
                if isnan(flg.RefDate)
                    refdate{ks,1}=mdf.time.RefDate;
                else
                    refdate{ks,1}=flg.RefDate;
                end
                
                %disp
                fprintf('branch %4.2f %% simulation %4.2f %% time %4.2f %% variable %4.2f %% \n',kb/nb*100,ks/ns*100,kt/nt*100,kv/nv*100);
            end
        end
    end
end %kb

end %function