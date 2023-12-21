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