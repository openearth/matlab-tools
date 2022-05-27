%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18070 $
%$Date: 2022-05-20 18:33:29 +0200 (Fri, 20 May 2022) $
%$Author: chavarri $
%$Id: D3D_var_num2str.m 18070 2022-05-20 16:33:29Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_var_num2str.m $
%
%

function val=grain_size_dX_mat(Fa,dchar,perc)

frac_nonan=Fa;
[nt,nF,nl,nf]=size(frac_nonan);
frac_nonan(isnan(frac_nonan))=0;

val=NaN(nt,nF,nl);
for kF=1:nF
    for kl=1:nl
        Fa=squeeze(frac_nonan(:,kF,kl,:));
        if sum(Fa)<1-1e-3 || sum(Fa)>1+1e-3 %take out values in which all are 0
            val(:,kF,kl)=NaN; 
        else
            dX=grain_size_dX(dchar,Fa,perc);
            val(:,kF,kl)=permute(dX,[3,4,2,1]); 
        end
    end %kl
end %kF

end %function