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
diff_z=diff(z_cen);
z_cor=[z_cen(1)-diff_z(1)/2,z_cen(1:end-1)+diff_z/2,z_cen(end)+diff_z(end)/2];
    
% figure
% hold on
% scatter(zeros(1,numel(z_cen)),z_cen,'*b')
% scatter(zeros(1,numel(z_cor)),z_cor,'or')

end %function