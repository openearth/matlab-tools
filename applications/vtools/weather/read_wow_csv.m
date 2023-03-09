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
%read exported CSV data from WOW
%
%E.G.
%
% fpath='c:\Users\chavarri\Downloads\export-all.csv';
% data=read_wow_csv(fpath);
% 
% %%
% 
% figure
% hold on
% plot(data.tim,data.rain_acc);
% ylabel('accumulated rain per event [mm]')
% set(findall(gcf,'-property','FontSize'),'FontSize',16)
% print(gcf,'r.png','-dpng')

function data=read_wow_csv(fpath)

raw_mat=readmatrix(fpath);
raw_cel=readcell(fpath);

%mat
row_m1=1;
col_rain_acc=20;

%cell
row_c1=2;
col_tim=5; 

tim=[raw_cel{row_c1:end,col_tim}]';
rain_acc=raw_mat(row_m1:end,col_rain_acc);

%out
data=v2struct(tim,rain_acc);

end %function