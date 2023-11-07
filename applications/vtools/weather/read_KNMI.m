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
%Ad-hoc function to read KNMI data. It should be read in `read_csv_data`. 

function [tim_dtime,rain]=read_KNMI(fpath_knmi)

data=readmatrix(fpath_knmi);
col_tim=2;
col_rai=23;
tim_int=data(:,col_tim);
rain=data(:,col_rai)./10;
bol_th=rain==-0.1;
rain(bol_th)=0.025;
tim_dtime=timint2datetime(tim_int);

end