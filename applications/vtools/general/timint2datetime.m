%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19229 $
%$Date: 2023-11-03 13:13:41 +0100 (Fri, 03 Nov 2023) $
%$Author: chavarri $
%$Id: fig_his_sal_01.m 19229 2023-11-03 12:13:41Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/fig_his_sal_01.m $
%
%Convert time input as integer number to datetime. 

function tim_dtime=timint2datetime(tim_int)

ntim=numel(tim_int);
tim_dtime=NaT(ntim,1);
tim_dtime.TimeZone='+00:00';

%There must be a way to do this nicer in vectorial form
for ktim=1:ntim
    tim_dtime(ktim)=datetime(num2str(tim_int(ktim)),'InputFormat','yyyyMMdd','TimeZone','+00:00');
end %ktim

end %function