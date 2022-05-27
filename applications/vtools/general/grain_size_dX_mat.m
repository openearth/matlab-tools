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