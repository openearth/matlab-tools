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
%writes initial composition files. For a given matrix 'frac_xy' containing x
%and y coordinates of 'np' points, it writes the files corresponding to
%'nl' layers and 'nf' fractions given in 'frac'. The first layer (i.e.,
%frac(:,1,:) is the active layer. Similarly for the thickness. 
%
%INPUT:
%   -simdef.mor.frac = volume fraction content [-]; [np,nl,nf]
%   -simdef.mor.thk = layer thickness [-]; [np,nl]

function D3D_morini_files(simdef)

dire_sim=simdef.D3D.dire_sim;
frac=simdef.mor.frac;
frac_xy=simdef.mor.frac_xy;
thk=simdef.mor.thk;
folder_out=simdef.mor.folder_out;

nf=size(frac,3);
nl=size(frac,2);

%% round

check_Fak(frac);

prec=9;
frac_rn=round(frac,prec);
% frac_rn(:,:,end)=1-sum(frac_rn(:,:,1:end-1),3);
frac_rn(:,:,1)=1-sum(frac_rn(:,:,2:end),3);
frac_rn(frac_rn<1*10^(-prec))=0;

check_Fak(frac_rn);

%% write
for kl=1:nl
    file_name=fullfile(dire_sim,folder_out,sprintf('lyr%02d_thk.xyz',kl));
    outmat=[frac_xy(:,1),frac_xy(:,2),thk(:,kl)];
    write_2DMatrix(file_name,outmat)
    for kf=1:nf
        file_name=fullfile(dire_sim,folder_out,sprintf('lyr%02d_frac%02d.xyz',kl,kf));
        outmat=[frac_xy(:,1),frac_xy(:,2),frac_rn(:,kl,kf)];
        write_2DMatrix(file_name,outmat)
    end
end

end

%%
%% FUNCTIONS
%%

function check_Fak(fractions_var_mod)

tol=1e-12;
if ~isempty(find(fractions_var_mod>1+tol, 1)) || ~isempty(find(fractions_var_mod<-tol, 1))
     warning('ups')
end

tol_sum=1e-12;
if ~isempty(find(sum(fractions_var_mod,3)>1+tol_sum,1)) || ~isempty(find(any(sum(fractions_var_mod,3)<1-tol_sum), 1))
    warning('ups on sum')
end

end
