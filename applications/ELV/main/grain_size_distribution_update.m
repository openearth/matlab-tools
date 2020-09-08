%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 231 $
%$Date: 2020-04-06 16:00:58 +0200 (Mon, 06 Apr 2020) $
%$Author: chavarri $
%$Id: grain_size_distribution_update.m 231 2020-04-06 14:00:58Z chavarri $
%$HeadURL: https://repos.deltares.nl/repos/ELV/trunk/main/grain_size_distribution_update.m $
%
%grain_size_distribution_update updates the mass at the active layer and the substrate and the substrate thickness
%
%[Mak_new,msk_new,Ls_new,La_ne,etab_new,ell_idx,out_en,pmm]=grain_size_distribution_update(Mak,msk,Ls,La_old,La,etab_old,etab,qbk,bc,u,h,Cf,input,fid_log,kt)
%
%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%160223
%   -V. Created for the first time.
%
%160429
%   -V. Bug solved. In case the active layer thickness is updated the
%   derivatives need to be computed with the old one because is the one
%   used in the computation of the sediment transport (nt changed in
%   Hirano)
%
%166614
%   -V. Output pmm for adjusting CFL condition
%
%160701
%   -V. Hoey and Ferguson
%
%181104
%   -V. Add possibility of CFL based time step
%   -V. Removed special functions _pmm

function [Mak_new,msk_new,Ls_new,La_ne,etab_new,ell_idx,out_en,pmm]=grain_size_distribution_update(Mak,msk,Ls,La_old,La,etab_old,etab,qbk,Dk,Ek,bc,u,h,Cf,input,fid_log,kt,time_l)

%%
%% RENAME
%%

%%
%% GSD UPDATE
%%

switch input.mor.gsdupdate
%% NO UPDATE    
    case 0
        Mak_new=Mak;
        msk_new=msk;
        Ls_new=Ls;
        ell_idx=zeros(1,input.mdv.nx);
        La_ne=La; %non-elliptic La
        out_en=struct('ls',[],'lb',[],'gamma',[],'mu',[],'A',[],'eigen',[],'eigen_pmm',[]);
        etab_new=etab;
        pmm(1,:)=ones(1,input.mdv.nx); %alpha
        pmm(2,:)=ones(1,input.mdv.nx); %beta
        
%% HIRANO        
    case 1       
        pmm(1,:)=ones(1,input.mdv.nx); %alpha
        pmm(2,:)=ones(1,input.mdv.nx); %beta
        [msk_new,Ls_new,fIk,detaLa]=substrate_update(Mak,msk,Ls,La_old,La,etab_old,etab,qbk,input,fid_log,kt);
        Mak_new=active_layer_mass_update(Mak,detaLa,fIk,qbk,Dk,Ek,bc,input,fid_log,kt,time_l,pmm);
        if input.mor.ellcheck
            [ell_idx,out_en]=elliptic_nodes(u,h,Cf,La_old,qbk,Mak,fIk,input,fid_log,kt);
            out_en.eigen_pmm=[]; %avoid dissimilar structures
        else
            ell_idx=zeros(1,input.mdv.nx);
            out_en=struct('ls',[],'lb',[],'gamma',[],'mu',[],'A',[],'eigen',[],'eigen_pmm',[]);
        end
        La_ne=La; %non-elliptic La
        etab_new=etab;
        
%% ELI 1
    case {2,3}
        [~,~,fIk,~]=substrate_update(Mak,msk,Ls,La_old,La,etab_old,etab,qbk,input,fid_log,kt); %substrate to obtain fIk
        [ell_idx,out_en]=elliptic_nodes(u,h,Cf,La_old,qbk,Mak,fIk,input,fid_log,kt); %La_old because the derivatives are of the transport before updating La
        La_ne=eli_1(La,ell_idx,out_en,input,fid_log,kt);
        [msk_new,Ls_new,fIk,detaLa]=substrate_update(Mak,msk,Ls,La_old,La_ne,etab_old,etab,qbk,input,fid_log,kt); %obtain the new substrate
        Mak_new=active_layer_mass_update(Mak,detaLa,fIk,qbk,Dk,Ek,bc,input,fid_log,kt,time_l); %obtain the new mass at the active layer
        etab_new=etab;
        pmm(1,:)=ones(1,input.mdv.nx); %alpha
        pmm(2,:)=ones(1,input.mdv.nx); %beta
        
%% PRE-CONDITIONING MASS MATRIX
    case {4,5,6,7,8,9}
%         [~,~,fIk,~]=substrate_update(Mak,msk,Ls,La_old,La,etab_old,etab,qbk,input,fid_log,kt); %substrate to obtain fIk 
        [msk_new,Ls_new,fIk,detaLa]=substrate_update(Mak,msk,Ls,La_old,La,etab_old,etab,qbk,input,fid_log,kt); %substrate to obtain fIk (we get all output for when beta=1
        [ell_idx,out_en]=elliptic_nodes(u,h,Cf,La_old,qbk,Mak,fIk,input,fid_log,kt); %La_old because the derivatives are of the transport before updating La
        [pmm,out_en]=preconditioning_mass_matrix(ell_idx,out_en,u,input,fid_log,kt);
		switch input.mor.gsdupdate
			case {4,5} %beta~=1
				etab_new=bed_level_update(etab_old,qbk,Dk,Ek,bc,input,fid_log,kt,time_l,pmm);
				[msk_new,Ls_new,fIk,detaLa]=substrate_update(Mak,msk,Ls,La_old,La,etab_old,etab_new,qbk,input,fid_log,kt); %obtain the new substrate
			otherwise %beta=1
				etab_new=etab;
		end
        Mak_new=active_layer_mass_update(Mak,detaLa,fIk,qbk,Dk,Ek,bc,input,fid_log,kt,time_l,pmm);
%         Mak_new=active_layer_mass_update_pmm(Mak,detaLa,fIk,qbk,bc,pmm,input,fid_log,kt,time_l); %obtain the new mass at the active layer        
        La_ne=La; %non-elliptic La
end %gsdupdate

end %function
    
    
    




