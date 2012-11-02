% So far no analysis on the singular value decomposition has been made
% in the papers or the thesis.
%
% We estimate the energy distribution in the SVD for different iterations
% of the test6_3obs_pertFixed.

clc; clear;

load('p:\x0385-gs-mor\ivan\paper_2\test_6_solver_fixed\iteration001\snapshots.mat');
save_fig_folder   =  'd:\Dropbox\Writtings\Paper 2 - Experiment in France\Figure\';

u = svd(snapshots);

%%
close all

h = figure;
hold on,;
posSw = [400   346   707   270]; 
set(gcf,'PaperPositionMode','auto'); 
set(gcf,'Position',posSw);


plot([1:50:1800],real(log10(u(1:50:1800)/u(1))),':x','color',[0.5,0.5,0.5],'linewidth',1.5,'markersize',7);
xlabel('i');
ylabel('Log10(\sigma/\sigma_1)','fontsize',14);

non_zero_sv = real(log10(u/u(1)));
non_zero_sv(non_zero_sv<-10) = [];

plot(length(non_zero_sv),real(log10(u(length(non_zero_sv))/u(1))),'bo','linewidth',1.5,'markersize',7);
plot(length(non_zero_sv+1),real(log10(u(length(non_zero_sv)+1)/u(1))),'ro','linewidth',1.5,'markersize',7);
legend('\sigma/\sigma_1',['\sigma_{',num2str(length(non_zero_sv)),'}'],['\sigma_{',num2str(length(non_zero_sv)+1),'}'],'location','southwest');

file_save_name = [save_fig_folder,'non_zeroSVs_3obs_pertSolved_it1'];
print('-depsc2',file_save_name);
saveas(h,file_save_name,'fig');