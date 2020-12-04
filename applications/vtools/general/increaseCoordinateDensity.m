%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: writetxt.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/writetxt.m $
%
function [c_out]=increaseCoordinateDensity(c_axis,ninc)

c_out=[];
for kv=1:2
c_cons=[c_axis(1:end-1,kv),c_axis(2:end,kv)];
c_loc=c_cons(:,1)+(c_cons(:,2)-c_cons(:,1))/ninc.*(0:1:ninc);
c_out=cat(1,c_out,reshape(c_loc',1,[]));
end
c_out=c_out';

% figure
% hold on
% plot(x_axis,y_axis,'-*')
% plot(x_out_s(:,1),x_out_s(:,2),'-*')

end