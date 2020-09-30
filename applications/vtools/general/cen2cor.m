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
%center to corners in a vector

function z_cor=cen2cor(z_cen)

z_cen=reshape(z_cen,1,[]);
bol_z_cen_nan=isnan(z_cen);

z_cen_nn=z_cen(~bol_z_cen_nan);
diff_z=diff(z_cen_nn);
z_cor_nn=[z_cen_nn(1)-diff_z(1)/2,z_cen_nn(1:end-1)+diff_z/2,z_cen_nn(end)+diff_z(end)/2];
z_cor=NaN(1,numel(z_cen)+1);
idx_z_cen_nnan=find(~bol_z_cen_nan);
idx_place_z_cord=[idx_z_cen_nnan,idx_z_cen_nnan(end)+1];
z_cor(idx_place_z_cord)=z_cor_nn;

end %function