%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18966 $
%$Date: 2023-05-26 09:39:44 +0200 (Fri, 26 May 2023) $
%$Author: chavarri $
%$Id: interpolate_bed_level_from_xlsx.m 18966 2023-05-26 07:39:44Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/interpolate_bed_level_from_xlsx.m $
%
%

function [xpol_cen,ypol_cen]=centroid_polygons(pol)

npol=numel(pol.xy.XY);
xpol_cen=NaN(npol,1);
ypol_cen=NaN(npol,1);
for kpol=1:npol
    polyin=polyshape(pol.xy.XY{kpol,1}(:,1),pol.xy.XY{kpol,1}(:,2));
    [xpol_cen(kpol),ypol_cen(kpol)]=centroid(polyin);
    fprintf('Polygon centroid %4.2f %% \n',kpol/npol*100);
end

% %% BEGIN DEBUG
% 
% figure
% hold on
% for kpol=1:100
% plot(pol.xy.XY{kpol,1}(:,1),pol.xy.XY{kpol,1}(:,2))
% scatter(xpol_cen(kpol),ypol_cen(kpol));
% end
% 
% %% END DEBUG

end %function